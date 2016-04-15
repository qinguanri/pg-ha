#!/bin/bash
STOP="docker stop main" 
LOGFILE="/var/log/keepalived-main-state.log"
echo "[backup]" >> $LOGFILE
date >> $LOGFILE
echo "being backup ..." >> $LOGFILE
echo "run cmd: docker stop main ..." >> $LOGFILE
$STOP >> $LOGFILE 2>&1


