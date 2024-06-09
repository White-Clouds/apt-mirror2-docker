#!/bin/sh
base_path=$(grep "^set base_path" /etc/apt/mirror.list | awk '{print $3}')
if [ -z "$base_path" ]; then
    echo "Error: Unable to find base_path in /etc/apt/mirror.list"
    exit 1
fi
log_path="${base_path}/var/*.log"
restart_flag=0
for file in $log_path; do
    if [ "${file}" != "${base_path}/var/apt-mirror2.log" ]; then
        if [ $(tail -n 40 "$file" | grep -c "Metadata moved") -eq 1 ]; then
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
        if [ "$zero_speed_count" -ge 30 ]; then
            restart_flag=1
            break
        fi
    fi
done
if [ $restart_flag -eq 1 ]; then
    echo "Error: Check failed."
    pkill -9 apt-mirror
    current_hour=$(date +%H)
    current_minute=$(date +%M)
    cron_hours=$(echo $CRON_SCHEDULE | awk '{print $2}' | tr ',' ' ')
    cron_minute=$(echo $CRON_SCHEDULE | awk '{print $1}')
    if echo "$cron_hours" | grep -wq $(($current_hour + ($current_minute >= $cron_minute ? 1 : 0))); then
        exit 0
    else
        apt-mirror >/proc/1/fd/1 2>/proc/1/fd/2
    fi
else
    echo "Success: Check passed."
fi
