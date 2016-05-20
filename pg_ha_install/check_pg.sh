## check pg whether start ok and sync ok.

if [ ! -f "ha.conf" ]; then
    echo "ERROR. cannot find ha.conf, please execute config.sh to generate."
    exit 1
fi

MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`

VIP_MASTER_STATE=`pcs status | grep vip-master | grep Started | wc -l`
VIP_SLAVE_STATE=`pcs status | grep vip-slave | grep Started | wc -l`

echo "(1) check PG Master and PG Slave whether start ok or not:"

if [ "$VIP_MASTER_STATE" == "1" ] && [ "$VIP_SLAVE_STATE" == "1" ]; then
    echo "OK. PG Master/Slave start ok."
else
    echo "ERROR.  PG Master/Slave start error."
fi


IS_LATEST=`crm_mon -Afr -1|grep LATEST | wc -l`
IS_SYNC=`crm_mon -Afr -1|grep SYNC | wc -l`

echo "(2) check PG Master and PG Slave sync status whether ok or not:"
if [ "$IS_LATEST" == "1" ] && [ "$IS_SYNC" == "1" ]; then
    echo "OK. PG Master/Slave sync ok"
else
    echo "ERROR. PG Master/Slave sync error"
fi
