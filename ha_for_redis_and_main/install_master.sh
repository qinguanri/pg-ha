MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`
VIP_MAIN=`cat ha.conf | grep VIP_MAIN | awk -F '=' {'print $2'}`
VIP_REDIS=`cat ha.conf | grep VIP_REDIS | awk -F '=' {'print $2'}`
INTERFACE_NO=`cat ha.conf | grep INTERFACE_NO | awk -F '=' {'print $2'}`

sed 's/SLAVE_IP/$SLAVE_IP/g' keepalived_master.conf
sed 's/VIP_MAIN/$VIP_MAIN/g' keepalived_master.conf
sed 's/VIP_REDIS/$VIP_REDIS/g' keepalived_master.conf
sed 's/INTERFACE_NO/$INTERFACE_NO/g' keepalived_master.conf

sed 's/SLAVE_IP/$SLAVE_IP/g' keepalived_slave.conf
sed 's/VIP_MAIN/$VIP_MAIN/g' keepalived_slave.conf
sed 's/VIP_REDIS/$VIP_REDIS/g' keepalived_slave.conf
sed 's/INTERFACE_NO/$INTERFACE_NO/g' keepalived_slave.conf

mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
cp keepalived_master.conf /etc/keepalived/keepalived.conf

mv /etc/keepalived/scripts /etc/keepalived/scripts.bak
cp -r scripts /etc/keepalived

systemctl restart keepalived.service
