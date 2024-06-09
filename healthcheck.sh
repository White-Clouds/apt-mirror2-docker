#!/bin/sh
if ! wget -q --tries=10 --timeout=20 --spider http://127.0.0.1
then
    echo "Error: Nginx is not running."
    exit 1
fi
if ! grep -q "ERROR" /var/spool/apt-mirror/var/*.log
then
    echo "Success: Healthcheck passed."
    exit 0
else
    echo "Error: Apt-mirror2 log contains errors."
    exit 1
fi
