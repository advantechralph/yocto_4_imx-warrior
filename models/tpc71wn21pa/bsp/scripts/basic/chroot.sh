#!/bin/bash

scriptpath=$(realpath -m ${BASH_SOURCE[0]})
scriptdir=$(dirname $scriptpath)
rootfsdir=$(realpath -m ${scriptdir}/../rootfs)
qemustatic=$rootfsdir/usr/bin/qemu-arm-static

if [ ! -e "$rootfsdir" ]; then
  echo rootfsdir not exists!!
  exit 1; 
fi

: << 'commentend'
printf "%20s : %20s\n" "scriptpath" "$scriptpath"
printf "%20s : %20s\n" "scriptdir" "$scriptdir"
printf "%20s : %20s\n" "rootfsdir" "$rootfsdir"
[ -e "$qemustatic" ] && echo "$qemustatic exists!!" || echo "$qemustatic not exists!!" 
exit 0; 
commentend

: << 'commentend'
chkmountpoint()
  $1: directory to check
return: 
  0: mointed, 1: not mounted
ex: 
  [ "$(chkmountpoint /proc)" -eq 0 ] && echo mounted!!
  chkmountpoint $rootfsdir/proc
commentend
chkmountpoint(){
  mountpoint -q $1
  echo $?
}

: << 'commentend'
1. Check if proc, sys, dev/pts, dev are mount points. 
   If yes, umount it and mount it again.  
2. Check if qemu static bin file exists in usr/bin/. 
   If not, script exits. 
3. 
commentend

dirs="proc sys dev/pts dev"
for d in $dirs; do 
  _d=$rootfsdir/$d
  if [ "$(chkmountpoint $_d)" -eq 0 ] ; then 
    echo "$d: mounted!!"; 
    umount $_d; 
    echo "umount $d"; 
  fi
done

[ "$1" == "umount" ] && exit 0

mount -o bind /dev $rootfsdir/dev
mount -o bind /dev/pts $rootfsdir/dev/pts
mount -t proc proc $rootfsdir/proc
mount -t sysfs sys $rootfsdir/sys

if [ ! -e "$qemustatic" ] ; then
  echo "$qemustatic not exists!!" 
  exit 1 
fi

chroot $rootfsdir
