#!/bin/sh

if [ ! -f ${CONFFILE} ]
  then
    echo "AccountID ${AccountID}" > ${CONFFILE}
    echo "LicenseKey ${LicenseKey}" >> ${CONFFILE}
    echo "EditionIDs ${EditionIDs}" >> ${CONFFILE}
    echo "DatabaseDirectory ${DatabaseDirectory}" >> ${CONFFILE}
    echo "PreserveFileTimes ${PreserveFileTimes}" >> $CONFFILE
    echo "LockFile ${LockFile}" >> $CONFFILE
    if [ -n "${Proxy}" ]; then
        echo "Proxy ${Proxy}" >> $CONFFILE
    fi
    if [ -n "${ProxyUserPassword}" ]; then
        echo "ProxyUserPassword ${ProxyUserPassword}" >> $CONFFILE
    fi
  else
    DatabaseDirectory=$(grep ^DatabaseDirectory ${CONFFILE} | awk '{print $2}')
fi

mkdir -p ${DatabaseDirectory}
geoipupdate -f ${CONFFILE} -v
chown geoip:geoip -R ${DatabaseDirectory}

echo -e "${CRON_SCHEDULE} geoipupdate -f ${CONFFILE}\n" > /var/spool/cron/crontabs/geoip
chown geoip:geoip /var/spool/cron/crontabs/geoip

exec "$@"