#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage: `basename $0` file eccnum"
	exit 1
fi

infile=$1
ecc=`printf "ecc\[%2d\]" $2`

while read line; do
	if echo $line | grep -q "^#"; then
		tag=$line
	fi

	if echo $line | grep -q "$ecc"; then
		echo $tag $line
	fi
done < $infile
