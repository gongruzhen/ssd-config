#!/bin/bash

work="/home/git"
autotest="${work}/autotest"
ssd_controller="${work}/ssd-controller"
shannon_utils="${work}/shannon-utils"
shannon="${work}/linux/drivers/block/shannon"

git_autotest()
{
	cd $autotest
	git_err=0
	echo "--------------git pull autotest-------------"
	git reset --hard || git_err=1
	git reset --hard 4191b0aedfe27ccfc8b6498c1e5a31428d21fef3 || git_err=2
	git pull || git_err=3

	if [[ $git_err -eq 0 ]];then
		echo -e "--------------git pull autotest success-------------.\n\n"
		return 0
	else
		echo "git Error. git_err:$git_err.\n"
		return 1
	fi
}

git_ssd_controller()
{
	cd $ssd_controller
	git_err=0
	echo "--------------git pull ssd-controller------------"
	git reset --hard || git_err=1
	git reset --hard 70226b08474925ece95b3542a227d7160aab0227  || git_err=2
	git pull || git_err=3

	cd ${ssd_controller}/iocheck
	make clean; make || git_err=4

	cd ${ssd_controller}/tool
	make clean; make || git_err=5

	mv ${ssd_controller}/tool/ztool ${ssd_controller}/bin/  || git_err=6

	if [[ $git_err -eq 0 ]];then
		echo -e "------------------git pull ssd-controller success----------------.\n\n"
		return 0
	else
		echo "git Error. git_err:$git_err.\n"
		return 1
	fi
}

git_shannon_utils()
{
	cd $shannon_utils
	git_err=0
	echo "-----------------git pull shannon-utils---------------------"
	git reset --hard || git_err=1
	git reset --hard d712b6fe2ff13e5cdd110c7659bfdcc20a6fb294 || git_err=2
	git pull || git_err=3
	make clean; make || git_err=4
	
	if [[ $git_err -eq 0 ]];then
		echo -e "---------------git pull ssd-controller success------------------.\n\n"
		return 0
	else
		echo "git Error. git_err:$git_err.\n"
		return 1
	fi
}


git_shannon()
{
	cd $shannon
	git_err=0
	echo "---------------------git shannon------------------"
	git reset --hard || git_err=1
	git reset --hard 561d5073953d0bd2a87f43d764c2c9e4aef292cd || git_err=3
	git pull || git_err=4
	make clean; make || git_err=5
	
	if [[ $git_err -eq 0 ]];then
		echo -e "--------------------git pull ssd-controller success---------------.\n\n"
		return 0
	else
		echo "git Error. git_err:$git_err.\n"
		return 1
	fi
}

main()
{
	git_autotest
	[ $? -ne 0 ] && return 0

	git_ssd_controller
	[ $? -ne 0 ] && return 0

	git_shannon_utils
	[ $? -ne 0 ] && return 0

	git_shannon
	[ $? -ne 0 ] && return 0
	
	return 0
}

main


