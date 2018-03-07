#!/bin/bash

defstep=10			# default: 10 <=> 0.1v
apptool="./ztool --dev=a"

die() {
	echo "$@"
	exit 1
}

cleanup() {
	if [ -n "$lun" ]; then
		echo "cleanup"
		$apptool v2-vth --reset $lun
		exit 1
	fi
}

trap cleanup SIGINT

if [ $# -ne 3 -a $# -ne 4 ]; then
	die -ne "Usage:\n\t`basename $0` lun block page\n"
fi
lun=$1
block=$2
page=$3
if [ $# -eq 4 ]; then
	step=$4
else
	step=$defstep
fi

id=`$apptool readid 0 | sed 's/\s//g'`
if [ "$id" != "AD5A15F30070AD5A" ]; then
	die "This is not Hynix-V2 flash, please check!"
fi

prebits=0
for ((v=-60; v<587; v+=$step)); do
	vsv=$(printf "%.2f\n" `echo "scale=2; $v/100" | bc`)

	$apptool v2-vth --set -q -- $lun $v
	bits=`$apptool --silent-config --disable-ecc read $lun $block $page -pN -Bm`

	echo $vsv $(($bits - $prebits))
	prebits=$bits
done
$apptool v2-vth --reset $lun
