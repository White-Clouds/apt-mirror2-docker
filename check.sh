#!/bin/sh
for file in /var/spool/apt-mirror/var/*.log
do
    if [ $(tail -n 40 $file | grep -c "Metadata moved") -eq 1 ]
    then
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
