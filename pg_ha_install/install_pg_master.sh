## 

if [ ! -f "ha.conf" ]; then
    echo "ERROR. cannot find ha.conf, please execute config.sh to generate."
    exit 1
fi

PG_DIR=`cat ha.conf | grep PG_DIR| awk -F '=' {'print $2'}`

PG_DIR_DATA="$PG_DIR/data"
PG_DIR_XLOG="$PG_DIR/xlog_archive"

MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`

NET=`cat ha.conf | grep NET| awk -F '=' {'print $2'}`

MY_IP=`hostname`

if [ "$MY_IP" != "$MASTER_IP" ]; then
    echo "ERROR. this host isnot master host, should not execute this script"
    echo "current IP：$MY_IP, master IP：$MASTER_IP"
    exit 1
fi

mv $PG_DIR_DATA $PG_DIR/bak

mkdir -p $PG_DIR

# data.tar.gz 是pg初始化后生成的data目录文件。安装前要准备好
cp data.tar.gz $PG_DIR
cd $PG_DIR
gunzip data.tar.gz
tar xvf data.tar

mkdir -p $PG_DIR_XLOG
chown -R postgres:postgres $PG_DIR
chmod 0700 $PG_DIR_DATA

su - postgres << EOF
    #initdb -D $PG_DIR_DATA -E UTF-8 --no-locale

    echo "listen_addresses = '*'
wal_level = hot_standby
synchronous_commit = on
archive_mode = on
archive_command = 'cp %p $PG_DIR_XLOG/%f'
max_wal_senders=5
wal_keep_segments = 32
#replication_timeout = 5000
hot_standby = on
restart_after_crash = off
wal_receiver_status_interval = 2
max_standby_streaming_delay = -1
max_standby_archive_delay = -1
synchronous_commit = on
restart_after_crash = off
hot_standby_feedback = on"  >> $PG_DIR_DATA/postgresql.conf


    echo "host    all             all    $NET      md5
host    replication     all    $NET      md5" >> $PG_DIR_DATA/pg_hba.conf


    pg_ctl -D $PG_DIR_DATA start
    echo "pg start ok, config password ..."

        sleep 5
    psql -U postgres << EOFF
        alter  user postgres with password 'postgres';
        create role replicator with login replication password '8d5e9531-3817-460d-a851-659d2e51ca99';

EOFF
EOF

echo "Done. master's pg config ok"
