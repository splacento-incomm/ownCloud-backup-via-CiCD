#!/bin/bash
# By Sebastijan Placento 9a33bsp@gmail.com
# simple backup routine for Owncloud for easier backup (needed for colleges).
# Insert drive with uuid 57313b9d-2aef-4ddc-879f-a8b4b256c922
MOUNTPOINT=/mnt/ext
MOUNTDRIVE=/dev/sdc
UUID=57313b9d-2aef-4ddc-879f-a8b4b256c922
IS_DRIVE_AVAILABLE=$(lsblk -f | grep -wq "$UUID" && echo true || echo false)
OWNCLOUD_DB_PASS=$(sudo -u www-data php /var/www/owncloud/occ config:system:get dbpassword) #GET DB password

DATE=$(date --iso-8601)-$(hostname)
TARGET=$MOUNTPOINT/BorgBackup/backups
OWNCLOUDPATH=/var/www/owncloud

if ($IS_DRIVE_AVAILABLE)
then
	echo "Target drive found $MOUNTDRIVE. Will be mounted into MOUNTPOINT"
else
        echo "Aborting - NO DRIVE found!!!"
        echo "Please insert the drive first or check cables. HINT: blue light!"
        exit 1
fi

echo "Mounting drive…"
mount $MOUNTDRIVE $MOUNTPOINT
sleep 5

echo "Dumping database…"
mysqldump -u owncloud2 owncloud2 -p"$OWNCLOUD_DB_PASS" > $OWNCLOUDPATH/data/sys/db.sql

echo "Packing Owncloud system…"
tar czf  $OWNCLOUDPATH/data/sys/owncloud-sys.tgz $OWNCLOUDPATH --exclude=$OWNCLOUDPATH/data

echo "Starting creating BORG backup snapshot…"
borg create --stats --progress $TARGET::$DATE $OWNCLOUDPATH/data

echo "Umonting...."
umount $MOUNTPOINT

echo "Done!"
exit 0
