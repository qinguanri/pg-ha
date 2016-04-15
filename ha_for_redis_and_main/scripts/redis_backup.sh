#!/bin/bash
REDISCLI="docker exec redis /usr/bin/redis-cli" 
LOGFILE="/var/log/keepalived-redis-state.log"
echo "[backup]" >> $LOGFILE
date >> $LOGFILE
echo "Run SLAVEOF cmd ..." >> $LOGFILE
$REDISCLI SLAVEOF $2 $3 >> $LOGFILE 2>&1
sleep 15 #delay 15 s wait data sync exchange role
