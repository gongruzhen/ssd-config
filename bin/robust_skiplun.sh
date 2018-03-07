#!/bin/bash

module_dir=../cdev

die()
{
	echo $@
	exit 1
}

check_permission()
{
	if [ $EUID != 0 ]; then
		die "Operation not permitted! Prefix \"sudo\" then try again"
	fi
}

check_module()
{
	current_dir=`pwd`
	cd $module_dir
	if ! sudo ./install; then
		die "install module"
	fi
	cd $current_dir
}

if [ $# -ne 1 ]; then
	die -ne "Usage:\n\t./`basename $0` loglun|phylun:x1-x2,x3,x4-x5...\n"
fi

luns=$1

if [[ ${luns:0:7} != 'loglun:' && ${luns:0:7} != 'phylun:' ]]; then
	die -ne "Usage:\n\t./`basename $0` loglun|phylun:x1-x2,x3,x4-x5...\n"
fi

check_permission
check_module

./ztool super-erase -T $luns -a || die "super-erase"
#./ztool super-write -T $luns 0 4 || die "1st super-write"
#./ztool super-write -T $luns 0 4 || die "2nd super-write"

rmmod shannon_cdev || die "rmmod"
