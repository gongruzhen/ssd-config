#!/bin/bash

shift_cnt=0

usage()
{
	echo "Usage:"
	echo -e "\t`basename $0` [Options] begin_block count seed"

	echo "Options"
	echo -e "\t-F count, set fixed ecc error bits per codeword"
	echo -e "\t-R ratio, set ratio of fixed ecc error bits as 1/ratio, default is 1"
	echo -e "\t-M count, set random ecc error bits per codeword"
	echo -e "\t-H head, 0 and 1 will open raid-write"
}

check_cfg()
{
	[ ! -e luninfo ] && return 1
	[ ! -e config ] && return 1

	line=`grep "nchannel" config`
	nchannel=${line#nchannel=}

	line=`grep "nthread" config`
	nthread=${line#nthread=}

	line=`grep "nlun" config`
	nlun=${line#nlun=}

	line=`./ztool utils parse-file luninfo | grep "nchannel"`
	n_nchannel=${line#nchannel=}

	line=`./ztool utils parse-file luninfo | grep "nthread"`
	n_nthread=${line#nthread=}

	line=`./ztool utils parse-file luninfo | grep "nlun"`
	n_nlun=${line#nlun=}

	if [ $nchannel -ne $n_nchannel -o $nthread -ne $n_nthread -o $nlun -ne $n_nlun ]; then
		return 1;
	else
		return 0;
	fi
}

while getopts "F:R:M:H:" opt
do
	case $opt in
	F)
		[ ! -z "$ecc_errbis_option" ] && echo "Don\`t set option 'max-ecc-errbits' and 'fixed-ecc-errbits' at the same time" && exit 1
		shift_cnt=`expr $shift_cnt + 1`
		ecc_errbis_option="-F $OPTARG"
		;;
	R)
		fix_ecc_ratio="-R $OPTARG"
		shift_cnt=`expr $shift_cnt + 1`
		;;
	M)
		[ ! -z "$ecc_errbis_option" ] && echo "Don\`t set option 'max-ecc-errbits' and 'fixed-ecc-errbits' at the same time" && exit 1
		shift_cnt=`expr $shift_cnt + 1`
		ecc_errbis_option="-M $OPTARG"
		;;
	H)
		if [ $OPTARG -ne 0 -a $OPTARG -ne 1 -a $OPTARG -ne 2 ]; then
			echo Head must be 0 1 2
			exit 1
		fi

		if [ $OPTARG -ne 2 ]; then
			if ! grep "raid_mode=1" config > /dev/null; then
				echo "You must enable raid in file 'config'"
				exit 1
			fi
			head_option="--head=$OPTARG"
			raid_option="--raid"
		fi
		shift_cnt=`expr $shift_cnt + 1`
		;;
	*)
		usage
		exit 1
	esac
done

shift $shift_cnt
[ $# -ne 3 ] && usage && exit 1

[ -z "$ecc_errbis_option" ] && echo "Option -M or -F is needed" && exit 1

sblk=$1
nblk=$2
seed=$3

# echo $sblk $nblk $seed $ecc_errbis_option $head_option $raid_option
# echo "./ztool fake-ecc $sblk $nblk -f luninfo --seed=$seed $ecc_errbis_option $head_option"
# echo "./ztool super-read $sblk $nblk -f luninfo --seed=$seed $raid_option"

check_cfg
if [ $? -ne 0 ]; then
	echo "Scan flash to skip factory invalid blocks:"
	./ztool bbt -e -f bbt
	./ztool luninfo luninfo bbt
else
	./ztool super-erase $sblk $nblk -s
fi

if ./ztool fake-ecc $sblk $nblk -f luninfo --seed=$seed $ecc_errbis_option $fix_ecc_ratio $head_option; then
	./ztool super-read $sblk $nblk -f luninfo --seed=$seed $raid_option
else
	echo "Fake ecc failed"
fi
