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

usage()
{
	echo -ne "Usage:\n"
	echo -ne "\t$(basename $0) [--dev=devnod] -id \"FlashID\"\n"
	echo -ne "\t$(basename $0) [--dev=devnod] -id \"FlashID\" \"FlashID\"\n"
	exit $1
}

if [[ ${1:0:6} == "--dev=" ]]; then
	devnod=$1
	shift
fi

[ $# -lt 2 ] && usage 1

case $1 in
-id)
	fullid=1
	;;
-xid)
	fullid=0
	;;
*)
	usage 1
esac

ID1=$(echo $2 | tr '[:lower:]' '[:upper:]' | sed -e 's/^\s*//' -e 's/\s*$//' -e 's/\s\+/ /g')
if [ $# -ge 3 ]; then
	ID2=$(echo $3 | tr '[:lower:]' '[:upper:]' | sed -e 's/^\s*//' -e 's/\s*$//' -e 's/\s\+/ /g')
fi

if [ $fullid -eq 1 ]; then
	n=$(echo $ID1 | wc -w)
	m=$(echo $ID1 | wc -c)
	[ $n -ne 8 -o $m -ne 24 ] && die "You should input 8 Bytes ID for ID1"

	if [ $# -ge 3 ]; then
		n=$(echo $ID2 | wc -w)
		m=$(echo $ID2 | wc -c)
		[ $n -ne 8 -o $m -ne 24 ] && die "You should input 8 Bytes ID for ID2"
	fi
fi

if ! lsmod | grep shannon_cdev 1>/dev/null; then
	check_permission
	check_module
	orgstatus='no'
else
	orgstatus='yes'
fi

tempfile=$(mktemp)

if [ $# -eq 2 ]; then
	./ztool $devnod super-readid | grep -v ": $ID1" | tee $tempfile
elif [ $# -eq 3 ]; then
	./ztool $devnod super-readid | grep -v -e ": $ID1" -e ": $ID2"| tee $tempfile
else
	usage 1
fi

lines=$(cat $tempfile | wc -l)
[ $lines -eq 0 ] && echo "All luns id are valid" && exit 1

echo
phy_absentluns=$(sed 's/.*phylun-\([0-9]\+\).*/\1/' $tempfile)
log_absentluns=$(sed 's/^lun-\([0-9]\+\).*/\1/' $tempfile)

echo "Possible absent luns number=$lines -->"

echo -n "loglun:"
i=0
for lun in $log_absentluns; do
	echo -n "$lun"
	let i++
	[ $i -eq $lines ] && echo && break
	echo -n ","
done

echo -n "phylun:"
i=0
for lun in $phy_absentluns; do
	echo -n "$lun"
	let i++
	[ $i -eq $lines ] && echo && break
	echo -n ","
done

rm -f $tempfile

if [[ $orgstatus == 'no' ]]; then
	rmmod shannon_cdev || die "rmmmod"
fi
