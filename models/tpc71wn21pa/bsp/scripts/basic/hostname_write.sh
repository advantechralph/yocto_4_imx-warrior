#!/bin/bash

mkdir mount_rootfs
sync
mount /dev/mmcblk0p2 mount_rootfs

HOSTNAME=`cat mount_rootfs/etc/hostname`
MACADDR=$1
MACTAIL=`echo $MACADDR |sed 's/://g'`
MACTAIL=${MACTAIL:0-4:4}
HOSTNAME="${HOSTNAME}-${MACTAIL}"

#echo ${HOSTNAME}
echo ${HOSTNAME} > mount_rootfs/etc/hostname
sync

umount mount_rootfs
sync
rmdir mount_rootfs
