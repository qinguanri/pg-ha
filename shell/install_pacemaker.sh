MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`
PG_DIR=`cat ha.conf | grep PG_DIR| awk -F '=' {'print $2'}`

PG_DIR_DATA="$PG_DIR/data"
PG_DIR_XLOG="$PG_DIR/xlog_archive"

hostname=`hostname -I`
hostname "$hostname"

yum install -y pacemaker pcs psmisc policycoreutils-python postgresql-server >> /dev/null

setenforce 0
 
sed -i.bak "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config

systemctl disable firewalld.service
systemctl stop firewalld.service
iptables --flush

systemctl start pcsd.service
systemctl enable pcsd.service
echo hacluster | sudo passwd hacluster --stdin

pcs cluster auth -u hacluster -p hacluster $MASTER_IP $SLAVE_IP

pcs cluster setup --last_man_standing=1 --name pgcluster $MASTER_IP $SLAVE_IP

pcs cluster start --all

echo "pacemaker 配置结束!"