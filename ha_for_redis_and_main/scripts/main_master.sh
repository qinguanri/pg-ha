#!/bin/bash
RESTART="docker restart main" 
LOGFILE="/var/log/keepalived-main-state.log"
echo "[master]" >> $LOGFILE
date >> $LOGFILE
echo "Being master...." >> $LOGFILE
echo "Run cmd: docker restart main ..." >> $LOGFILE
$RESTART >> $LOGFILE

