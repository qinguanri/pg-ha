## 人工修复故障后，运行此脚本恢复双机热备的状态

if [ ! -f "ha.conf" ]; then
    echo "ERROR. 当前目录缺少ha.conf配置文件。 请先执行config.sh脚本生成配置文件"
    exit 1
fi

MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
PG_DIR=`cat ha.conf | grep PG_DIR| awk -F '=' {'print $2'}`

PG_DIR_DATA="$PG_DIR/data"
PG_DIR_XLOG="$PG_DIR/xlog_archive"
PG_DIR_BACKUP="$PG_DIR/backup"
HOSTNAME=`hostname`

echo "(1) 正在停止pacemaker ..."
systemctl stop pacemaker.service

echo "(2) 备份旧的数据库数据 ..."
mkdir -p $PG_DIR_BACKUP
mv $PG_DIR_DATA $PG_DIR_BACKUP

echo "(3) 从master库上同步数据 ..."
mkdir -p $PG_DIR_DATA
mkdir -p $PG_DIR_XLOG

echo "需要您输入pg数据库postgres用户的登录密码:"
pg_basebackup -h $VIP_PG_MASTER -U postgres -D $PG_DIR_DATA -X stream -P
echo "standby_mode = 'on'
primary_conninfo = 'host=$MASTER_IP port=5432 user=replicator application_name=$HOSTNAME password=8d5e9531-3817-460d-a851-659d2e51ca99 keepalives_idle=60 keepalives_interval=5 keepalives_count=5'
restore_command = 'cp $PG_DIR/xlog_archive/%f %p'
recovery_target_timeline = 'latest'" > $PG_DIR_DATA/recovery.conf

chown -R postgres:postgres $PG_DIR
chmod 0700 $PG_DIR_DATA

echo "(4) 同步pacemaker配置 ..."
# 清理pacemaker的cib配置
cd /var/lib/pacemaker
mv cib cib_bak
mkdir cib
rm -rf /var/lib/pgsql/tmp/PGSQL.lockf

echo "(5) 重启pacemaker ..."
systemctl start pacemaker.service

sleep 5
echo "重启完毕！"