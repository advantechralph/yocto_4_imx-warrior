#!/bin/bash

ROOTFS_VERSION=$2

#check arg number
if [ $# -lt 1 ];then
    echo "Usage: ./mksd_recovery-linux.sh /dev/sdb [ubuntu16044]"
    exit
fi

if [ -f "../image/ubuntu16044.tar.gz" ] && [ x${ROOTFS_VERSION} != 'xubuntu16044' ]; then
    echo "Ubuntu image detected. Please run following cmd to burn SD:"
	echo "./mksd_recovery-linux.sh /dev/sdb ubuntu16044"
	exit 0
fi

# check the if root?
userid=`id -u`
if [ $userid -ne "0" ]; then
	echo "you're not root?"
	exit
fi

#check image file exist or not?
files=`ls ../image/`
if [ -z "$files" ]; then
	echo "There are no file in image folder."
	exit
fi

#avoid format my computer
if [ "$1" == "/dev/sda" ];then
	echo "cannot format your filesystem"
	exit
fi

node=$1
#check if /dev/sdx exist?
if [ ! -e ${node} ]; then
	echo "There is no "${node}" in you system"
	exit
fi

echo "All data on "${node}" now will be destroyed! Continue? [y/n]"
read ans
if [ $ans != 'y' ]; then exit 1; fi

# umount device
umount ${node}* &> /dev/null

# destroy the partition table
dd if=/dev/zero of=${node} bs=512 count=2 conv=fsync &> /dev/null;sync

#partition
echo "partition start"
SIZE=`fdisk -l ${node} | grep Disk | awk '{print $5}'`
echo DISK SIZE - $SIZE bytes
CYLINDERS=`echo $SIZE/255/63/512 | bc`

tmp=partitionfile
cs=$(fdisk -l ${node}| sed -n '4p'| cut -d ' ' -f 3)
if [ $cs == "cylinders" ];then
	echo u > $tmp
	echo n>> $tmp
else
	echo n > $tmp
fi
echo p >> $tmp
echo 1 >> $tmp
echo 20480 >> $tmp
echo +50M >> $tmp
echo n >> $tmp
echo p >> $tmp
echo 2 >> $tmp
echo 122880 >> $tmp
echo "" >> $tmp
echo t >> $tmp
echo 1 >> $tmp
echo b >> $tmp
echo w >> $tmp
fdisk ${node} < $tmp &> /dev/null
sync
rm $tmp

echo "partition done"
if [ -x /sbin/partprobe ]; then
	/sbin/partprobe ${node} &> /dev/null
else
	sleep 1
fi

sync
sync
echo "partition done"
# format filesystem
mkfs.vfat -F 32 -n "kernel" ${node}1
echo y | mkfs.ext4 -L "rootfs" ${node}2
sync
sync


# copy files
echo "dd [adv_boot & u-boot]"
dd if=../image/u-boot.imx of=${node} bs=512 seek=2 1>/dev/null 2>/dev/null;sync
#dd if=../image/u-boot_crc.bin.crc of=$1 bs=512 seek=2  1>/dev/null 2>/dev/null;sync
# 2M+512bytes
#dd if=../image/u-boot_crc.bin of=$1 bs=512 seek=3 1>/dev/null 2>/dev/null;sync
sync
sync

umount mount_point0 &> /dev/null
rm -fr mount_point0 &> /dev/null
mkdir mount_point0

if ! mount ${node}1 mount_point0 &> /dev/null; then 
	echo  "Cannot mount ${node}1"
	exit 1
fi
rm -fr mount_point0/*
echo "copy [zImage & dtb]"
cp -f ../image/zImage mount_point0/
cp -f ../image/*.dtb mount_point0/
if [ x${ROOTFS_VERSION} != 'xubuntu16044' ]; then
	echo "copy [EdgeLink ramdisk]"
	cp -arxf ../image/EdgeLink/ramdisk.gz mount_point0/
	cp -arxf ../image/EdgeLink/example-advupdate.txt mount_point0/
	cp -arxf ../image/EdgeLink/checksum.md5 mount_point0/
	sync
fi
sync

umount ${node}1
sync
sync
if ! mount ${node}2 mount_point0 &> /dev/null; then 
	echo  "Cannot mount ${node}2"
	exit 1
fi
rm -fr mount_point0/*
sync
echo "copy [rootfs]"
if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
	tar -zpxvf ../image/ubuntu16044.tar.gz -C mount_point0/ &> /dev/null
else 
	tar -zpxvf ../image/yocto21.tar.gz -C mount_point0/ &> /dev/null
fi
sync

if [ 1 -eq 1 ];then
# for emmc update usage
    echo "[Copying iNAND upgrate tools...]"
    mkdir mount_point0/mk_inand &> /dev/null
    mkdir mount_point0/mk_inand/image
    mkdir mount_point0/mk_inand/scripts

	# copy boot file
    cp -a mac_write* etp_write mtd_debug flash_erase mkspi-advboot.sh Factory-linux.sh Factory-final.sh touch_fa.sh touch_ecc.sh mkinand-linux.sh hostname_write.sh mount_point0/mk_inand/scripts/
    cp -a ../image/*.bmp ../image/SPL ../image/u-boot* ../image/zImage ../image/*.dtb mount_point0/mk_inand/image/
	#cp -a ../image/8111g-cfg mount_point0/mk_inand/

	# copy rootfs
	if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
    	cp -arxf ../image/ubuntu16044.tar.gz mount_point0/mk_inand/image/
	else
		cp -arxf ../image/yocto21.tar.gz mount_point0/mk_inand/image/
		# copy EdgeLink file
    	cp -arxf ../image/EdgeLink mount_point0/mk_inand/image/
	fi
    chown -R 0.0 mount_point0/mk_inand/*
	if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
		chown -R 1000.1000 mount_point0/home/advantech
	fi
fi

sync
umount ${node}*
sync
rmdir mount_point0
sync

