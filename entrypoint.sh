#!/bin/sh
cp /usr/share/zoneinfo/"$TZ" /etc/localtime
echo "$TZ" > /etc/timezone
{
  echo "TZ=$TZ"
  echo "PATH=$PATH"
  echo "$CRON_SCHEDULE /bin/sh -c 'apt-mirror > /proc/1/fd/1 2>/proc/1/fd/2'"
  echo "*/20 * * * * /bin/sh -c /check.sh"
} > /etc/crontabs/apt-mirror2
chmod 0644 /etc/crontabs/apt-mirror2
crontab /etc/crontabs/apt-mirror2
nginx
crond -f
