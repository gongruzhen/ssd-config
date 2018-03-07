#!/bin/bash

# exit if use undefines variables
set -u

die() {
	echo -ne "\033[0;1;31m$@\033[0m\n"
	exit 1
}

tmp=`mktemp`
./ztool info > $tmp

names="HW_nchannel HW_nthread HW_nlun Flash_blocks Flash_pages"
while read line; do
	for name in $names; do
		if echo $line | grep -q "^$name"; then
			expression=`echo $line | sed -e 's/ //g' -e 's/:/=/'`
			eval $expression
		fi
	done
done < $tmp
rm -f $tmp

lun=$((RANDOM % (HW_nchannel * HW_nthread * HW_nlun)))
block=$((RANDOM % Flash_blocks))
page=$((RANDOM % Flash_pages))

# echo "Select lun $lun block $block page $page to check softdecoe"
seed=$RANDOM
cmds=(
	"./ztool erase $lun $block" \
	"./ztool write $lun $block 0 -n$Flash_pages --seed=$seed" \
	"./ztool sd-read $lun $block 0 -n$Flash_pages --seed=$seed"
)

for cmd in "${cmds[@]}"; do
	echo $cmd
	eval $cmd || die "Please use ztool read to check if selecting bad block. If not so, this is softdecoe bug!"
done
