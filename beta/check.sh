#!/bin/sh
base_path=$(grep "^set base_path" /etc/apt/mirror.list | awk '{print $3}')
if [ -z "$base_path" ]; then
    echo "Error: Unable to find base_path in /etc/apt/mirror.list"
    exit 1
fi
log_path="${base_path}/var/*.log"
for file in $log_path; do
    if [ $(tail -n 40 "$file" | grep -c "Metadata moved") -eq 1 ]; then
        break
    fi
    if [ $(tail -n 40 $file | grep -c "0.0 B/sec") -eq 40 ]
    then
        pkill -9 apt-mirror
        current_hour=$(date +%H)
        current_minute=$(date +%M)
        if echo $CRON_SCHEDULE | awk '{print $2}' | grep -q $(($current_hour + ($current_minute >= 30 ? 1 : 0)))
        then
            break
        else
            apt-mirror > /proc/1/fd/1 2>/proc/1/fd/2
            break
        fi
    fi
done
