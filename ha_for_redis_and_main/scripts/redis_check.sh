#!/bin/bash
ALIVE=`docker exec redis /usr/bin/redis-cli -h $1 -p $2 PING`
LOGFILE="/var/log/keepalived-redis-check.log"
echo "[CHECK]" >> $LOGFILE
date >> $LOGFILE
if [ "$ALIVE" == "PONG" ]; then :
    echo "Success: redis-cli -h $1 -p $2 PING $ALIVE" >> $LOGFILE 2>&1
    exit 0
else
    echo "Failed: redis-cli -h $1 -p $2 PING $ALIVE" >> $LOGFILE 2>&1
    exit 1
fi

