#!/bin/bash
# hostBackup.sh 1.0
# Simple script to backup Host Xen (XCP) and XenServer
# Javier Morueco
# http://www.seavtec.com
#

TIMESTAMP=`date +%Y%m%d`
BACKUP="/backups"
HOST=`hostname -s`
HOSTNAME=`hostname`

#Delete old backups
rm -f ${BACKUP}/${HOST}/${HOST}.host.*

#Create backup
mkdir -p ${BACKUP}/${HOST}
xe host-backup hostname=${HOSTNAME} file-name=${BACKUP}/${HOST}/${HOST}.host.${TIMESTAMP}

