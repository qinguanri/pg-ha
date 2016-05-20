

## pg 
SRC_DIR="/root/pg_ha_install"

## 
CONFIG_SH="config.sh"      
OPEN_PORT_SH="open_port.sh"
CREATE_REPO_SH="create_repo.sh"
INSTALL_PACEMAKER_SH="install_pacemaker.sh"
INSTALL_PG_MASTER_SH="install_pg_master.sh"
INSTALL_PG_SLAVE_SH="install_pg_slave.sh"
AUTO_CHANGE_SH="auto_change.sh"
CHECK_PG_SH="check_pg.sh"
COME_OVER_SH="come_over.sh"

## 
YUM_TAR="yum.tar"
YUM_PCMK_TAR="yum_pacemaker.tar"

cd $SRC_DIR

echo "check files..."

exsit_1=`ls $SRC_DIR/$CONFIG_SH|wc -l`
exsit_2=`ls $SRC_DIR/$OPEN_PORT_SH|wc -l`
exsit_3=`ls $SRC_DIR/$CREATE_REPO_SH|wc -l`
exsit_4=`ls $SRC_DIR/$INSTALL_PACEMAKER_SH|wc -l`
exsit_5=`ls $SRC_DIR/$INSTALL_PG_MASTER_SH|wc -l`
exsit_6=`ls $SRC_DIR/$INSTALL_PG_SLAVE_SH|wc -l`
exsit_7=`ls $SRC_DIR/$AUTO_CHANGE_SH|wc -l`
exsit_8=`ls $SRC_DIR/$CHECK_PG_SH|wc -l`
exsit_9=`ls $SRC_DIR/$COME_OVER_SH|wc -l`
exsit_10=`ls $SRC_DIR/$YUM_TAR|wc -l`
exsit_11=`ls $SRC_DIR/$YUM_PCMK_TAR|wc -l`


if [ "$exsit_1" != "1" ] || [ "$exsit_2" != "1" ] || [ "$exsit_3" != "1" ] \
    || [ "$exsit_4" != "1" ] || [ "$exsit_5" != "1" ] || [ "$exsit_6" != "1" ] \
    || [ "$exsit_7" != "1" ] || [ "$exsit_8" != "1" ] || [ "$exsit_9" != "1" ] \
    || [ "$exsit_10" != "1" ] || [ "$exsit_11" != "1" ]; then
    echo "ERROR. some files cannot found. $SRC_DIR"
    echo "$exsit_1", "$exsit_2", "$exsit_3"
    echo "$exsit_4", "$exsit_5", "$exsit_6"
    echo "$exsit_7", "$exsit_8", "$exsit_9"
    echo "$exsit_10", "$exsit_11"
    exit 1
fi

chmod +x $SRC_DIR/*.sh

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
    echo "ERROR. args error"
    echo "usage:"
    echo "     ./config.sh MASTER_IP=1.2.3.4 SLAVE_IP=1.2.3.5 VIP_PG_MASTER=1.2.3.6 VIP_PG_SLAVE=1.2.3.7 NET=1.2.0.0/16 PG_DIR=/data/postgresql"
fi

echo "OK. you can do next step now."