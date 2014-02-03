#!/bin/bash
# metaBackup.sh 1.0
# Simple script to backup Metadata on Xen (XCP) and XenServer
# Javier Morueco
# http://www.seavtec.com
#

TIMESTAMP=`date +%Y%m%d`
BACKUP="/backups"
HOST=`hostname -s`

#Delete old backups
rm -f ${BACKUP}/${HOST}/${HOST}.metadata.*

#Create backup
mkdir -p ${BACKUP}/${HOST}
xe pool-dump-database file-name=${BACKUP}/${HOST}/${HOST}.metadata.${TIMESTAMP}
