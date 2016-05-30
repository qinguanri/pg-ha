## set hostname with IP
HOSTNAME=`hostname -I`
hostname "$HOSTNAME"

rm -rf /var/lib/pgsql/tmp/PGSQL.lock

echo "systemctl stop pacemaker.service..."
systemctl stop pacemaker.service

echo "systemctl start pacemaker.service..."
systemctl start pacemaker.service

echo 'starting pg service. please wait about one minute ...'

## pg restart service may take minutes. so we sleep here to wait pg start normally.
sleep 60

## check pg status
IS_LATEST=`crm_mon -Afr -1|grep LATEST | wc -l`

if [ "$IS_LATEST" == "1" ] ; then
    echo "OK. PG service ok"
else
    echo "ERROR. pg service has not started."
    echo "Please wait minutes then execute check_pg.sh to check pg service status again."
fi
