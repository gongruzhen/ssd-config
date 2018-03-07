#!/bin/bash

die()
{
	echo "$@"
	exit 1
}

[ $UID -ne 0 ] && die "root permission needed"
[ $# -ne 1 ] && die "Usage: `basename $0` filename" || bbtfile="./toshiba-bbt-20130730/$1"
[ -e $bbtfile ] && die "file $bbtfile has exist"

echo "format..."
./install.sh || die "install failed"
./ztool mpt -n || die "format failed"

./ztool super-readid | head > $bbtfile
./ztool mpt -M | tee -a $bbtfile | grep -v "lost MBR"
./ztool mpt -B | tee -a $bbtfile | grep -v "dynamic"

wc -l $bbtfile
