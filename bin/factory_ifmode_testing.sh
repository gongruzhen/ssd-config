#!/bin/bash

n=`lspci | grep -i 'Mass storage' | grep -i '1cb0:' | wc -l`
for ((i=0; i<$n; i++)); do
	d=`echo $((97 + i)) | awk '{printf("%c", $1)}'`
	echo "Testing Device $d ... "
	./autompt.py --autobdtype --quiet --ifmodeloops=100 -i $d
done
