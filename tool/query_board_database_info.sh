#!/bin/bash

usage()
{
	echo -ne "Usage:\n\t./`basename $0` sn1 sn2 ...\n"
}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

i=1
n=`echo $@ | wc -w`

for sn in $@; do
	echo "[$sn]"
	counter=`curl -k https://www/inventory/mboards/queryCounter?no=${sn}\&type=init 2>/dev/null`
	echo "init:    $counter"

	counter=`curl -k https://www/inventory/mboards/queryCounter?no=${sn}\&type=verify 2>/dev/null`
	echo "verify:  $counter"

	badluns=`curl -k https://www/inventory/mboards/queryBadLun?no=${sn} 2>/dev/null`
	echo -ne "badluns: "
	[ -n "$badluns" ] && echo "$badluns" || echo "None"

	errlog=`curl -k https://www/inventory/mboards/getInfo?no=${sn}\&type=err_msg 2>/dev/null`
	echo -ne "errlog:  "
	[ -n "$errlog" ] && echo "$errlog" || echo "None"

	[ $i -ne $n ] && echo
	let i++
done
