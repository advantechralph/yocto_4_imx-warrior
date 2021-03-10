#!/bin/bash

 if [ $# -lt 1 ];then
    echo "Usage: $0 <Mac_addr> [ubuntu16044]"
    echo "       $0 AUTOMAC [ubuntu16044]"
	echo "MACADDR like: AA:BB:CC:DD:EE:FF"
	echo "AUTOMAC will use current system mac address."
	exit
 fi

if [  "$1" = "AUTOMAC" ]; then
    MACADDR=`ifconfig |grep HWaddr |grep -v eth0:0 |grep -o ..:..:..:..:..:.. |awk 'NR==1 {print}'`
else
    MACADDR=$1
fi

ROOTFS_VERSION=$2

# write eMMC file system
if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
	./mkinand-linux.sh /dev/mmcblk0 ubuntu16044
else
	./mkinand-linux.sh /dev/mmcblk0
fi

# write SPL
./mkspi-advboot.sh

# write MAC addr
echo "Write mac address: $MACADDR"
./mac_write_linux $MACADDR

# write hostname
./hostname_write.sh $MACADDR

