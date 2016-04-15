MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`
VIP_MAIN=`cat ha.conf | grep VIP_MAIN | awk -F '=' {'print $2'}`
VIP_REDIS=`cat ha.conf | grep VIP_REDIS | awk -F '=' {'print $2'}`
INTERFACE_NO=`cat ha.conf | grep INTERFACE_NO | awk -F '=' {'print $2'}`

sed -i "s/SLAVE_IP/$SLAVE_IP/g" keepalived_master.conf
sed -i "s/VIP_MAIN/$VIP_MAIN/g" keepalived_master.conf
sed -i "s/VIP_REDIS/$VIP_REDIS/g" keepalived_master.conf
sed -i "s/INTERFACE_NO/$INTERFACE_NO/g" keepalived_master.conf

sed -i "s/MASTER_IP/$MASTER_IP/g" keepalived_slave.conf
sed -i "s/VIP_MAIN/$VIP_MAIN/g" keepalived_slave.conf
sed -i "s/VIP_REDIS/$VIP_REDIS/g" keepalived_slave.conf
sed -i "s/INTERFACE_NO/$INTERFACE_NO/g" keepalived_slave.conf

mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

HOST_IP=`hostname -I`
if [ "$MASTER_IP" == "$HOST_IP" ]; then
    cp keepalived_master.conf /etc/keepalived/keepalived.conf
elif [ "$SLAVE_IP" == "$HOST_IP" ]; then
    cp keepalived_slave.conf /etc/keepalived/keepalived.conf
else
    echo "ERROR. ha.conf文件中的master/slave ip 地址配置错误"
    exit 1
fi

mv /etc/keepalived/scripts /etc/keepalived/scripts.bak
cp -r scripts /etc/keepalived
chmod +x /etc/keepalived/scripts/*.sh

systemctl restart keepalived.service

echo "keepalived 配置完成"
