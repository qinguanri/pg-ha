## 离线安装pacemaker、pg等组件。

if [ ! -f "ha.conf" ]; then
    echo "ERROR. 当前目录缺少ha.conf配置文件。 请先执行config.sh脚本生成配置文件"
    exit 1
fi

MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`

## 为方便起见，修改hostname为本机IP
hostname=`hostname -I`
hostname "$hostname"

# 创建postgres用户，用于登录pg
useradd postgres

echo "正在安装postgresql-server，安装可能需要几分钟 ..."
yum install -y --disablerepo=\* --enablerepo=Local postgresql94-server postgresql94-contrib

echo "正在安装pacemaker组件，安装可能需要几分钟 ..."
yum install -y --disablerepo=\* --enablerepo=Pacemaker pacemaker pcs psmisc policycoreutils-python 

echo "pacemaker安装完成，还需要配置一下，请稍后 ..."

systemctl start pcsd.service
systemctl enable pcsd.service
echo hacluster | passwd hacluster --stdin

pcs cluster auth -u hacluster -p hacluster $MASTER_IP $SLAVE_IP

pcs cluster setup --last_man_standing=1 --name pgcluster $MASTER_IP $SLAVE_IP

pcs cluster start --all

echo "pacemaker 配置结束!"
