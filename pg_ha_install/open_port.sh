
firewall_run=`ps -ef | grep firewalld|grep -v grep|wc -l`
firewall_run=`echo $firewall_run`

if [ "$firewall_run" == "0" ]; then
	echo "ERROR.  firewalld has not open"
else
	setenforce 0

	sed -i.bak "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config

	firewall-cmd --add-port 22/tcp
	firewall-cmd --add-port 5432/tcp
	firewall-cmd --add-port 55284/tcp
	firewall-cmd --add-port 2224/tcp
	firewall-cmd --add-port 21/tcp
	firewall-cmd --add-port 25/tcp
	firewall-cmd --add-port 60403/tcp

	firewall-cmd --add-port 48294/udp
	firewall-cmd --add-port 5405/udp
	firewall-cmd --add-port 53055/udp
	firewall-cmd --add-port 323/udp
	firewall-cmd --add-port 60801/udp
	firewall-cmd --add-port 27103/udp
	firewall-cmd --add-port 39458/udp
	firewall-cmd --add-port 68/udp
	firewall-cmd --add-port 35525/udp
	firewall-cmd --add-port 61447/udp
	firewall-cmd --add-port 5859/udp
	firewall-cmd --add-port 38150/udp
	firewall-cmd --add-port 36135/udp
	firewall-cmd --add-port 54705/udp
	firewall-cmd --add-port 43639/udp
	firewall-cmd --add-port 34979/udp
	firewall-cmd --add-port 42772/udp

	echo "Done"
fi
