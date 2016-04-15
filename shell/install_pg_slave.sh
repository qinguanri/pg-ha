MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
PG_DIR=`cat ha.conf | grep PG_DIR| awk -F '=' {'print $2'}`

HOSTNAME=`hostname`

su - postgres << EOF
    pg_basebackup -h $MASTER_IP -U postgres -D $PG_DIR/data/ -X stream -P
	echo "standby_mode = 'on'
primary_conninfo = 'host=$MASTER_IP port=5432 user=replicator application_name=$HOSTNAME password=8d5e9531-3817-460d-a851-659d2e51ca99 keepalives_idle=60 keepalives_interval=5 keepalives_count=5'
restore_command = 'cp $PG_DIR/xlog_archive/%f %p'
recovery_target_timeline = 'latest'" > $PG_DIR/data/recovery.conf

    pg_ctl -D $PG_DIR/data/ start
EOF

sleep 10

su - postgres <<EOF
    pg_ctl -D $PG_DIR/data/ -mi stop
EOF

echo "slave主机的数据库配置完成."
