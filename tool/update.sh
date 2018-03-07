#!/bin/bash

apptool=./ztool
module_dir=../cdev
max_size=`expr 32 \* 1024 \* 1024`

usage()
{
	printf "Usage:\n"
	printf "\t`basename $0` --dev=nod FPGA-bin-file\n"
	printf "\t`basename $0` --lsdev, list all shannon devices on ths system\n"
	printf "\t`basename $0` --help, display this help and exit\n"

	printf "Example:\n"
	printf "\t\"`basename $0` --dev=/dev/shannon_cdev file\" -- you can do so if you system has only one shannon device\n"
}

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
	if [[ $orgstatus == 'no' ]]; then
		rmmod shannon_cdev || die "rmmod"
	fi
}

# main
if [ $# -ne 1 -a $# -ne 2 ]; then
	usage
	exit 1
fi

if [ $# -eq 1 ]; then
	if [ $1 = "--help" -o $1 = "-h" ]; then
		usage
		exit 0
	fi

	if [ $1 != "--lsdev" ]; then
		usage
		exit 1
	fi
fi

check_apptool
if ! lsmod | grep -q shannon_cdev; then
	check_permission
	check_module
	orgstatus='no'
else
	orgstatus='yes'
fi

if [ $1 = "--lsdev" ]; then
	for devnod in `ls /dev/shannon_cdev*`; do
		printf "=== $devnod ===\n"
		$apptool --dev=$devnod hwinfo | head -n3
		printf "\n"
	done
	remove_module
	exit 0
fi

bin_file=$2
if [ ! -e $bin_file ]; then
	echo "ERR: File $bin_file not exists"
	exit 1
fi

length=`stat -L -c%s $bin_file`
if [ $length -eq 0 ]; then
	echo "ERR: File $bin_file length is 0"
	exit 1
fi
if [ $length -gt $max_size ]; then
	echo "ERR: File $bin_file is too large"
	exit 1
fi

if ! b=`$apptool $1 nor check-endian`; then
	echo "not check-endian failed"
	remove_module
	exit 1
fi

if [ "$b" -ne 0 ]; then
	opt="-b"
fi

if ! $apptool $1 nor erase 0 $length; then
	echo "erase nor failed"
	remove_module
	exit 1
fi

if ! $apptool $1 nor write $opt 0 $bin_file; then
	echo "write nor failed"
	remove_module
	exit 1
fi

bin_file_read=`mktemp`
if [[ -z $bin_file_read ]]; then
	echo "mktemp filename for read fail"
	remove_module
	exit 1
fi

if ! $apptool $1 nor read $opt 0 $length $bin_file_read; then
	echo "read nor failed"
	remove_module
	exit 1
fi

echo -n "Check "
if cmp $bin_file $bin_file_read; then
	if ! $apptool $1 nor reload; then
		echo "nor reload failed"
		remove_module
		exit 1
	fi

	echo "passed! Hardware updates successfully! Please poweroff the computer then restart."
	rc=0
else
	echo "failed!"
	rc=1
fi

remove_module
rm -f $bin_file_read
exit $rc
