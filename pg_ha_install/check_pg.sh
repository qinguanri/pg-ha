## 检查pg数据库是否正确启动，以及主备是否正常同步

if [ ! -f "ha.conf" ]; then
    echo "ERROR. 当前目录缺少ha.conf配置文件。 请先执行config.sh脚本生成配置文件"
    exit 1
fi

MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`

VIP_MASTER_STATE=`pcs status | grep vip-master | grep Started | wc -l`
VIP_SLAVE_STATE=`pcs status | grep vip-slave | grep Started | wc -l`

echo "(1) 检查 PG Master 和 PG Slave 是否已经启动:"

if [ "$VIP_MASTER_STATE" == "1" ] && [ "$VIP_SLAVE_STATE" == "1" ]; then
    echo "OK. PG Master/Slave 都已正常启动."
else
    echo "ERROR.  PG Master/Slave 启动错误."
fi


IS_LATEST=`crm_mon -Afr -1|grep LATEST | wc -l`
IS_SYNC=`crm_mon -Afr -1|grep SYNC | wc -l`

echo "(2) 检查 PG Master 和 PG Slave 同步状态是否正确:"
if [ "$IS_LATEST" == "1" ] && [ "$IS_SYNC" == "1" ]; then
    echo "OK. PG Master/Slave 同步状态正确"
else
    echo "ERROR. PG Master/Slave 同步状态异常"
fi
