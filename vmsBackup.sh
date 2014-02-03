#!/bin/bash
# vmsBackup.sh 1.3
# Simple script to backup Xen (XCP) and XenServer Virtual Machines with snapshot
# Javier Morueco
# http://www.seavtec.com
#
# 1.3 : Added to remove disks that has NOBACKUP included in name-description (It could be configured in original VM, not SnapShot)
# 1.2 : Added to allow specified VM Backup, if name is as parameter
# 1.1 : Added that only BACKUP VMs with tag BACKUP
# 1.0 : Added workaround to remove Orphan VDIs on XenServer versions older than 5.6 (REMOVED)
# 0.9 : Base script to backup xen or xenserver vms with snapshot adding force to uninstall

TIMESTAMP=`date +%Y%m%d`
BACKUP="/backups"
HOST=`hostname -s`

# Delete old backups
rm -f ${BACKUP}/${HOST}/*.xva*

# Only get VMs that have BACKUP tag or VM NAME as parameter
if [ ! "$1" ]; then
	echo "`date +%Y%m%d_%H%M%S` Backup All VMs ..."
	VM_LIST=`xe vm-list tags:contains=BACKUP | grep "name-label" | grep -v "host:" | awk '{print $NF}' | sort | xargs`;
else
	echo "`date +%Y%m%d_%H%M%S` Backup VM $1 ..."
	VM_LIST="$1";
fi

# Create new backups
for VM_NAME in ${VM_LIST} ; do
	echo "START Time: `date +%Y%m%d_%H%M%S`"
	echo "Doing backup for ${VM_NAME}"
	echo "`date +%Y%m%d_%H%M%S` Creating Snapshot ..."
	SNAPUUID=`xe vm-snapshot vm=${VM_NAME} new-name-label=${VM_NAME}_${TIMESTAMP}`
	echo "`date +%Y%m%d_%H%M%S` Done."

	echo "`date +%Y%m%d_%H%M%S` Updating param ..."
	xe template-param-set is-a-template=false ha-always-run=false uuid=${SNAPUUID}
	echo "`date +%Y%m%d_%H%M%S` Done."

	# (VDI) Disks with NOBACKUP in name-description will be deleted
	echo "`date +%Y%m%d_%H%M%S` Deleting Disks with NOBACKUP ..."
	for VDI_UUID in $(xe vbd-list vm-uuid=${SNAPUUID} empty=false params=vdi-uuid | grep vdi-uuid | awk '{print $NF}'); do
		REMOVEVDI=$(xe vdi-param-get uuid=${VDI_UUID} param-name=name-description | grep -q NOBACKUP && echo 1 || echo 0)
		if [ "${REMOVEVDI}" -eq "1" ]; then
			echo "Deleting snapshot VDI : ${VDI_UUID}"
			xe vdi-destroy uuid=${VDI_UUID}
		fi
	done
	echo "`date +%Y%m%d_%H%M%S` Done."	
	echo "`date +%Y%m%d_%H%M%S` Exporting VM ..."
	xe vm-export vm=${SNAPUUID} filename=${BACKUP}/${HOST}/${VM_NAME}.snapbackup.${TIMESTAMP}.xva compress=true
	echo "`date +%Y%m%d_%H%M%S` Done."

	echo "`date +%Y%m%d_%H%M%S` Uninstalling Snapshot ..."
	xe snapshot-uninstall snapshot-uuid=${SNAPUUID} force=true
	echo "`date +%Y%m%d_%H%M%S` Done."
	echo "END Time: `date +%Y%m%d_%H%M%S`"
done
