#!/bin/bash

apptool=./ztool
module_dir=../cdev

die()
{
	echo $@
	exit 1
}

check_permission()
{
	if [ $EUID != 0 ]; then
		echo "Operation not permitted! Prefix \"sudo\" then try again"
		exit 1
	fi
}

check_apptool()
{
	if [ ! -e $apptool ]; then
		echo "$apptool no exist"
		echo 1
	fi
}

check_module()
{
	current_dir=`pwd`
	cd $module_dir
	if ! sudo ./install; then
		exit 1
	fi
	cd $current_dir
}

remove_module()
{
	rmmod shannon_cdev || die "rmmod"
}

check_apptool
if ! lsmod | grep -q shannon_cdev; then
	check_permission
	check_module
fi

devs=`find /dev/ -maxdepth 1 -name "shannon_cdev*" | sort`

tmpfile=`mktemp`

for dev in $devs; do
	printf "=>[%-18s]: " $dev
	./ztool --dev=$dev mpt -M > $tmpfile
	if ! grep -q inherent_mbr_sector_size $tmpfile; then
		echo "ERROR"
	else
		grep inherent_mbr_sector_size $tmpfile | cut -d'=' -f2
	fi
done

rm -f $tmpfile
remove_module
