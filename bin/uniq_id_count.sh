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

if ! lsmod | grep shannon_cdev 1>/dev/null; then
	check_permission
	check_module
	orgstatus='no'
else
	orgstatus='yes'
fi

./ztool super-readid | awk -F":" '{print $2}' | sed 's/^\s*//g' | sort | uniq

if [[ $orgstatus == 'no' ]]; then
	rmmod shannon_cdev || die "rmmmod"
fi
