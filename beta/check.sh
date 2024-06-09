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
        if [ $(tail -n 40 "$file" | grep -c "Metadata moved") -eq 0 ]; then
            restart_flag=1
            break
        fi
        if grep -q "apt-mirror is already running, exiting" "$file"; then
            restart_flag=1
            break
        fi
        lines=$(tail -n 40 "$file")
        for line in $lines; do
            if echo "$line" | grep -q "HTTPDownloader Download progress"; then
                speed=$(echo "$line" | awk -F' ' '{print $(NF-1)}' | tr -dc '0-9.')
                unit=$(echo "$line" | awk -F' ' '{print $NF}')
                if [ "$unit" = "KiB/sec" ]; then
                    speed=$(echo "$speed*1024" | bc)
                elif [ "$unit" = "MiB/sec" ]; then
                    speed=$(echo "$speed*1024*1024" | bc)
                elif [ "$unit" = "GiB/sec" ]; then
                    speed=$(echo "$speed*1024*1024*1024" | bc)
                fi
                if [ $(echo "$speed < 200" | bc -l) -eq 1 ]; then
                    restart_flag=1
                    break 2
                fi
            fi
        done
        if [ $restart_flag -eq 1 ]; then
            break
        fi
    fi
done
if [ $restart_flag -eq 1 ]; then
    echo "Error: Check failed."
    pkill -9 apt-mirror
    current_hour=$(date +%H)
    current_minute=$(date +%M)
    if echo $CRON_SCHEDULE | awk '{print $2}' | grep -q $(($current_hour + ($current_minute >= 30 ? 1 : 0))); then
        exit 0
    else
        apt-mirror >/proc/1/fd/1 2>/proc/1/fd/2
    fi
else
    echo "Success: Check passed."
fi