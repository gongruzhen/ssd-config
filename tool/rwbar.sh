#!/bin/bash

die()
{
	echo -ne "\033[0;1;31m$@\033[0m\n"
	exit 1
}

usage()
{
	echo "Usage:"
	echo -ne "\t`basename $0` read devnod hex-reg\n"
	echo -ne "\t`basename $0` write devnod hex-reg hex-value\n"
}

case $1 in
	"read")
		rw="read"
		;;
	"write")
		rw="write"
		;;
	
	*)
		usage
		exit 1
esac

shift
case $1 in
	[a-z])
		devnod="/debug/shannon/sct${1}"
		;;
	*)
		usage
		exit 1
esac
[ ! -e $devnod ] && die "No such file $devnod"

shift
case $rw in
	"read")
		[ $# -ne 1 ] && usage && exit 1
		echo ${1}R > ${devnod}/bar
		cat ${devnod}/bar
		;;
	"write")
		[ $# -ne 2 ] && usage && exit 1
		echo ${1}R > ${devnod}/bar
		echo ${2} > ${devnod}/bar
		;;
	*)
		die "BUG $LINENO"
esac
