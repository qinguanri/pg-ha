
firewall_run=`ps -ef | grep firewalld|grep -v grep|wc -l`
firewall_run=`echo $firewall_run`

if [ "$firewall_run" == "0" ]; then
    echo "ERROR.  firewalld has not open"
    exit 1
else
    setenforce 0

    sed -i.bak "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config

    echo "systemctl stop firewalld.service ..."
    systemctl stop firewalld.service
    echo "systemctl start firewalld.service ..."
    systemctl start firewalld.service

    firewall-cmd --add-port 22/tcp  --permanent
    firewall-cmd --add-port 5432/tcp --permanent
    firewall-cmd --add-port 55284/tcp --permanent
    firewall-cmd --add-port 2224/tcp --permanent
    firewall-cmd --add-port 21/tcp --permanent
    firewall-cmd --add-port 25/tcp --permanent
    firewall-cmd --add-port 60403/tcp --permanent

    firewall-cmd --add-port 48294/udp --permanent
    firewall-cmd --add-port 5405/udp --permanent
    firewall-cmd --add-port 53055/udp --permanent
    firewall-cmd --add-port 323/udp --permanent
    firewall-cmd --add-port 60801/udp --permanent
    firewall-cmd --add-port 27103/udp --permanent
    firewall-cmd --add-port 39458/udp --permanent
    firewall-cmd --add-port 68/udp --permanent
    firewall-cmd --add-port 35525/udp --permanent
    firewall-cmd --add-port 61447/udp --permanent
    firewall-cmd --add-port 5859/udp --permanent
    firewall-cmd --add-port 38150/udp --permanent
    firewall-cmd --add-port 36135/udp --permanent
    firewall-cmd --add-port 54705/udp --permanent
    firewall-cmd --add-port 43639/udp --permanent
    firewall-cmd --add-port 34979/udp --permanent
    firewall-cmd --add-port 42772/udp --permanent
fi

PG_PORT_OPEN=`firewall-cmd --list-all | grep ports | grep / | grep 5432 | wc -l`
PCMK_PORT_OPEN=`firewall-cmd --list-all | grep ports | grep / | grep 5405| wc -l`
COROSYNC_PORT_OPEN=`firewall-cmd  --list-all | grep ports | grep / | grep 323 | wc -l`

## check some important ports
if [ "$PG_PORT_OPEN" == "0" ] || [ "$PCMK_PORT_OPEN" == "0" ] || [ "$COROSYNC_PORT_OPEN" == "0" ]; then
    echo "ERROR. Open ports failed. Please try again."
    firewall-cmd --list-all
    exit 1
fi

echo "Done."
