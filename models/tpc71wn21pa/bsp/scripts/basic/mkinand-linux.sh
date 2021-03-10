#!/bin/bash

ROOTFS_VERSION=$2

#check arg number
if [ $# -lt 1 ];then
    echo "Usage: ./mkinand-linux.sh /dev/mmcblk0 [ubuntu16044]"
    exit
fi

if [ -f "../image/ubuntu16044.tar.gz" ] && [ x${ROOTFS_VERSION} != 'xubuntu16044' ]; then
    echo "Ubuntu image detected. Please run following cmd to burn SD:"
    echo "./mkinand-linux.sh /dev/mmcblk0 ubuntu16044"
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

node=$1
#check if /dev/sdx exist?
if [ ! -e ${node} ]; then
echo "There is no "${node}" in you system"
exit
fi

#do not ask
#echo "All data on "${node}" now will be destroyed! Continue? [y/n]"
#read ans
#if [ $ans != 'y' ]; then exit 1; fi

if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
    filesystem=../image/ubuntu16044.tar.gz
else 
    filesystem=../image/yocto27.tar.gz
fi
if [ ! -f "$filesystem" ]; then
    echo "There is no "$2" in image folder."
    exit 0
fi

# umount device
umount ${node}* &> /dev/null

# destroy the partition table
dd if=/dev/zero of=${node} bs=512 count=2 &> /dev/null;sync

#partition
echo "partition start"
if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
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
else 
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
echo +2.5G >> $tmp
echo n >> $tmp
echo p >> $tmp
echo 3 >> $tmp
echo 5341184 >> $tmp
echo +900M >> $tmp
echo n >> $tmp
echo p >> $tmp
echo 7184384 >> $tmp
echo "" >> $tmp
echo t >> $tmp
echo 1 >> $tmp
echo b >> $tmp
echo w >> $tmp
fdisk ${node} < $tmp &> /dev/null
sync
rm $tmp
fi
sync
partprobe
sync
echo "partition done"

sleep 5

# format filesystem
umount ${node}p1 &> /dev/null
#mkfs.vfat -F 32 -n "kernel" ${node}p1
mkfs.vfat ${node}p1
sync
umount ${node}p2 &> /dev/null
echo y | mkfs.ext4 -L "rootfs" ${node}p2
sync
if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
    echo "Not support recovery / data area."
else
umount ${node}p3 &> /dev/null
echo y | mkfs.ext4 -L "recovery" ${node}p3
sync
umount ${node}p4 &> /dev/null
echo y | mkfs.ext4 -L "data" ${node}p4
sync
fi

# copy files
echo "dd [u-boot]"
#This is diffrent from mksd_*.sh
dd if=../image/u-boot_crc.bin.crc of=${node} bs=512 seek=2  &> /dev/null;sync
dd if=../image/u-boot_crc.bin of=${node} bs=512 seek=3 &> /dev/null;sync
sync

echo "dd [logo]"
LOGOPATH=`ls ../image/*.bmp`
dd if=/dev/zero of=${node} bs=1 count=5242880 seek=1048576
dd if=${LOGOPATH} of=${node} bs=1 seek=1048576 skip=54
sync

rm -rf mount_point0
mkdir mount_point0
umount ${node}* &> /dev/null
mount ${node}p1 mount_point0/ &> /dev/null
rm -rf mount_point0/*
echo "copy [zImage & dtb]"
cp -arxf ../image/zImage mount_point0/
cp -arxf ../image/*.dtb mount_point0/
sync
umount ${node}p1

umount ${node}* &> /dev/null
mount ${node}p2 mount_point0/ &> /dev/null
rm -rf mount_point0/*
echo "copy [rootfs]"
if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
    tar -zpxvf ../image/ubuntu16044.tar.gz -C mount_point0/ &> /dev/null
else
    tar -zpxvf ../image/yocto27.tar.gz -C mount_point0/ &> /dev/null
    #cp -arxf ../image/rootfs/* mount_point0/ &> /dev/null
fi
sync
umount ${node}p2

umount ${node}* &> /dev/null
if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
    echo "Not support recovery / data area."
else
mount ${node}p3 mount_point0/ &> /dev/null
rm -rf mount_point0/*
echo "copy [recovery files]"
echo "copy rootfs ..."
if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
    cp -arxf ../image/ubuntu16044.tar.gz mount_point0/rootfs.tar.gz &> /dev/null
else
    cp -arxf ../image/yocto27.tar.gz mount_point0/rootfs.tar.gz &> /dev/null
fi
sync
echo "copy SPL ..."
cp -arxf ../image/SPL mount_point0/ &> /dev/null 
echo "copy u-boot ..."
cp -arxf ../image/u-boot_crc* mount_point0/ &> /dev/null 
echo "copy kernel ..."
cp -arxf ../image/*.dtb mount_point0/ &> /dev/null 
cp -arxf ../image/zImage mount_point0/ &> /dev/null 
if [ x${ROOTFS_VERSION} != 'xubuntu16044' ]; then
    echo "copy ramdisk ..."
    cp -arxf ../image/EdgeLink/ramdisk.gz mount_point0/ &> /dev/null 
    cp -arxf ../image/EdgeLink/example-advupdate.txt mount_point0/ &> /dev/null 
    cp -arxf ../image/EdgeLink/checksum.md5 mount_point0/ &> /dev/null 
    cp -arxf ../image/EdgeLink/apps.tar.gz mount_point0/ &> /dev/null 
    cp -arxf ../image/EdgeLink/manifest.xml mount_point0/ &> /dev/null 
fi
echo "copy logo ..."
cp -arxf ../image/adv_logo_*.bmp mount_point0/ &> /dev/null 
echo "create uploads dir ..."
mkdir mount_point0/uploads &> /dev/null
chown -h sysuser:sysuser mount_point0/uploads
sync
umount ${node}p3
fi

umount ${node}* &> /dev/null
echo "create sysuser"
if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
    echo "Ubuntu img detected."
    echo "Skip EdgeLink updte."
else
    echo "Yocto img detected."
    mount ${node}p4 mount_point0/ &> /dev/null
    rm -rf mount_point0/*
    mkdir mount_point0/root &> /dev/null
    chown -h root:root mount_point0/root
    mkdir mount_point0/sysuser &> /dev/null
    chown -h sysuser:sysuser mount_point0/sysuser
    if [ -f "/mk_inand/image/EdgeLink/apps.tar.gz" ]; then
        echo "update edgelink applications"
        [ -d mount_point0/sysuser/bin ] && rm -rf mount_point0/sysuser/bin
        [ -d mount_point0/sysuser/driver ] && rm -rf mount_point0/sysuser/driver
        [ -d mount_point0/sysuser/lib ] && rm -rf mount_point0/sysuser/lib
        [ -d mount_point0/sysuser/project ] && rm -rf mount_point0/sysuser/project
        [ -d mount_point0/sysuser/update ] && rm -rf mount_point0/sysuser/update
        [ -d mount_point0/sysuser/user ] && rm -rf mount_point0/sysuser/user
        [ -d mount_point0/sysuser/util ] && rm -rf mount_point0/sysuser/util
        [ -d mount_point0/sysuser/www ] && rm -rf mount_point0/sysuser/www
        [ -d mount_point0/sysuser/doc ] && rm -rf mount_point0/sysuser/doc
        [ -d mount_point0/sysuser/inc ] && rm -rf mount_point0/sysuser/inc
        tar -zxpf /mk_inand/image/EdgeLink/apps.tar.gz -C mount_point0/sysuser/
        sync;sync;sleep 2
    fi
    sync
    umount ${node}p4
fi

rmdir mount_point0
sync




