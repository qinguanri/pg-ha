#!/bin/bash
ALIVE=`docker ps -a|grep skylar_main|wc -l`
LOGFILE="/var/log/keepalived-main-check.log"
echo "[CHECK]" >> $LOGFILE
date >> $LOGFILE
if [ "$ALIVE" -gt "0" ]; then :
    echo "Success: skylar_main is exist" >> $LOGFILE 2>&1
    exit 0
else
    echo "Failed: skylar_main is not exist" >> $LOGFILE 2>&1
    exit 1
fi

