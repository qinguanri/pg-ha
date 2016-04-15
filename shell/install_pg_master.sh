PG_DIR=`cat ha.conf | grep PG_DIR| awk -F '=' {'print $2'}`

PG_DIR_DATA="$PG_DIR/data"
PG_DIR_XLOG="$PG_DIR/xlog_archive"

NET=$2

mkdir -p $PG_DIR_DATA
mkdir -p $PG_DIR_XLOG
chown -R postgres:postgres /data/postgresql/
chmod 0700 /data/postgresql/data

su - postgres << EOF
	initdb -D $PG_DIR_DATA

	echo "listen_addresses = '*'
wal_level = hot_standby
synchronous_commit = on
archive_mode = on
archive_command = 'cp %p $PG_DIR_XLOG/%f'
max_wal_senders=5
wal_keep_segments = 32
hot_standby = on
restart_after_crash = off
replication_timeout = 5000
wal_receiver_status_interval = 2
max_standby_streaming_delay = -1
max_standby_archive_delay = -1
synchronous_commit = on
restart_after_crash = off
hot_standby_feedback = on"  >> $PG_DIR_DATA/postgresql.conf


	echo "host    all             all    $NET      md5
host    replication     all    $NET      md5" >> $PG_DIR_DATA/pg_hba.conf


    pg_ctl -D /data/postgresql/data/ start
    sleep 2
    psql -U postgres;
    alter  user postgres with password 'postgres';
    create role replicator with login replication password '8d5e9531-3817-460d-a851-659d2e51ca99';
EOF

echo "master主机上的数据库配置完成!"