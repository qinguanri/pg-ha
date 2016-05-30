## 人工修复故障后，运行此脚本恢复双机热备的状态

if [ ! -f "ha.conf" ]; then
    echo "ERROR. cannot find ha.conf, please execute config.sh to generate."
    exit 1
fi

MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
PG_DIR=`cat ha.conf | grep PG_DIR| awk -F '=' {'print $2'}`
VIP_PG_MASTER=`cat ha.conf | grep VIP_PG_MASTER| awk -F '=' {'print $2'}`

PG_DIR_DATA="$PG_DIR/data"
PG_DIR_XLOG="$PG_DIR/xlog_archive"
PG_DIR_BACKUP="$PG_DIR/backup"

HOSTNAME=`hostname -I`
hostname "$HOSTNAME"

echo "(1) stopping pacemaker ..."
systemctl stop pacemaker.service

#echo "Important Notice!!!"
#echo " Input yes when you want to use old pg data to sync."
#echo " Input no when you want to clear old pg data and pull all data from master pg."
#echo " clear old data and pull all data from master pg may take 30 minutes."
#echo " you'd better input yes if the pg data has not be destroyed or loss."

#read -p "Please input(yes/no):" word

## 增量同步还存在问题。暂时只支持全量同步。
word="no"

if [ "$word" != "yes" ] && [ "$word" != "no" ]; then
	echo "Input error. please input again."
	exit 1
fi

if [ "$word" == "no" ]; then
	echo "(2) backup pg's old data..."
	mkdir -p $PG_DIR_BACKUP
	cp -rf $PG_DIR_DATA $PG_DIR_BACKUP

	## 清空旧的数据库数据
	if [ "$PG_DIR" != "/" ]; then
	    rm -rf $PG_DIR
	fi

	echo "(3) sync pg's new data from master ..."
	mkdir -p $PG_DIR_DATA
	mkdir -p $PG_DIR_XLOG

	## 从主库重新同步数据库数据
	echo "please input postgres's passwd:"
	pg_basebackup -h $VIP_PG_MASTER -U postgres -D $PG_DIR_DATA -X stream -P

	echo "standby_mode = 'on'
	primary_conninfo = 'host=$MASTER_IP port=5432 user=replicator application_name=$HOSTNAME password=8d5e9531-3817-460d-a851-659d2e51ca99 keepalives_idle=60 keepalives_interval=5 keepalives_count=5'
	restore_command = 'cp $PG_DIR/xlog_archive/%f %p'
	recovery_target_timeline = 'latest'" > $PG_DIR_DATA/recovery.conf

	chown -R postgres:postgres $PG_DIR
	chmod 0700 $PG_DIR_DATA
fi

echo "(4) sync pacemaker's config ..."
# 清理pacemaker的cib配置
cd /var/lib/pacemaker
mv cib cib_bak_"$$"
mkdir cib
rm -rf /var/lib/pgsql/tmp/PGSQL.lock

echo "(5) restart pacemaker ..."
systemctl start pacemaker.service

sleep 5

pacemaker_run=`ps -ef | grep pacemaker| grep -v grep |wc -l`
corosync_run=`ps -ef | grep corosync | grep -v grep | wc -l`
pcs_run=`ps -ef | grep pcs | grep -v grep | wc -l`

if [ "$pacemaker_run" == "0" ] || [ "$corosync_run" == "0" ] || [ "$pcs_run" == "0" ]; then
    echo "ERROR. config pacemaker error. please retry again."
    exit 1
fi

echo "Done!"