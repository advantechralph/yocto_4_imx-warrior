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
elif [ -f "../image/yocto21.tar.gz" ]; then
	ROOTFS_NAME="yocto21.tar.gz"
else
	echo "There are no rootfs file in image folder."
	exit
fi

if [ -f "../image/EdgeLink/apps.tar.gz" ]; then
	APP_NAME="apps.tar.gz"
else
	echo "There are no apps file in EdgeLink folder."
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
echo "[Backup Rootfs Starting]"
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
echo "[Backup Rootfs end]"
sync

# umount device
umount ${node}p4 &> /dev/null
echo "[Backup app Starting]"
echo "Delete old apps package..."
rm -rf ../image/EdgeLink/${APP_NAME}
rm -rf  mount_point0
mkdir  mount_point0
mount ${node}p4 mount_point0/ &> /dev/null
sync


echo "Package new apps package..."
sync
cd  mount_point0/sysuser/
tar --numeric-owner -zcpvf ../../../image/EdgeLink/${APP_NAME}  *  1>/dev/null
sync
cd  ../
sync
cd ../
sync
umount ${node}p4
rmdir mount_point0
rm -rf mount_point0
echo "[Backup apps end]"

echo "auto check md5sum"
cd /mk_inand
mkdir update
cd /mk_inand/image/EdgeLink
cp apps.tar.gz ramdisk.gz manifest.xml advupdate.txt encdec ../../update
rm checksum.md5
cd ../
cp yocto21.tar.gz *.bmp SPL u-boot_crc.bin u-boot_crc.bin.crc *.dtb zImage ../update
cd ../update
mv yocto21.tar.gz rootfs.tar.gz
md5sum *.bmp > checksum.md5.d
md5sum SPL >> checksum.md5.d
md5sum u-boot_crc.bin >> checksum.md5.d
md5sum u-boot_crc.bin.crc >> checksum.md5.d
md5sum *.dtb >> checksum.md5.d
md5sum zImage >> checksum.md5.d
md5sum ramdisk.gz >> checksum.md5.d
md5sum rootfs.tar.gz >> checksum.md5.d
md5sum apps.tar.gz >> checksum.md5.d
md5sum manifest.xml >> checksum.md5.d
encdec -e checksum.md5.d checksum.md5
rm checksum.md5.d
echo "auto check md5sum end"

echo "Generate advupdate.txt"

sync
