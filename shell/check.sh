MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`


MASTER_STATE=`pcs status | grep $MASTER_IP|grep Online|wc -l`
SLAVE_STATE=`pcs status | grep $SLAVE_IP|grep Online|wc -l`

if [ "$MASTER_STATE" == "1" && "SLAVE_STATE" == "1" ]; then
	echo "pcsd status OK"
else
	echo "ERROR"
fi

VIP_MASTER_STATE=`pcs status | grep vip-master | grep Started | wc -l`
VIP_SLAVE_STATE=`pcs status | grep vip-slave | grep Started | wc -l`

if [ "$VIP_MASTER_STATE" == "1" && "VIP_SLAVE_STATE" == "1" ]; then
	echo "resource group status OK"
else
	echo "ERROR"
fi