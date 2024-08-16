#!/bin/sh
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N'): $1"
}

base_path=$(grep "^set base_path" /etc/apt/mirror.list | awk '{print $3}')
if [ -z "$base_path" ]; then
    log "ERROR: Unable to find base_path in /etc/apt/mirror.list"
    exit 1
fi
log_path="${base_path}/var/*.log"
restart_flag=0
target_speed_kb=100

get_actual_speed() {
    interface=$(ip route get 8.8.8.8 | awk -- '{printf $5}')
    if [ -n "$interface" ]; then
        speed_bps=$(cat /sys/class/net/"$interface"/statistics/rx_bytes)
        sleep 1
        speed_bps_new=$(cat /sys/class/net/"$interface"/statistics/rx_bytes)
        speed_kbps=$(((speed_bps_new - speed_bps) / 1024))
        echo $speed_kbps
    else
        echo 0
    fi
}

for file in $log_path; do
    if [ "${file}" != "${base_path}/var/apt-mirror2.log" ]; then
        if [ "$(tail -n 40 "$file" | grep -c "Metadata moved")" -eq 1 ]; then
            break
        else
            restart_flag=1
            break
        fi
        if grep -q "apt-mirror is already running, exiting" "$file"; then
            restart_flag=1
            break
        fi
        zero_speed_count=$(tail -n 40 "$file" | grep -c "0.0 B/sec")
        actual_speed=$(for _ in $(seq 1 5); do
            get_actual_speed
            sleep 3
        done)
        if [ "$zero_speed_count" -ge 30 ] && [ "$actual_speed" -lt "$target_speed_kb" ]; then
            restart_flag=1
            break
        fi
    fi
done

if [ $restart_flag -eq 1 ]; then
    log "ERROR: Check failed."
    pkill -9 apt-mirror
    current_hour=$(date +%H)
    current_minute=$(date +%M)
    cron_hours=$(echo "$CRON_SCHEDULE" | awk '{print $2}' | tr ',' ' ')
    cron_minute=$(echo "$CRON_SCHEDULE" | awk '{print $1}')
    if echo "$cron_hours" | grep -wq $((current_hour + (current_minute >= cron_minute ? 1 : 0))); then
        exit 0
    else
        apt-mirror >/proc/1/fd/1 2>/proc/1/fd/2
    fi
else
    log "INFO: Check passed."
fi
