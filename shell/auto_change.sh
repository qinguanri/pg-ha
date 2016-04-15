MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`
MASTER_VIP=`cat ha.conf | grep VIP_PG_MASTER| awk -F '=' {'print $2'}`
SLAVE_VIP=`cat ha.conf | grep VIP_PG_SLAVE| awk -F '=' {'print $2'}`
PG_DIR=`cat ha.conf | grep PG_DIR| awk -F '=' {'print $2'}`


PG_CTL=`which pg_ctl`
PSQL=`which psql`

su - postgres << EOF
    pg_ctl -D $PG_DIR/data/ -mi stop
EOF

cd /var/lib/pacemaker/cib
rm -rf /var/lib/pacemaker/cib/

# 将cib配置保存到文件
pcs cluster cib pgsql_cfg
# 在pacemaker级别忽略quorum
pcs -f pgsql_cfg property set no-quorum-policy="ignore"
# 禁用STONITH
pcs -f pgsql_cfg property set stonith-enabled="false"
# 设置资源粘性，防止节点在故障恢复后发生迁移
pcs -f pgsql_cfg resource defaults resource-stickiness="INFINITY"
# 设置多少次失败后迁移
pcs -f pgsql_cfg resource defaults migration-threshold="3"
# 设置master节点虚ip
pcs -f pgsql_cfg resource create vip-master IPaddr2 ip="$MASTER_VIP" cidr_netmask="24"    op start   timeout="60s" interval="0s"  on-fail="restart"    op monitor timeout="60s" interval="10s" on-fail="restart"    op stop    timeout="60s" interval="0s"  on-fail="block"
# 设置slave节点虚ip
pcs -f pgsql_cfg resource create vip-slave IPaddr2 ip="$SLAVE_VIP" cidr_netmask="24"    op start   timeout="60s" interval="0s"  on-fail="restart"    op monitor timeout="60s" interval="10s" on-fail="restart"    op stop    timeout="60s" interval="0s"  on-fail="block"
# 设置pgsql集群资源
# pgctl、psql、pgdata和config等配置根据自己的环境修改
pcs -f pgsql_cfg resource create pgsql pgsql pgctl="$PG_CTL" psql="$PSQL" pgdata="$PG_DIR/data" config="$PG_DIR/data/postgresql.conf" rep_mode="sync" node_list="$MASTER_IP $SLAVE_IP" master_ip="$MASTER_VIP"  repuser="replicator" primary_conninfo_opt="password=8d5e9531-3817-460d-a851-659d2e51ca99 keepalives_idle=60 keepalives_interval=5 keepalives_count=5" restore_command="cp $PG_DIR/xlog_archive/%f %p" restart_on_promote='true' op start   timeout="60s" interval="0s"  on-fail="restart" op monitor timeout="60s" interval="4s" on-fail="restart" op monitor timeout="60s" interval="3s"  on-fail="restart" role="Master" op promote timeout="60s" interval="0s"  on-fail="restart" op demote  timeout="60s" interval="0s"  on-fail="stop" op stop    timeout="60s" interval="0s"  on-fail="block"
# 设置master/slave模式
pcs -f pgsql_cfg resource master pgsql-cluster pgsql master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
# 配置master ip组
pcs -f pgsql_cfg resource group add master-group vip-master
# 配置slave ip组
pcs -f pgsql_cfg resource group add slave-group vip-slave
# 配置master ip组绑定master节点
pcs -f pgsql_cfg constraint colocation add master-group with master pgsql-cluster INFINITY
# 配置启动master节点
pcs -f pgsql_cfg constraint order promote pgsql-cluster then start master-group symmetrical=false score=INFINITY
# 配置停止master节点
pcs -f pgsql_cfg constraint order demote  pgsql-cluster then stop  master-group symmetrical=false score=0
# 配置slave ip组绑定slave节点
pcs -f pgsql_cfg constraint colocation add slave-group with slave pgsql-cluster INFINITY
# 配置启动slave节点
pcs -f pgsql_cfg constraint order promote pgsql-cluster then start slave-group symmetrical=false score=INFINITY
# 配置停止slave节点
pcs -f pgsql_cfg constraint order demote  pgsql-cluster then stop  slave-group symmetrical=false score=0
# 把配置文件push到cib
pcs cluster cib-push pgsql_cfg


echo "pg故障切换配置完成."
