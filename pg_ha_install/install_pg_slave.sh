## 初始化slave主机上的pg

if [ ! -f "ha.conf" ]; then
    echo "ERROR. 当前目录缺少ha.conf配置文件。 请先执行config.sh脚本生成配置文件"
    exit 1
fi

MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`
PG_DIR=`cat ha.conf | grep PG_DIR| awk -F '=' {'print $2'}`

HOSTNAME=`hostname`

PG_DIR_DATA="$PG_DIR/data"
PG_DIR_XLOG="$PG_DIR/xlog_archive"

MY_IP=`hostname`

if [ "$MY_IP" != "$SLAVE_IP" ]; then
    echo "ERROR. 这台主机可能不是slave主机，不能执行该脚本。"
    echo "本机IP：$MY_IP, master主机IP：$SLAVE_IP"
    exit 1
fi


mkdir -p $PG_DIR_DATA
mkdir -p $PG_DIR_XLOG


echo "需要您输入pg数据库postgres用户的登录密码"
pg_basebackup -h "$MASTER_IP" -U postgres -D "$PG_DIR_DATA" -X stream -P

echo "standby_mode = 'on'
primary_conninfo = 'host=$MASTER_IP port=5432 user=replicator application_name=$HOSTNAME password=8d5e9531-3817-460d-a851-659d2e51ca99 keepalives_idle=60 keepalives_interval=5 keepalives_count=5'
restore_command = 'cp $PG_DIR/xlog_archive/%f %p'
recovery_target_timeline = 'latest'" > $PG_DIR_DATA/recovery.conf

chown -R postgres:postgres $PG_DIR
chmod 0700 $PG_DIR_DATA
chmod 777 $PG_DIR

su - postgres << EOF
    pg_ctl -D $PG_DIR_DATA start
EOF

sleep 5

su - postgres <<EOF
    pg_ctl -D $PG_DIR/data/ -mi stop
EOF

# 清理pacemaker的cib配置
cd /var/lib/pacemaker
cp -r cib cib_bak
rm -rf cib
mkdir cib

echo "slave主机的数据库配置完成."
