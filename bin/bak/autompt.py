#!/usr/bin/python -u

import board

import os
import sys
import json
import time
import signal
import pycurl
import socket
import urllib2
import tempfile
import commands
import subprocess



#*************** global ******************
dictall = board.dictall
irf = ''
log_fd = -1


#************* signal funct **************
def onsignal_sigint(a, b):
    print("get signal SIGINT (ctrl + c)")
    exit(0)


#************** get log *****************
def get_log(log_info, log_type):
	global log_fd

	#0, ====> date, log\n
	#1, ====> date, log
	#2, log\n
	#3, log

	time.localtime(time.time())
	log_time = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))

	if log_type == 0:
		log = "=====> %s, %s\n"%(log_time, log_info)
		print log
		log_fd.write(log)

	elif log_type == 1:
		log = "=====> %s, %s"%(log_time, log_info)
		print log
		log_fd.write(log)

	elif log_type == 2:
		log = "%s\n"%(log_info)
		print log
		log_fd.write(log)

	elif log_type == 3:
		log = "%s"%(log_info)
		print log
		log = log.split('\t')
		for line in log:
			log_fd.write(line)

	log_fd.write('\n')



#********* install shannon cdev **********
def install_shannon_cdev():
	cmd = "lsmod | grep shannon_cdev > /dev/null"
	status = os.system(cmd)
	if status == 0:
		return 0

	cmd = './install.sh'
	status = os.system(cmd)
	if status != 0:
		get_log("install_shannon_cdev(): install shannon cdev Error.", 1)
		return -1

	return 0


#*********** checkout user ***************
def get_user(mpt_data, cfg_data):

	if (0 == len(mpt_data.format_byte)):
		return 0

	count = 0
	while (count < 5):
		count = count + 1

		if count == 1 and len(cfg_data.person) != 0:
			uname = cfg_data.person
		else:
			uname = input("please enter your name (same as email ID) eg:\"zhihui\":")

		commit = ' curl -k https://www.shannon-data.com/inventory/users/checkExist?uid=%s \
				2>/dev/null'%(uname)

		result = commands.getoutput(commit)
		result = str(json.loads(result))
		if "{u'status': u'ok'}" == result:
			break

	if count >= 5:
		get_log("get_user(): user ID [%s] is not vaild! please check! Error."%(uname), 0)
		return -1
	else:
		get_log("user ID:%s is OK!"%(uname), 0)
		mpt_data.uname = uname

	return 0



#************ check prepare *************
def check_prepare(mpt_data, cfg_data):
	global log_fd

	# install.sh
	status = install_shannon_cdev()
	if status == -1:
		print("check_prepare(): install shannon_cdev Error.\n")
		return -2

	# dev name
	if len(mpt_data.dev_name) == 0:
		mpt_data.dev_name = "/dev/shannon_cdev"

	if os.path.exists(mpt_data.dev_name) == 0:
		print("check_prepare(): %s is not a valid devnode, Error"%(mpt_data.dev_name))
		return -2

	#log file
	if mpt_data.dev_name[-1] == "v":
		file_name = 0
	else:
		file_name = mpt_data.dev_name[-1]

	log_fd = open("%s_%s_log"%(file_name, cfg_data.log_file), "w")
	log_fd.truncate()


	if len(mpt_data.format_byte) != 0:
		status = get_user(mpt_data, cfg_data)
		if status == -1:
			get_log("check_prepare(), get_user() Error.", 0)
			return -1

	if len(mpt_data.skip_lun) != 0:
		if (len(mpt_data.format_byte) == 0) and (mpt_data.ifmode_flag == 0):
			get_log("check_prepare(): skip lun must format dev, Error.", 2)
 			return -1

	return 0


#************** beacon_on ****************
def beacon_on(mpt_data):

	if mpt_data.beacon_on_flag == -1:
		return 0

	cmd = "./ztool --dev=%s utils peek-regs 0xC0 1"%(mpt_data.dev_name)
	(status, result) = commands.getstatusoutput(cmd)
	if status != 0:
		print("beacon_on(): get utils peek regs Error.\n")
		return -1

	result = str(result)
	result = result.split(" ")[1]
	mask = int("0x%s"%(result), 16)

	#beacon off
	if mpt_data.beacon_on_flag == 0:
		off_on_mask = mask | int('0xBFFFFFFF', 16)
	else:
		off_on_mask = mask | int('0x40000000', 16)

	cmd = "./ztool --dev=%s utils poke-regs 0xC0 %s"%(mpt_data.dev_name, off_on_mask)
	(status, result) = commands.getstatusoutput(cmd)
	if status != 0:
		print("beacon_on(): get utils poke regs Error.\n")
		return -1

	return 0


#************** dev list *****************
def list_devnode(mpt_data):

	get_log("list devices:%s"%(mpt_data.dev_name), 1)

	cmd = "./ztool --silent-config --dev=%s hwinfo"%(mpt_data.dev_name)
	(status, result) = commands.getstatusoutput(cmd)
	if status == 0:
		get_log(result, 2)
		if (mpt_data.listdev_flag == 1) or (mpt_data.mbr_flag == 1) or (mpt_data.bbt_flag == 1):
			return 0


		result = result.split('\n')
		for tmp in result:
			mpt_data.dev_info[tmp.split(':')[0]] = (tmp.split(':')[1]).strip()

		if len(mpt_data.format_byte) != 0:
			commit = 'curl -k https://www.shannon-data.com/inventory/mboards/checkExist?no=%s \
					2>/dev/null'%(mpt_data.dev_info['SerialNumber'])

			result = commands.getoutput(commit)
			result = str(json.loads(result))

			if "{u'status': u'ok'}" != result:
				get_log("list_devnode(): SerialNumber:%s does not exsit in inventory! Error."%\
						mpt_data.dev_info['SerialNumber'], 1)
				return -1
	else:
		get_log("list_devnode(): ztool hwinfo Error.", 2)
		return -1

	return 0


#************ show MBR/BBT *************
def display_mbr(mpt_data):
	if (mpt_data.mbr_flag == 0) and (mpt_data.bbt_flag == 0):
		return 0

	get_log("show MBR or BBT:", 1)
	if mpt_data.mbr_flag == 1:
		cmd = "./ztool --silent-config --dev=%s mpt -M 2>/dev/null"%(mpt_data.dev_name)
	elif mpt_data.bbt_flag == 1:
		cmd = "./ztool --silent-config --dev=%s mpt -B 2>/dev/null"%(mpt_data.dev_name)

	(status, result) = commands.getstatusoutput(cmd)
	if status != 0:
		get_log("display_mbr(): %s display mbr/BBT error."%(mpt_data.dev_name), 0)
		return -1

	get_log(result, 3)

	return 0


#******* show the board select ***********
def show_bdname(mpt_data, cfg_data):
	global dictall

	if not mpt_data.dev_info:
		get_log("show_bdname(): mpt_data.dev_info is none!", 2)
		return -1

	cmd = "./ztool --silent-config  --dev=%s readid 0"%(mpt_data.dev_name)
	(status, result) = commands.getstatusoutput(cmd)
	if status != 0:
		get_log("show_bdname(): get flash id Error.", 1)
		return -1

	flash_id = str(result)[:-1]

	key = "HW_nchannel%sHW_nthread%sHW_nlun%sHW_ecc_tmode%s"%(mpt_data.dev_info['HW_nchannel'],\
			mpt_data.dev_info['HW_nthread'],mpt_data.dev_info['HW_nlun'], mpt_data.dev_info['HW_ecc_tmode'])

	i = 0
	count = 0
	local_count_to_i = {}
	get_log("Supported board:", 3)
	while(i < len(dictall[key])):
		if flash_id == dictall[key][i]['flash_id'][0:len(flash_id)]:
			local_count_to_i['%s'%(count)] = i
			get_log("\t%2d) %s:%s" % (count,dictall[key][i]['name'], dictall[key][i]['desc']), 3)
			count = count + 1
		i = i + 1

	if cfg_data.board_num != -1:
		select_bd_num = cfg_data.board_num
	else:
		select_bd_num = int(input("Please select the board type:"))

	if (select_bd_num < 0) or (select_bd_num > count):
		get_log("Please input a number between 0 and %d" % (len(dictall[key])-1), 1)
		return -1

	select_bd_num = int(local_count_to_i['%s'%(select_bd_num)])
	if (select_bd_num < 0) or (select_bd_num >= len(dictall[key])):
		get_log("Please input a number between 0 and %d" % (len(dictall[key])-1), 1)
		return -1

	mpt_data.select_bd = dictall[key][select_bd_num]

	get_log("Your select board is %s:%s" %\
			(mpt_data.select_bd['name'], mpt_data.select_bd['desc']), 0)
	return 0


#*********** check flash id ***********
def check_flashid(mpt_data):

	flashid = []
	flashid_tmp = mpt_data.select_bd['flash_id']

	if flashid_tmp.find('and') != -1:
		flashid = flashid_tmp.split('and')
	else:
		flashid.append(flashid_tmp)

	get_log("check_flashid(): Check %s flash id begin..."%(mpt_data.dev_name), 1)
	board_lun_num = int(mpt_data.select_bd['expluns'])

	if len(mpt_data.skip_lun) != 0:
		skip_lun_num = (mpt_data.skip_lun.count(",") + 1)
		board_lun_num = board_lun_num - skip_lun_num

		cmd = './ztool --silent-config --dev=%s super-readid -T phylun:%s -t loglun:%s'%\
				(mpt_data.dev_name, mpt_data.select_bd['Tphylun'],mpt_data.skip_lun)

	else:
		cmd = './ztool --silent-config --dev=%s super-readid -T phylun:%s'%\
				(mpt_data.dev_name, mpt_data.select_bd['Tphylun'])

	(status, result) = commands.getstatusoutput(cmd)
	if status != 0:
		get_log("check_flashid(): ztool --dev=%s super readid, Error."%(mpt_data.dev_name), 1)
		return -1

	flashid_count = 0
	valid_luns = 0
	while (flashid_count < len(flashid)):
		get_log("check_flashid(): flash id:%s, valid_luns:%s"%\
				(flashid[flashid_count], result.count(str(flashid[flashid_count]))), 1)
		valid_luns = valid_luns + result.count(str(flashid[flashid_count]))
		flashid_count = flashid_count + 1

	if valid_luns != board_lun_num:
		get_log("check_flashid(): %s lost lun ID, see logfile for detail. Error."%\
				 (mpt_data.dev_name), 1)
		get_log("check_flashid(): board_lun_num:%s, vaild_luns:%s."%\
				(board_lun_num, valid_luns), 1)
		return -1

	get_log("check_flashid(): Reverse verification flash id.", 1)
	cmd = "./ztool --silent-config --dev=%s super-readid -t phylun:%s"%\
			(mpt_data.dev_name, mpt_data.select_bd['Tphylun'])

	(status, result) = commands.getstatusoutput(cmd)
	if status != 0:
		get_log("ztool --dev=%s super readid -t error." % mpt.dev_name, 1)
		return -1

	flashid_count = 0
	valid_luns = 0
	while (flashid_count < len(flashid)):
		get_log("check_flashid(): flash id:%s, valid_luns:%s"%\
				(flashid[flashid_count], result.count(str(flashid[flashid_count]))), 1)
		valid_luns = valid_luns + result.count(str(flashid[flashid_count]))
		flashid_count = flashid_count + 1

	if valid_luns != 0:
		get_log("check_flashid(): %s have vaild luns :%s(should 0). select wrong board type. Error."%\
				(mpt_data.dev_name, valid_luns), 1)

		return -1

	get_log("check_flashid(): check %s flash id finish."%(mpt_data.dev_name), 0)

	return 0


#*********** display board ***************
def display_board(mpt_data):
	if mpt_data.raidgroup_flag == 0:
		return 0

	get_log("Board:%s; RAIDGROUP:%s"%(mpt_data.select_bd["name"], mpt_data.select_bd["raidgroup"]), 0)
	return 0


#*************ifmode: check ECC ***************
def check_ifmode(mpt_data, cfg_data):
	global irf
	global log_fd

	fenced_luns = ''
	irf = ''

	local_ifmode_log_file = "./.%s_tmp"%(mpt_data.dev_name[-1])
	tmpfd = open(local_ifmode_log_file, 'wb+')

	get_log("check_ifmode(): check ifmode ....", 1)

	if len(mpt_data.skip_lun) != 0:
		status = subprocess.call([\
				'./ztool', '--silent-config',\
				'--dev=%s'%(mpt_data.dev_name),\
				'ifmode', '0', '5',\
				'-T', 'phylun:%s'%(mpt_data.select_bd['Tphylun']),\
				'-t', 'loglun:%s'%(mpt_data.skip_lun),\
				'-o', '-g',\
				'%s'%(local_ifmode_log_file),\
				'-l', '%s'%(cfg_data.fenced_lun_total_ecc),\
				'-m', '%s'%(cfg_data.fenced_lun_max_ecc)\
			])
	else:
		status = subprocess.call([\
				'./ztool', '--silent-config',\
				'--dev=%s'%(mpt_data.dev_name),\
				'ifmode', '0', '5',\
				'-T', 'phylun:%s'%(mpt_data.select_bd['Tphylun']),\
				'-o', '-g',\
				'%s'%(local_ifmode_log_file),\
				'-l', '%s'%(cfg_data.fenced_lun_total_ecc),\
				'-m', '%s'%(cfg_data.fenced_lun_max_ecc)\
			])

	if status != 0:
		get_log("check_ifmode(): ztool ifmode Error.", 1)
		return -1

	result = tmpfd.readlines()
	for tmp in result:
		if tmp.find('ShouldBeFenced') != -1:
			tmp = tmp.split(' ')
			lun_num = filter(str.isdigit, tmp[0])
			ecc_sum = tmp[5].replace('sum=', ',')
			ecc_bit = tmp[6].replace('=', '')

			irf = irf + ("%s%s%s "%(lun_num, sum_num, ecc_bit))
			fenced_luns = fenced_luns + ("%s,"%(lun_num))
		elif tmp.find('Sum of ECC bit is') != -1:
			get_log(tmp, 1)
		else:
			continue

	if len(fenced_luns) != 0:
		fenced_luns = fenced_luns[:len(fenced_luns) - 1]
		get_log("check_ifmode(): %s fence logical lun for ifmode overflow limit:%s"%\
				(mpt_data.dev_name, fenced_luns), 1)

		if cfg_data.ifmode_add_bad_lun == 1:
			addbadlun_database(mpt_data, "ifmode:%s"%(fenced_luns))

		if fenced_luns.count(',') > cfg_data.warn_fenced_lun:
			get_log("check_ifmode(): %s(fenced_luns) >= %s(warn_fenced_lun)"%\
					(fenced_luns, cfg_data.warn_fenced_lun), 0)
			return -1

		if (len(mpt_data.skip_lun) != 0):
			mpt_data.skip_lun = ("%s,%s"%(mpt_data.skip_lun, fenced_luns))
		else:
			mpt_data.skip_lun = fenced_luns

	log_fd.write(tmpfd.read())
	os.remove(local_ifmode_log_file)
	get_log("check_ifmode(): %s check ifmode finish."%(mpt_data.dev_name), 0)
	return 0


#************ add bad block into database ************
def addbadlun_database(mpt_data, note):

	if note != -1:
		if ((len(mpt_data.skip_lun) != 0) and (mpt_data.database != 0)) and (len(mpt_data.format_byte) != 0):

			commit = 'https://www.shannon-data.com/inventory/mboards/addBadLun?no=%s&bad_lun=%s&person=%s&note=%%28%s%%29'%\
					(mpt_data.dev_info['SerialNumber'], mpt_data.skip_lun, mpt_data.uname, note)

			count = 1
			while(count):
				url = urllib2.urlopen(commit)
				result = url.read()

				if result.find("error") != -1:
					get_log("addbadlun_database(): %s set badlun %s into database, Error."%\
							(mpt_data.dev_name, mpt_data.skip_lun), 1)
					get_log("addbadlun_database(): result:%s"%(result), 0)

					break_continue = int(input("Enter 0: record log break. 1: continue. [0|1]:"))
					if break_continue == 0:
						commit_bad_lun_fauild_fd = open("./commit_bad_lun_fauild_file", "wb+")
						if commit_bad_lun_fauild_fd < 2:
							get_log("addbadlun_database(): open record fauild file, Error.", 0)
							continue

						commit_bad_lun_fauild_fd.write(commit)
						commit_bad_lun_fauild_fd.close()
						get_log("addbadlun_database(): Note, %s will not fenced."%(mpt_data.skip_lun), 1)
						break

					else:
						count = count + 1
						continue
				else:
					get_log("bad lun into database:%s"%(mpt_data.skip_lun), 1)
					break


	#get bad lun from db
	commit = "https://www.shannon-data.com/inventory/mboards/queryBadLun?no=%s"%\
			(mpt_data.dev_info['SerialNumber'])

	url = urllib2.urlopen(commit)
	result = url.read()

	if result.find('error') != -1:
		get_log("addbadlun_database(): %s get badlun from database, Error."%(mpt.dev_name), 1)
		return -1

	if ((mpt_data.database != 0) and (len(mpt_data.format_byte) != 0)) or (len(mpt_data.skip_lun) == 0):
		mpt_data.skip_lun = result
	elif (len(mpt_data.skip_lun) != 0) and (len(result) != 0):
		mpt_data.skip_lun = '%s,%s'%(mpt_data.skip_lun, result)

	get_log("all bad lun: %s"%(mpt_data.skip_lun), 0)

	return 0



#********* commit_inventory_last *********
def commit_inventory_last(file_name):
	if os.path.exists(file_name) == 0:
		return 0

	if os.path.getsize(file_name) == 0:
		return 0

	commit_fauild_log_fd = open(file_name, "r+")
	if commit_fauild_log_fd < 2:
		print("commit_inventory_last(): Open %s Error."%(file_name))
		return 0

	commit = commit_fauild_log_fd.read()
	print("\ncommit_inventory_last(): commit:%s.\n"%(commit))

	count = 1
	commit_err = 0
	while(count):

		#commit bad lun need urllib2
		if file_name.find("bad_lun") != -1:
			url = urllib2.urlopen(commit)
			result = url.read()

			if result.find("error") != -1:
				commit_err = 1
				status = -1
		else:
			(status, result) = commands.getstatusoutput(commit)
			if status != 0:
				commit_err = 2

			elif result.find("ok") == -1:
				commit_err = 3


		if commit_err != 0:
			print("commit_inventory_last(): Commit %s last failure log Error."%(file_name))
			print("commit_inventory_last(): Status:%s result:%s commit_err:%s.\n"%(status, result, commit_err))
			break_continue = int(input("Enter 0: remove the log exit. 1: continue. [0|1]:"))

			if break_continue == 0:
				break

			else:
				count = count + 1
				continue

		if file_name.find("bad_lun") == -1:
			result = str(json.loads(result))
			if result != "{u'status': u'ok'}":
				print("commit_inventory_last(): Commit %s last failure log, Error."%(file_name))
				print("commit_inventory_last(): Status:%s, Result:%s."%(status, result))
				return -1

		print("commit_inventory_last(): Commit last log \033[0;1;32m %s SUCCESS!!!\033[0m"%\
				(file_name))

		break


	commit_fauild_log_fd.close()
	os.remove(file_name)
	return 0


#************* commit inventory**********
def commit_inventory(commit):

	count = 1
	commit_err = 0
	get_log("commit_inventory(): commit:%s."%(commit), 0)
	while(count):
		commitline='curl -k -d "%s"  https://www.shannon-data.com/inventory/mboards/assembly \
				2>/dev/null'%(commit)
		(status, result) = commands.getstatusoutput(commitline)

		if status != 0:
			commit_err = 1

		elif result.find("ok") == -1:
			commit_err = 2

		if commit_err != 0:
			get_log("commit_inventory(): %sth Commit into fauild info, Error."%(count), 1)
			get_log("commit_inventory(): Status:%s, Result:%s, commit_err:%s."%\
					(status, result, commit_err), 1)

			break_continue = int(input("Enter 0: record log exit. 1: continue. [0|1]:"))

			if break_continue == 0:
				commit_ztool_faild_fd = open("./commit_ztool_faild_file", "wb+")
				if commit_ztool_faild_fd < 2:
					get_log("low_format(): Open commit_ztool_faild_file Error.", 1)
					count = count + 1
					continue

				commit_ztool_faild_fd.write(commitline)
				commit_ztool_faild_fd.close()
				break

			else:
				count = count + 1
				continue

		result = str(json.loads(result))
		if result != "{u'status': u'ok'}":
			get_log("commit_inventory(): Status:%s, result:%s, Error."%(status, result), 0)
			return -1
		else:
			times_tmp = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
			get_log("time:%s hostname:%s, \033[0;1;32mMPT SUCCESS\033[0m devnode: [\033[0;1;32m%s\033[0m]]"%\
					(times_tmp, socket.gethostname(), mpt_data.dev_name), 1)
			break

	return 0


#************* format dev ****************
def low_format(mpt_data, cfg_data):
	global log_fd

	get_log("low_format(): format %s...."%(mpt_data.dev_name), 1)


	local_log_file = "./.%s_log_file"%(mpt_data.dev_name[-1])
	local_record_file = "./.%s_record_file"%(mpt_data.dev_name[-1])

	local_log_fd = open(local_log_file, 'wb+')
	local_record_fd = open(local_record_file, 'wb+')

	if mpt_data.loops_num == 0:
		loops_num_opt = ""
	else:
		loops_num_opt = "-o %s"%(mpt_data.loops_num)

	if len(mpt_data.skip_lun) == 0:
		status = subprocess.call([\
				'./ztool', '--silent-config',\
				'--dev=%s'%(mpt_data.dev_name),\
				'--power-budget=%s'%(mpt_data.select_bd['power_budget']),\
				'--ifclock=%s'%(mpt_data.select_bd['flash_ifclock']),\
				'--manual-nplane=%s'%(mpt_data.select_bd['nplane']),\
				'mpt', '%s'%(mpt_data.format_byte),\
				'%s'%(loops_num_opt),\
				'-T', 'phylun:%s'%(mpt_data.select_bd['Tphylun']),\
				'-r', '%s'%(mpt_data.select_bd['raidgroup']),\
				'-F', '%s'%(local_log_file),\
				'-V', '%s'%(mpt_data.select_bd['mbr_version']),\
				'-R', '%s'%(local_record_file),\
				'-E', '-X', '%s'%(cfg_data.warn_fenced_lun)\
			])
	else:
		status = subprocess.call([\
				'./ztool', '--silent-config',\
				'--dev=%s'%(mpt_data.dev_name),\
				'--power-budget=%s'%(mpt_data.select_bd['power_budget']),\
				'--ifclock=%s'%(mpt_data.select_bd['flash_ifclock']),\
				'--manual-nplane=%s'%(mpt_data.select_bd['nplane']),\
				'mpt', '%s'%(mpt_data.format_byte),\
				'%s'%(loops_num_opt),\
				'-T', 'phylun:%s'%(mpt_data.select_bd['Tphylun']),\
				'-t', 'loglun:%s'%(mpt_data.skip_lun),\
				'-r', '%s'%(mpt_data.select_bd['raidgroup']),\
				'-F', '%s'%(local_log_file),\
				'-V', '%s'%(mpt_data.select_bd['mbr_version']),\
				'-R', '%s'%(local_record_file),\
				'-E', '-X', '%s'%(cfg_data.warn_fenced_lun)\
			])
		

	log_fd.write(local_log_fd.read())

	if status != 0:
		beacon_on(mpt_data)
		get_log("low_format(): %s ztool format, Error."%(mpt_data.dev_name), 1)

		if mpt_data.database == 0:
			tmptime = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
			commit = "no=%s&person=%s&note=MPT FAIL ON %s TAG:%s  FM:%s TS:%s"%\
					(mpt_data.dev_info['SerialNumber'], mpt_data.uname, socket.gethostname(), \
					mpt_data.dev_info['Firmware'], mpt_data.format_byte, tmptime)

			commit_inventory(commit)

	else:
		result = local_record_fd.readlines()
		for line in result:
			if line.find("dynamic_bad_blocks") != -1:
				dynamic_bad_blocks = line.split(' ')[1]

			elif line.find("max_controller_temp") != -1:
				max_controller_temp = line.split(' ')[1]

			elif line.find("max_flash_temp") != -1:
				max_flash_temp = line.split(' ')[1]

		record_tmp_data = (dynamic_bad_blocks, max_controller_temp, max_flash_temp)

		if low_format_info(mpt_data, cfg_data, record_tmp_data) == -1:
			get_log("low_format(): BUG:%s"%(mpt_data.dev_name), 0)
			return -1

	os.remove(local_log_file)
	os.remove(local_record_file)
	get_log("==== autompt finish ====", 2)

	return 0




#************** low_format_fenced*****************
def low_format_fenced_lun(mpt_data, cfg_data):

	pass_status="PASS"
	mbr_version_num = ''
	mbr_fenced_luns = ''
	capacity = 0

	cmd = './ztool --silent-config --ifclock=%s --dev=%s mpt -M -T phylun:%s 2>/dev/null'%\
			(mpt_data.select_bd['flash_ifclock'], mpt_data.dev_name, mpt_data.select_bd['Tphylun'])

	(status, result) = commands.getstatusoutput(cmd)
	if status != 0:
		#pass_status, mbr_version_num, capacity, mbr_fenced_luns
		fenced_lun_data = ("ERR", mbr_version_num, capacity, mbr_fenced_luns)
		get_log("low_format_fenced_lun(): ztool mpt -M ==> get fenced luns, Error.", 0)
		return fenced_lun_data

	result = result.split('\n')
	for line in result:
		if line.find('capacity') != -1:
			capacity = int(line.split('=')[1].split(' ')[0])
			capacity = capacity / (2 * 1024 * 1024)

		if line.find('mbr_version') != -1:
			mbr_version_num = line.split('0x')[1]

		if line.find('Fenced Bad Log Luns:') != -1:
			if line.find('total=') == -1:
				continue

			#maybe @index should 34 start
			index = 34
			while (index < 40):
				if line[index].isdigit() == 1:
					break
				index = index + 1

			line = line[index:]
			line = line.split(' total=')

			mbr_fenced_luns = line[0]
			mbr_fenced_bad_phy_lun_total = int(line[1])

			if mbr_fenced_bad_phy_lun_total >= cfg_data.warn_fenced_lun:
				get_log("low_format_fenced_lun(): mbr_fenced_bad_lun_total(%s) > warn_fenced_lun(%s), Error."%\
						(mbr_fenced_bad_phy_lun_total, cfg_data.warn_fenced_lun), 1)
				get_log("low_format_fenced_lun(): %s Should be delivered to R&D"%(mpt_data.dev_name), 1)

				pass_status="WARNNING"

	fenced_lun_data = (pass_status, mbr_version_num, capacity, mbr_fenced_luns)
	return fenced_lun_data



#************** low_format_lost_mbr *****************
def low_format_lost_mbr(mpt_data, fenced_luns_opt):

	lost_mbr_blocks = ""

	cmd = './ztool  --silent-config --dev=%s mpt -M -T phylun:%s %s 2>/dev/null'%\
			(mpt_data.dev_name, mpt_data.select_bd['Tphylun'], fenced_luns_opt)

	(status, result) = commands.getstatusoutput(cmd)
	if status != 0:
		get_log("low_format_lost_mbr(): ./ztool mpt -M ==> get lost mbr blocks, Error!", 1)
		return -1

	result = result.split('###')
	for line in result:
		if line.find('lost MBR') == -1:
			continue

		line = line.split(' ')
		lun = int(line[2].split('-')[1])
		block = int(line[4].split('-')[1])

		lost_mbr_blocks = lost_mbr_blocks + ('%s,%s '%(lun, block))

	return lost_mbr_blocks


#************** low_format_no_mbr ********
def low_format_no_mbr(mpt_data, mbr_fenced_luns):

	cmd = './ztool --silent-config --dev=%s mpt -M -T loglun:%s 2>/dev/null'%\
			(mpt_data.dev_name, mbr_fenced_luns)

	(status, result) = commands.getstatusoutput(cmd)
	if result[0:12] != "No MBR found":
		get_log("low_format_no_mbr(): cmd: %s"%(cmd), 1)
		get_log(result, 1)
		return -1

	return 0


#************** dev list *****************
def low_format_info(mpt_data, cfg_data, record_tmp_data):
	global irf

	fenced_luns_opt = ""

	#record_tmp data
	dynamic_bad_blocks = int(record_tmp_data[0])
	max_controller_temp = int(record_tmp_data[1])
	max_flash_temp = int(record_tmp_data[2])


	# fenced lun data
	fenced_lun_data = low_format_fenced_lun(mpt_data, cfg_data)
	if str(fenced_lun_data[0]) == "ERR":
		get_log("low_format_info(): get fenced_lun_data, Error.", 0)
		return -1

	pass_status = str(fenced_lun_data[0])
	mbr_version_num = str(fenced_lun_data[1])
	capacity = int(fenced_lun_data[2])
	mbr_fenced_luns = str(fenced_lun_data[3])

	if len(mbr_fenced_luns) != 0:
		mbr_fenced_luns = mbr_fenced_luns.replace(" ", ",")
		fenced_luns_opt = "-t loglun:%s"%(mbr_fenced_luns)


	# lost mbr blocks
	lost_mbr_blocks = low_format_lost_mbr(mpt_data, fenced_luns_opt)
	if lost_mbr_blocks == -1:
		get_log("low_format_info(): get lost_mbr_blocks, Error.", 0)
		return -1

	if len(mbr_fenced_luns) != 0:
		if low_format_no_mbr(mpt_data, mbr_fenced_luns) != 0:
			get_log("low_format_info(): get no find mbr blocks, Error.", 0)
			return -1

	commit = "no=%s&person=%s&note=MPT %s ON %s TAG:%s DB:%s TEMP:%s,%s MV:%s FM:%s CAP:%sG FL:%s MF:%s BM:%s IF:%s CLK:%s"%\
			(mpt_data.dev_info['SerialNumber'], mpt_data.uname, pass_status, socket.gethostname(),\
			mpt_data.dev_info['Firmware'], dynamic_bad_blocks, max_controller_temp, max_flash_temp,\
			mbr_version_num, mpt_data.format_byte, capacity, mbr_fenced_luns, mpt_data.skip_lun, lost_mbr_blocks,\
			irf, mpt_data.select_bd['flash_ifclock'])

	get_log(commit, 0)
	commit = commit.replace(' ', '%20')
	if commit_inventory(commit) == -1:
		get_log("low_format_info(): Commit fauild, Error.", 0)
		return -1

	return 0


#********** call the function ************
def call_function(mpt_data, cfg_data):

	#list dev
	status = list_devnode(mpt_data)
	if status == -1:
		get_log("call_function(): list_devnode() Error.", 0)
		return -1

	if mpt_data.listdev_flag == 1:
		return 0

	#show mbr/bbt
	if (mpt_data.mbr_flag == 1) or (mpt_data.bbt_flag == 1):
		status = display_mbr(mpt_data)
		if status == -1:
			get_log("call_function(): display_mbr() Error.", 0)
			return -1
		return 0


	#beacon
	status = beacon_on(mpt_data)
	if status == -1:
		get_log("call_function(): beacon_on() Error.", 0)
		return -1

	if mpt_data.beacon_on_flag == 1:
		return 0

	#add bad lun
	status = addbadlun_database(mpt_data, "manually:%s"%(mpt_data.skip_lun))
	if status == -1:
		get_log("call_function(): addbadlun_database() Error.", 0)
		return -1

	if mpt_data.ifmode_flag + len(mpt_data.format_byte) + mpt_data.raidgroup_flag == 0:
		return 0

	status = show_bdname(mpt_data, cfg_data)
	if status == -1:
		get_log("cal_function(): show_bdname() Error.", 0)
		return -1

	status = check_flashid(mpt_data)
	if status == -1:
		get_log("call_function(): check_flashid() Error.", 0)
		return -1

	if mpt_data.raidgroup_flag == 1:
		return display_board(mpt_data)

	status = check_ifmode(mpt_data, cfg_data)
	if status == -1:
		get_log("call_function(): check_ifmode() Error.", 0)
		return -1

	if mpt_data.ifmode_flag == 1:
		return 0

	status = low_format(mpt_data, cfg_data)
	if status == -1:
		get_log("in call_function(), low_format() error.", 0)
		return -1

	return 0



#*************** usage *******************
def usage():
	print("Usage")
	print("	python autompt.py [-d devnode] -l, --list  #list all devices.")
	print("	python autompt.py [-d devnode] -M, --mbr  #display MBR then exit.")
	print("	python autompt.py [-d devnode] -B, --bbt  #display BBT then exit.")
	print("	python autompt.py [-d devnode] -b, --database  #list devices bad lun from db.")
	print("	python autompt.py [-d devnode] -r, --raidgroup  #display board detail on system.")
	print("	python autompt.py [-d devnode] --beacon off_on  #off_on[0 == off; 1 == on]")
	print("	python autompt.py [-d devnode] -i, --ifmode [-t loglun1,loglun2...]  #do ifmode.")
	print("	python autompt.py [-d devnode] [-b] <-n|-u|-f> [-o loops][-t loglun1,loglun2...]")
	print("						  #format dev, -b: will add bad lun into database")
	print("	python autompt.py -h, -H, --help  #show usage then exit.")
	print("eg:")
	print("	ifmode: ./autompt.py -i -t 1,5,2...  format: python autompt.py -f -d /dev/shannon_cdev1\n")



def set_mpt_opt(mpt_data, cfg_data, opt, index):

	if opt == '-h' or opt == '-H' or opt == '--help':
		usage()
		return -2

	elif opt in ['-n', '-u', '-f']:
		mpt_data.format_byte = opt

	elif opt == '-d' or opt == "--dev":
		index = index + 1
		mpt_data.dev_name = sys.argv[index]

	elif opt == '-t':
		index = index + 1
		mpt_data.skip_lun = sys.argv[index]

	elif opt == '-o' or opt == "--loops":
		index = index + 1
		mpt_data.loops_num = sys.argv[index]

	elif opt == '-b' or opt == "--database":
		mpt_data.database = 1

	elif opt == '-l' or opt == "--list":
		mpt_data.listdev_flag = 1

	elif opt == '-i' or opt == "--ifmode":
		mpt_data.ifmode_flag = 1

	elif opt == '-M' or opt == "--mbr":
		mpt_data.mbr_flag = 1

	elif opt == '-B' or opt == "--bbt":
		mpt_data.bbt_flag = 1

	elif opt == '-r' or opt == "--raidgroup":
		mpt_data.raidgroup_flag = 1

	elif opt == '--beacon':
		index = index + 1
		mpt_data.beacon_on_flag = sys.argv[index]

	else:
		print("set_mpt_opt(): Not support the usage:%s, Error.\n"%(opt))
		usage()
		return -2

	index = index + 1
	if (index >= len(sys.argv)):
		status = check_prepare(mpt_data, cfg_data)
		if status != 0:
			print("set_mpt_opt(): check_prepare Error.\n")
			return status

		return call_function(mpt_data, cfg_data)

	return index



#*********** autompt class ***************
class mpt_data(object):
	def __init__(self, dev_name = "", format_byte = "", skip_lun = "", database = 0,\
			mbr_flag = 0, bbt_flag = 0, listdev_flag = 0, ifmode_flag = 0, loops_num=0,\
			raidgroup_flag = 0, dev_info = {}, select_bd = {}, uname = "", beacon_on_flag = -1):

		self.dev_name = dev_name
		self.uname = uname

		self.format_byte = format_byte
		self.skip_lun = skip_lun
		self.loops_num = loops_num

		self.mbr_flag = mbr_flag
		self.bbt_flag = bbt_flag
		self.database = database

		self.listdev_flag = listdev_flag
		self.ifmode_flag  = ifmode_flag
		self.raidgroup_flag = raidgroup_flag
		self.beacon_on_flag = beacon_on_flag

		self.dev_info = dev_info
		self.select_bd = select_bd


#****************** config ***************
class cfg_data(object):
	def __init__(self, person = "", log_file = "", board_num = -1, warn_fenced_lun = 0,\
			ifmode_add_bad_lun = -1, fenced_lun_total_ecc = -1, fenced_lun_max_ecc = -1 ):

		self.person = person

		self.log_file = log_file
		self.board_num = board_num

		self.warn_fenced_lun = warn_fenced_lun
		self.ifmode_add_bad_lun = ifmode_add_bad_lun

		self.fenced_lun_total_ecc = fenced_lun_total_ecc
		self.fenced_lun_max_ecc = fenced_lun_max_ecc



def get_cfg_data(cfg_data):
	module = __import__("cfg")

	cfg_data.person = module.person

	cfg_data.log_file = module.log_file
	cfg_data.board_num = module.board_num

	cfg_data.warn_fenced_lun = module.warn_fenced_lun
	cfg_data.ifmode_add_bad_lun = module.ifmode_add_bad_lun

	cfg_data.fenced_lun_total_ecc = module.fenced_lun_total_ecc
	cfg_data.fenced_lun_max_ecc = module.fenced_lun_max_ecc


#*******************main******************
if __name__ == '__main__':

	signal.signal(signal.SIGINT, onsignal_sigint)

	if commit_inventory_last("./commit_bad_lun_fauild_file") == -1:
		exit(1)

	if commit_inventory_last("./commit_ztool_faild_file") == -1:
		exit(1)

	mpt_data = mpt_data()
	cfg_data = cfg_data()

	if get_cfg_data(cfg_data):
		print("main(): get_cfg_data Error.\n")
		exit(1)

	if len(sys.argv) < 2:
		print("main(): Please enter usage, Error.\n");
		usage()
		exit(1)


	index = 1
	while (index < len(sys.argv)):
		if "-" == sys.argv[index][0]:
			index = set_mpt_opt(mpt_data, cfg_data, sys.argv[index], index)

			if index == -1 or index == 0:
				log_fd.close()

			if index <= 0:
				exit(0)
		else:
			print("main():Usage %s Error.\n"%(sys.argv[index]))
			usage()
			log_fd.close()
			exit(1)

	log_fd.close()



