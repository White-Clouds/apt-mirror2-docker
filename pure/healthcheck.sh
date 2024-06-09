#!/bin/sh
if ! grep -q "ERROR" /var/spool/apt-mirror/var/*.log
then
    echo "Success: Healthcheck passed."
    exit 0
else
    echo "Error: Apt-mirror2 log contains errors."
    exit 1
fi
