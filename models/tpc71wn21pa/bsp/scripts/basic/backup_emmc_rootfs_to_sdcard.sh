#!/bin/sh

#check arg number
if [ $# != 1 ] && [ "$1"x != "dev/mmcblk0"x ];then
	echo "Usage: ./backup_emmc_rootfs_to_sdcard.sh /dev/mmcblk0."
	exit
fi

#check image file exist or not?
files=`ls ../image/`
if [ -z "$files" ]; then
	echo "There are no file in image folder."
	exit
fi

if [ -f "../image/ubuntu16044.tar.gz" ]; then
	ROOTFS_NAME="ubuntu16044.tar.gz"
elif [ -f "../image/yocto27.tar.gz" ]; then
	ROOTFS_NAME="yocto27.tar.gz"
else
	echo "There are no rootfs file in image folder."
	exit
fi

node=$1
#check if /dev/sdx exist?
if [ ! -e ${node} ]; then
	echo "There is no "${node}" in you system"
	exit
fi

# umount device
#umount ${node}* &> /dev/null
echo "[Backup Starting]"
echo "Delete old rootfs package..."
rm -rf ../image/${ROOTFS_NAME}
rm -rf  mount_point0
mkdir  mount_point0
mount ${node}p2 mount_point0/ &> /dev/null
sync


echo "Package new rootfs package..."
sync
cd  mount_point0/
tar --numeric-owner -zcpvf ../../image/${ROOTFS_NAME}  *  1>/dev/null
sync
cd  ../
sync
umount ${node}p2
rmdir mount_point0
echo "[Backup end]"
sync
