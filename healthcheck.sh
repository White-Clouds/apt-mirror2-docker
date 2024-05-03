#!/bin/sh
wget -q --tries=10 --timeout=20 --spider http://127.0.0.1
if [ $? -ne 0 ]
then
    exit 1
fi
grep -q "ERROR" /var/spool/apt-mirror/var/*.log
if [ $? -ne 0 ]
then
    exit 0
else
    exit 1
fi
