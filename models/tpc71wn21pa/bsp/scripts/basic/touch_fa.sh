#!/bin/bash

MODULENAME=$1
MACADDRESS=$2
SERIALNUM=$3

mkdir mount_kernel
sync
mount /dev/mmcblk1p1 mount_kernel

if [ ! -d "mount_kernel/factory_burnin" ]; then
	mkdir mount_kernel/factory_burnin
fi

FANUM=`ls -l mount_kernel/factory_burnin |grep "^-" |grep fa |grep ".txt" |wc -l`
FILENAME=fa${FANUM}.txt

echo "{" > mount_kernel/factory_burnin/${FILENAME}
echo "	\"ModuleName\": \"$MODULENAME\"" >> mount_kernel/factory_burnin/${FILENAME}
echo "	\"MacAddress\": \"$MACADDRESS\"" >> mount_kernel/factory_burnin/${FILENAME}
echo "	\"SerialNumber\": \"$SERIALNUM\"" >> mount_kernel/factory_burnin/${FILENAME}
echo "}" >> mount_kernel/factory_burnin/${FILENAME}
sync

umount mount_kernel
sync
rmdir mount_kernel
