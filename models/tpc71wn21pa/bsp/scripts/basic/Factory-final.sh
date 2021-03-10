#!/bin/bash

 if [ $# -lt 3 ];then
    echo "Usage: $0 AUTOMAC <DeviceName> <SNCode> [ubuntu16044]"
	echo "AUTOMAC will use current system mac address."
	exit
 fi

if [ "x$1" = "xAUTOMAC" ]; then
    MACADDR=`ifconfig |grep HWaddr |grep -v eth0:0 |grep -o ..:..:..:..:..:..`
	DEVICENAME=$2
	SNCODE=$3
	UUID=`/usr/bin/uuidgen`
	ROOTFS_VERSION=$4
else
	echo "Error !"
	exit
fi

<< !
# write eMMC file system
if [ x${ROOTFS_VERSION} = 'xubuntu16044' ]; then
	./mkinand-linux.sh /dev/mmcblk0 ubuntu16044
else
	./mkinand-linux.sh /dev/mmcblk0
fi

# write SPL
./mkspi-advboot.sh
!

# write MAC addr
echo "Write mac address: $MACADDR"
./mac_write_linux $MACADDR

# write board info
echo "Write board info:"
echo "  - DEVICENAME: $DEVICENAME"
echo "  - SNCODE: $SNCODE"
echo "  - UUID: $UUID"
./etp_write $DEVICENAME $SNCODE $UUID
./touch_fa.sh $DEVICENAME $MACADDR $SNCODE
./touch_ecc.sh linux

# write hostname
./hostname_write.sh $MACADDR

