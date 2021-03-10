#!/bin/bash

function cmd_kill() {
	sleep 2
	flag=true
	while $flag
	do
		sleep 1
		procnum=`ps -ef |grep "cmd-processor" |grep -v grep |wc -l`
		if [ $procnum -ne 0 ]; then
			killall cmd-processor
			flag=false
		fi
	done
}

mkdir mount_kernel
sync
mount /dev/mmcblk1p1 mount_kernel

if [ ! -d "mount_kernel/factory_burnin" ]; then
	mkdir mount_kernel/factory_burnin
fi

tmp=geteccinfo
info=eccinfo
if [ "x$1" = "xfinal" ]; then
	ECCNUM=`ls -l mount_kernel/factory_burnin |grep "^-" |grep ecc-final |grep ".txt" |wc -l`
	FILENAME=ecc-final${ECCNUM}.txt
	
	echo 508 > $tmp
	echo sernum >> $tmp
	{
		cmd_kill 
	} &
	cmd-processor ${node} < $tmp &> $info
	sync

	SERIALNUM=`sed -n '6p' $info |awk '{sub(/.$/,"")}1'`
	SIGPUBKEY=
	SIGCERT=
	DEVPUBKEY=
	DEVCERT=
	XFZN=
elif [ "x$1" = "xlinux" ]; then
	ECCNUM=`ls -l mount_kernel/factory_burnin |grep "^-" |grep ecc-linux |grep ".txt" |wc -l`
	FILENAME=ecc-linux${ECCNUM}.txt

	echo 508 > $tmp
	echo sernum >> $tmp
	{
		cmd_kill 
	} &
	cmd-processor ${node} < $tmp &> $info
	sync

	SERIALNUM=`sed -n '6p' $info |awk '{sub(/.$/,"")}1'`
	SIGPUBKEY=
	SIGCERT=
	DEVPUBKEY=
	DEVCERT=
	XFZN=
else
	ECCNUM="-error"
	FILENAME=ecc-final${ECCNUM}.txt
	echo "Usage: $0 linux|final"
fi
rm $tmp
rm $info

echo "{" > mount_kernel/factory_burnin/${FILENAME}
echo "	\"SerialNumber\": \"$SERIALNUM\"" >> mount_kernel/factory_burnin/${FILENAME}
echo "	\"SignerPublicKey\": \"$SIGPUBKEY\"" >> mount_kernel/factory_burnin/${FILENAME}
echo "	\"SignerCert\": \"$SIGCERT\"" >> mount_kernel/factory_burnin/${FILENAME}
echo "	\"DevicePublicKey\": \"$DEVPUBKEY\"" >> mount_kernel/factory_burnin/${FILENAME}
echo "	\"DeviceCert\": \"$DEVCERT\"" >> mount_kernel/factory_burnin/${FILENAME}
echo "	\"X.509\": \"$XFZN\"" >> mount_kernel/factory_burnin/${FILENAME}
echo "}" >> mount_kernel/factory_burnin/${FILENAME}
sync

umount mount_kernel
sync
rmdir mount_kernel

wait

