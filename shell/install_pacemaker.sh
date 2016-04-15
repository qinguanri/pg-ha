MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`

hostname=`hostname -I`
hostname "$hostname"

echo "正在安装pacemaker、postgresql-server，安装可能需要几分钟 ..."

yum install -y pacemaker pcs psmisc policycoreutils-python postgresql-server >> /dev/null

echo "pacemaker安装完成，还需要配置一下，请稍后 ..."

setenforce 0

sed -i.bak "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config

systemctl disable firewalld.service
systemctl stop firewalld.service
iptables --flush

systemctl start pcsd.service
systemctl enable pcsd.service
echo hacluster | passwd hacluster --stdin

pcs cluster auth -u hacluster -p hacluster $MASTER_IP $SLAVE_IP

pcs cluster setup --last_man_standing=1 --name pgcluster $MASTER_IP $SLAVE_IP

pcs cluster start --all

echo "pacemaker 配置结束!"
