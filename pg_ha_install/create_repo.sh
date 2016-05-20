## create repo

pg_rpm="yum.tar"
pcmk_rpm="yum_pacemaker.tar"

if [ ! -f "$pg_rpm" ]; then
	echo "ERROR。 cannot find files：", "$pg_rpm"
	exit 1
fi

if [ ! -f "$pcmk_rpm" ]; then
	echo "ERROR. cannot find files：", "$pcmk_rpm"
	exit 1
fi

cp $pg_rpm /
cp $pcmk_rpm /

cd /

tar xvf "$pg_rpm"
tar xvf "$pcmk_rpm"

echo "[Local]
name=Local Yum
baseurl=file:///yum/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/CentOS-Local.repo

echo "[Pacemaker]
name=Pacemaker Yum
baseurl=file:///yum_pacemaker/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/CentOS-Pacemaker.repo

echo "Done! create repo ok."