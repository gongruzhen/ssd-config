#!/bin/bash
# script of install shannon_cdev driver

module_dir=../cdev

check_permission()
{
	if [ $EUID != 0 ]; then
		echo "Operation not permitted! Prefix \"sudo\" then try again"
		exit 1
	fi
}

check_module()
{
	current_dir=`pwd`
	cd $module_dir
	if ! ./install $@; then
		exit 1
	fi
	cd $current_dir
}

check_permission
check_module $@
