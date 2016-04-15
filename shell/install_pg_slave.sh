MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
PG_DIR=`cat ha.conf | grep PG_DIR| awk -F '=' {'print $2'}`

HOSTNAME=`hostname`

PG_DIR_DATA="$PG_DIR/data"
PG_DIR_XLOG="$PG_DIR/xlog_archive"

mkdir -p $PG_DIR_DATA
mkdir -p $PG_DIR_XLOG
chown -R postgres:postgres $PG_DIR
chmod 0700 $PG_DIR_DATA

echo "需要您输入pg数据库postgres用户的登录密码"
su - postgres << EOF
    pg_basebackup -h $MASTER_IP -U postgres -D $PG_DIR_DATA -X stream -P
	  echo "standby_mode = 'on'
primary_conninfo = 'host=$MASTER_IP port=5432 user=replicator application_name=$HOSTNAME password=8d5e9531-3817-460d-a851-659d2e51ca99 keepalives_idle=60 keepalives_interval=5 keepalives_count=5'
restore_command = 'cp $PG_DIR/xlog_archive/%f %p'
recovery_target_timeline = 'latest'" > $PG_DIR_DATA/recovery.conf

    pg_ctl -D $PG_DIR_DATA start
EOF

sleep 5

su - postgres <<EOF
    pg_ctl -D $PG_DIR/data/ -mi stop
EOF

# 清理pacemaker的cib配置
cd /var/lib/pacemaker
mv cib cib_bak
mkdir cib

echo "slave主机的数据库配置完成."
