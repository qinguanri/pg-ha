## 

if [ ! -f "ha.conf" ]; then
    echo "ERROR. cannot find ha.conf, please execute config.sh to generate."
    exit 1
fi

MASTER_IP=`cat ha.conf | grep MASTER_IP | awk -F '=' {'print $2'}`
SLAVE_IP=`cat ha.conf | grep SLAVE_IP | awk -F '=' {'print $2'}`

## 
hostname=`hostname -I`
hostname "$hostname"

# 
useradd postgres

echo "installing postgresql-server，please wait a minute ..."
yum install -y --disablerepo=\* --enablerepo=Local postgresql94-server postgresql94-contrib

cp -r /usr/pgsql-9.4/bin/* /usr/bin/
cp -r /usr/pgsql-9.4/lib/* /usr/lib/
cp -r /usr/pgsql-9.4/share/* /usr/share/

echo "installing pacemaker, please wait a minute ..."
yum install -y --disablerepo=\* --enablerepo=Pacemaker pacemaker pcs psmisc policycoreutils-python 

echo "install pacemaker ok, configing ..."

systemctl start pcsd.service
systemctl enable pcsd.service
echo hacluster | passwd hacluster --stdin

pcs cluster auth -u hacluster -p hacluster $MASTER_IP $SLAVE_IP

pcs cluster setup --last_man_standing=1 --name pgcluster $MASTER_IP $SLAVE_IP

pcs cluster start --all

echo "Done. pacemaker config ok"
