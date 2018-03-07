#!/bin/bash

i=0
j=0
declare -a data
declare -a data_diff
declare -a data_smt

gcfg='--silent --disable-ecc'

usage()
{
	echo "Usage:"
	echo -e "\t ./vth-read.sh mode lun block page mode=[D S]"
	echo -e "\t ./vth-read.sh mode file mode=[D S R]"
	echo -e "\t mode=[D(diff data) S(smt data) R(raw data)]"
	exit
}

smt_calc()
{
	for ((j=0; j < $(($i - 3)); j++))
	do
		temp_1=$((data_diff[$j+2] / 2))
		temp_2=${data_diff[$j+1]}
		temp_3=$((data_diff[$j] / 2))
		data_smt[$j]=$(($temp_1 + $temp_2 + $temp_3))
		if [[ $mode == 'S' ]]; then
			echo ${data_smt[j]}
		fi
	done
}

data_process()
{
	while read line
	do
		if [[ ${line:0:13} = "page_bit_cnt:" ]]; then
			data[$i]=${line:13}
			if [[ $mode == 'R' ]]; then
				echo ${data[i]}
			fi
			let i++
		elif [[ ${line:4} = "read start" ]]; then
			i=0
		elif [[ ${line:4} = "read end" ]]; then
			for ((j=0; j < $(($i - 1)); j++));
			do
				data_diff[$j]=$((data[$j+1] - data[$j]))
				if [[ ${data_diff[j]} -lt 0 ]]; then
					let data_diff[$j]=0-${data_diff[$j]}
				fi
				if [[ $mode == 'D' ]]; then
					echo ${data_diff[j]}
				fi
			done
			if [[ $mode == 'S' ]]; then
				smt_calc
			else
				break;
			fi
		fi
	done < $1
}

mode=$1

if [ $# == 4 ]; then
	if [ $mode != 'D' -a $mode != 'S' ]; then
		usage
	fi

	lun=$2
	block=$3
	wl=$4

	mode_tmp=$mode
	mode='R'
	./ztool $gcfg vth-read $lun $block $wl 80 80 4 -rA > A_vth_read
	A_F=$(data_process "A_vth_read")

	./ztool $gcfg vth-read $lun $block $wl 80 80 4 -rG > G_vth_read
	G_F=$(data_process "G_vth_read")

	./ztool $gcfg vth-read $lun $block $wl 7F 7F 4 -rG > G_vth_read
	G_L=$(data_process "G_vth_read")

	erase_bit=$(($A_F - $G_F + $G_L))
	echo $erase_bit

	mode=$mode_tmp
	./ztool $gcfg vth-read $lun $block $wl 80 7F 4 -rC > C_vth_read
	./ztool $gcfg vth-read $lun $block $wl 80 7F 4 -rG > G_vth_read


	data_process "C_vth_read"
	data_process "G_vth_read"

#	rm A_vth_read C_vth_read G_vth_read
elif [ $# == 2 ]; then
	if [ $mode != 'D' -a $mode != 'R' -a $mode != 'S' ]; then
		usage
	fi

	data_process $2
else
	usage
fi
