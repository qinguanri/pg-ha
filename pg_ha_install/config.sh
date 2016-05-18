# 做一些安装前的准备工作：
# （1）检查安装文件是否齐全
# （2）修改配置文件ha.conf

## pg 双机热备安装文件存放目录
SRC_DIR="/root/pg_ha_install"

## pg 双机热备所需脚本
CONFIG_SH="config.sh"      
OPEN_PORT_SH="open_port.sh"
CREATE_REPO_SH="create_repo.sh"
INSTALL_PACEMAKER_SH="install_pacemacker.sh"
INSTALL_PG_MASTER_SH="install_pg_master.sh"
INSTALL_PG_SLAVE_SH="install_pg_slave.sh"
AUTO_CHANGE_SH="auto_change.sh"
CHECK_PG_SH="check_pg.sh"
COME_OVER_SH="come_over.sh"

## 
YUM_TAR="yum.tar"
YUM_PCMK_TAR="yum_pacemaker.tar"

cd SRC_DIR

echo "检查安装文件是否正确 ..."

if [ ! -f "$SRC_DIR/$CONFIG_SH" ] || [ ! -f "$SRC_DIR/$OPEN_PORT_SH" ] \
    || [ ! -f "$SRC_DIR/$CREATE_REPO_SH" ] || [ ! -f "$SRC_DIR/$INSTALL_PACEMAKER_SH"] \
    || [ ! -f "$SRC_DIR/$INSTALL_PG_MASTER_SH" ] || [ ! -f "$SRC_DIR/$INSTALL_PG_SLAVE_SH" ] \
    || [ ! -f "$SRC_DIR/$AUTO_CHANGE_SH" ] || [ ! -f "$SRC_DIR/$CHECK_PG_SH" ] \
    || [ ! -f "$SRC_DIR/$COME_OVER_SH" ] || [ ! -f "$SRC_DIR/$YUM_TAR" ] \
    || [ ! -f "$SRC_DIR/$YUM_PCMK_TAR" ]; then
    echo "ERROR. 缺少文件。请将安装包上传到目录$SRC_DIR"
    exit 1
fi

chmod +x "$SRC_DIR/*.sh"

rm ha.conf

MASTER_IP=$1
SLAVE_IP=$2
VIP_PG_MASTER=$3
VIP_PG_SLAVE=$4
NET=$5
PG_DIR=$6

MASTER_IP_valid=`echo $MASTER_IP |grep MASTER_IP | wc -l`
SLAVE_IP_valid=`echo $SLAVE_IP | grep SLAVE_IP | wc -l`
VIP_PG_MASTER_valid=`echo $VIP_PG_MASTER | grep VIP_PG_MASTER |wc -l`
VIP_PG_SLAVE_valid=`echo $VIP_PG_SLAVE | grep VIP_PG_SLAVE |wc -l`
NET_valid=`echo $NET | grep NET| wc -l`
PG_DIR_valid=`echo $PG_DIR|grep PG_DIR |wc -l`

MASTER_IP_valid=`echo $MASTER_IP_valid`
SLAVE_IP_valid=`echo $SLAVE_IP_valid`
VIP_PG_MASTER_valid=`echo $VIP_PG_MASTER_valid`
VIP_PG_SLAVE_valid=`echo $VIP_PG_SLAVE_valid`
NET_valid=`echo $NET_valid`
PG_DIR_valid=`echo $PG_DIR_valid`

if [ "$MASTER_IP_valid" == "1" ] && [ "$SLAVE_IP_valid" == "1" ] \
    && [ "$VIP_PG_MASTER_valid" == "1" ] && [ "$VIP_PG_SLAVE_valid" == "1" ] \
    && [ "$NET_valid" == "1" ] && [ "$PG_DIR_valid" == "1" ]; then
    echo "$MASTER_IP
$SLAVE_IP
$VIP_PG_MASTER
$VIP_PG_SLAVE
$NET
$PG_DIR" > ha.conf

else
    echo "$MASTER_IP_valid"
    echo "ERROR. 参数错误"
    echo "usage:"
    echo "     ./config.sh MASTER_IP=1.2.3.4 SLAVE_IP=1.2.3.5 VIP_PG_MASTER=1.2.3.6 VIP_PG_SLAVE=1.2.3.7 NET=1.2.0.0/16 PG_DIR=/data/postgresql"
fi
