#!/usr/bin/python -u

# init david.miao 20160410

import sys
import os
import time
import getopt
import commands
import re
import fileinput
from socket import gethostname

#-----------------------------------------------------------------------------------------------------
def autompt_exit(info):
	# NOTE! All functions called by me can't use autompt_exit, or it will trap in dead recursion loop
	try:
		raise Exception
	except:
		f = sys.exc_info()[2].tb_frame.f_back
	func = f.f_code.co_name
	lineno = f.f_lineno

	if GBLVAR.inflight_device:
		cmd = '%s --dev=%s utils peek-regs 0xC0 1' % (GBLVAR.apptool, GBLVAR.inflight_device)
		r,o = commands.getstatusoutput(cmd)
		if r == 0:
			o = o.split()
			x = int(o[1], 16)
			cmd = '%s --dev=%s utils poke-regs 0xC0 %08X' % (GBLVAR.apptool, GBLVAR.inflight_device, x|0x40000000)
			os.system(cmd)

	if GBLVAR.inflight_db:
		print 'COMMIT FAILURE INFO TO DB'
		GBLVAR.inflight_db.commit_failure_format('%s() +%d: %s' % (func, lineno, info))

	if GBLVAR.inflight_log:
		GBLVAR.inflight_log.error('%s() +%d: %s' % (func, lineno, info))
	else:
		print '\033[0;1;31m[%s %s() +%d]. %s\033[0m' % (GBLVAR.autompt_version, func, lineno, info)

	sys.exit(21)

def exeshell(cmd, check = True):
	r,o = commands.getstatusoutput(cmd)
	if check and r != 0:
		autompt_exit("execute shell command \'%s\' error: code=%d, %s" % (cmd, r>>8, o))
	return o

def install():
	if os.geteuid() != 0:
		autompt_exit('Operation not permitted! Prefix "sudo" then try again')

	o = exeshell('lsmod | grep -w shannon_cdev', False)
	if not o:
		exeshell('./install.sh')

def uninstall():
	o = exeshell('lsmod | grep -w shannon_cdev', False)
	if o and o.split()[2] == '0':
		exeshell('rmmod shannon_cdev')

def alpha2node(c):
	c = c.lower()
	if len(c) != 1 or not c.isalpha():
		autompt_exit('%s is not a valid device code' % c)

	if c == 'a':
		return '/dev/shannon_cdev'
	else:
		return '/dev/shannon_cdev%s' % (ord(c) - ord('a'))

def node2alpha(node):
	m = re.match('(/dev/shannon_cdev)(\d*)', node)
	if m:
		m = m.groups()
	else:
		autompt_exit('%s is not a valid device node' % node)

	if not m[1]:
		return 'a'
	else:
		return chr(97 + int(m[1]))

def get_devices(given = None):
	devices = exeshell('find /dev -maxdepth 1 -name "shannon_cdev*"').split('\n')
	devices.sort()
	return devices

def device_exist(devnode):
	return os.path.exists(devnode)

def beacon(devnode, do):
	o = exeshell('%s --dev=%s utils peek-regs 0xC0 1' % (GBLVAR.apptool, devnode)).split()
	x = int(o[1], 16)

	if do == 'on':
		exeshell('%s --dev=%s utils poke-regs 0xC0 %08X' % (GBLVAR.apptool, devnode, x|0x40000000))
	elif do == 'off':
		exeshell('%s --dev=%s utils poke-regs 0xC0 %08X' % (GBLVAR.apptool, devnode, x&0xBFFFFFFF))
	else:
		autompt_exit('BUGggggggg')

def get_tempfile():
	global GBLVAR

	tf = exeshell('mktemp')
	GBLVAR.tempfiles.append(tf)
	return tf

def rm_tempfiles():
	for tf in GBLVAR.tempfiles:
		if os.path.exists(tf):
			os.remove(tf)

def timespan(sec):
	h = sec / 3600
	m = (sec % 3600) / 60
	s = sec % 60

	ts = '%d seconds' % s
	if m or h:
		ts = '%d minutes %s' % (m, ts)
	if h:
		ts = '%d hours %s' % (h, ts)
	return ts

#-----------------------------------------------------------------------------------------------------
class rnd_options:
	def __init__(self):
		self.fblocks = 0
		self.ifclock = 0
		self.bdfile = None
		self.flashlib = None
		self.nodatabase = False
		self.initloops = ''
		self.ifmodeloops = 200
		self.autobdtype = False
		self.forceautobdtype = 0
		self.skipfirmwarecheck = False
		self.cheatinitloops = 0
		self.nocheckcounter = False
		self.user = ''
		self.forcelastfirmware = False
		self.forcebdname = ''
		self.constoverprovision = False
		self.downgrade = False
		self.quiet = False
		self.autocps = True

class gbl_variables:
	def __init__(self):
		self.tempfiles = []
		self.inflight_db = None
		self.inflight_log = None
		self.inflight_device = None
		self.apptool = './ztool --silent-config'
		self.autompt_version = 'Undetermined'

#-----------------------------------------------------------------------------------------------------
class logger:
	def __init__(self, name):
		self.name = name
		self.prefix = '%s(%s) MPT' % (gethostname(), GBLVAR.autompt_version)
		self.filehandler = open(self.name, 'a', buffering=0)

	def __del__(self):
		self.filehandler.close()

	def close(self):
		self.filehandler.close()

	def add_prefix(self, p):
		self.prefix += ' %s' % p

	def info(self, info, raw=False, xprint=True, xlog=True):
		if not raw:
			ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
			if xprint and not RNDOPT.quiet:
				print '=====> %s %s, %s' % (self.prefix, ts, info)
			if xlog:
				self.filehandler.write('===> %s %s, %s\n' % (self.prefix, ts, info))
		else:
			if xprint and not RNDOPT.quiet:
				print info,
			if xlog:
				self.filehandler.write('%s' % info)

	def debug(self, debug):
		ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		print '=====> \033[0;1;34m%s %s DEBUG\033[0m, %s' % (self.prefix, ts, debug)
		self.filehandler.write('===> %s %s DEBUG, %s\n' % (self.prefix, ts, debug))

	def warn(self, warn):
		ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		print '=====> \033[0;1;33m%s %s WARNNING\033[0m, %s' % (self.prefix, ts, warn)
		self.filehandler.write('===> %s %s WARNNING, %s\n' % (self.prefix, ts, warn))

	def error(self, error):
		ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		print '=====> \033[0;1;31m%s %s ERROR\033[0m, %s' % (self.prefix, ts, error)
		self.filehandler.write('===> %s %s ERROR, %s\n' % (self.prefix, ts, error))

	def success(self, success):
		ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		print '=====> \033[0;1;32m%s %s SUCCESS\033[0m, %s' % (self.prefix, ts, success)
		self.filehandler.write('===> %s %s SUCCESS, %s\n' % (self.prefix, ts, success))

	def checkpoint(self, checkpoint):
		ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		print '=====> \033[0;1;35m%s %s CHECKPOINT\033[0m, %s' % (self.prefix, ts, checkpoint)
		self.filehandler.write('===> %s %s CHECKPOINT, %s\n' % (self.prefix, ts, checkpoint))
		# TODO: commit to DB

#-----------------------------------------------------------------------------------------------------
class product_database:
	def __init__(self, device, log, url='https://www.shannon-data.com', nodatabase=False):
		self.device = device
		self.log = log
		self.url = url
		self.retry_time = 10
		self.retry_interval = 3
		self.user = ''
		self.sn = ''
		self.hostname = gethostname()
		self.mpt_version = GBLVAR.autompt_version
		self.nodatabase = nodatabase;
		self.nodb_badlun = []

	def curl(self, ccmd, retry=False):
		if self.nodatabase:
			return (0, '{"status":"ok"}')

		r,o = commands.getstatusoutput('curl %s 2>/dev/null' % ccmd)
		if not retry:
			return (r, o)
		else:
			for loop in range(self.retry_time + 1):
				if r == 0 and o.lower().find('error') == -1:
					return (r, o)
				time.sleep(self.retry_interval)
				print '.',
			return (r, o)

	def check_user(self, user):
		if self.nodatabase:
			return None

		self.log.info('CHECK user ...')

		self.user = user.strip()
		ccmd = '-k https://www.shannon-data.com/inventory/users/checkExist?uid=%s' % self.user
		ret = self.curl(ccmd)
		if ret[0] != 0 or ret[1] != '{"status":"ok"}':
			autompt_exit('Fail to find user %s: r=%s c=%s' % (self.user, ret[0], ret[1]))

	def check_board(self, sn):
		if self.nodatabase:
			return None

		self.log.info('CHECK board in inventory ...')

		self.sn = sn.strip()
		ccmd = '-k https://www.shannon-data.com/inventory/mboards/checkExist?no=%s' % self.sn
		ret = self.curl(ccmd)
		if ret[0] != 0 or ret[1] != '{"status":"ok"}':
			autompt_exit('Fail to find board %s in inventory: r=%s c=%s' % (self.sn, ret[0], ret[1]))

	def push_badlun(self, badlun_list, type, auto_ecc_lunlist_info=None):
		if self.nodatabase:
			self.nodb_badlun += badlun_list
			return None

		if not self.user or not self.sn:
			autompt_exit('BUGggggggg: user=%s sn=%s' % (self.user, self.sn))

		if not badlun_list:
			return None

		mlst = ','.join([str(x) for x in badlun_list])
		if type == 'auto':
			xlst = []
			for lun in badlun_list:
				if lun not in auto_ecc_lunlist_info:
					autompt_exit('BUGggggggg')
				lst = auto_ecc_lunlist_info[lun]
				xlst.append('%d,%d,%d,%d' % (lst[0], lst[5], lst[7], lst[8]))
			note = ' '.join(xlst)
		else:
			note = mlst
		self.log.info('PUSH %s logical badlun %s to database ...' % (type, mlst))

		ccmd = '-k https://www/inventory/mboards/addBadLun?'	\
			'no=%s\&'					\
			'bad_lun=%s\&'					\
			'person=%s\&'					\
			'note=%%28%s:%s%%29' % (self.sn, mlst, self.user, type, note.replace(' ', '%20'))
		ret = self.curl(ccmd, retry = True)
		if ret[0] != 0 or ret[1].lower().find('error') != -1 or not ret[1].replace(',', '0').isdigit():
			autompt_exit('Fail to push %s logical badlun %s to database: r=%s c=%s' % (type, mlst, ret[0], ret[1]))

	def get_badlun(self):
		if self.nodatabase:
			return self.nodb_badlun

		self.log.info('GET logical badlun from database ...')

		ccmd = '-k https://www/inventory/mboards/queryBadLun?no=%s' % self.sn
		ret = self.curl(ccmd, retry = True)

		if ret[0] == 0 and not ret[1]:	# None
			self.log.info('database logical badlun is None')
			return []

		if ret[0] != 0 or ret[1].lower().find('error') != -1 or not ret[1].replace(',', '0').isdigit():
			autompt_exit('Fail to get badlun from database: r=%s c=%s' % (ret[0], ret[1]))
		else:
			self.log.info('database logical badlun is %s' % ret[1])
			return [int(x) for x in ret[1].split(',')]

	def obtain_counter(self, type):
		if self.nodatabase:
			return 0

		if not self.sn:
			autompt_exit('BUGggggggg: user=%s sn=%s' % (self.user, self.sn))

		self.log.info('Obtain %s counter from DB' % type)
		cmd = 'curl -k https://www/inventory/mboards/queryCounter?no=%s\&type=%s 2>/dev/null' % (self.sn, type)
		for retry in range(self.retry_time):
			r,o = commands.getstatusoutput(cmd)
			if r == 0 and o.isdigit():
				break
			time.sleep(self.retry_interval)
		if r != 0 or not o.isdigit():
			autompt_exit('obtain %s counter fail' % type)
		return int(o)

	def reset_counter(self, type, count=0):
		if self.nodatabase:
			return None

		if not self.user or not self.sn:
			autompt_exit('BUGggggggg: user=%s sn=%s' % (self.user, self.sn))

		self.log.info('Reset %s to %d ...' % (type, count))

		line = 'no=%s&person=%s&type=%s&inc=%d&note=%s' % (self.sn, self.user, type, count, 'Reset %s counter to %d' % (type, count))
		ccmd = 'curl -k -d "%s" https://www.shannon-data.com/inventory/mboards/assembly 2>/dev/null' % line.replace(' ', '%20')
		ret = self.curl(ccmd)
		if ret[0] != 0 or ret[1] != '{"status":"ok"}':
			autompt_exit('Fail to reset %s counter: r=%s c=%s' % (type, ret[0], ret[1]))

	def commit_failure_format(self, info):
		# XXX: this function only called by autompt_exit
		# DONOT use autompt_exit() in this function, or it maybe trap in dead recursion loop
		if self.nodatabase or not self.user or not self.sn:
			return None

		line = 'no=%s&person=%s&note=MPT FAIL! HT:%s(%s) TS:%s WH:%s' % \
			(self.sn, self.user, self.hostname, self.mpt_version, time.strftime("%H%M%S",time.localtime()), info[0:200])

		self.log.info('COMMIT failure status to DB: %s' % line[line.find('MPT'):], xprint=False)

		ccmd = 'curl -k -d "%s" https://www.shannon-data.com/inventory/mboards/assembly 2>/dev/null' % line.replace(' ', '%20')
		for retry in range(self.retry_time):
			r,o = commands.getstatusoutput(ccmd)
			if r == 0 and o == '{"status":"ok"}':
				break
			time.sleep(self.retry_interval)
		if r != 0 or o != '{"status":"ok"}':
			self.log.error('Commit failure status to DB error: %s' % line)

	def commit_success_format(self,
			firmware='', capacity='', type='', inc='', product_type='',
			dynamic_bad_blocks='',
			max_controller_temp='', max_flash_temp='', max_board_temp='',
			mbr_version='',
			format_mode='',
			manual_fenced_luns='',
			auto_fenced_luns='',
			fenced_luns_in_mbr='',
			bad_mbrblocks='',
			ifmode_ecc='',
			flash_clock='',
			rndinfo=''):
		line = 'no=%s&person=%s&firmware_tag=%s&capacity=%s&type=%s&inc=%d&product_type=%s&'	\
			'note=MPT PASS! '	\
			'HT:%s(%s) '		\
			'TS:%s '		\
			'DB:%s '		\
			'TP:%s,%s,%s '		\
			'MV:%s '		\
			'FM:%s '		\
			'CP:%s '		\
			'MF:%s '		\
			'AF:%s '		\
			'FL:%s '		\
			'BM:%s '		\
			'IF:%s '		\
			'CK:%s '		\
			'RD:%s' % (self.sn, self.user, firmware, capacity, type, inc, product_type,
				self.hostname, self.mpt_version,
				time.strftime("%H%M%S",time.localtime()),
				dynamic_bad_blocks,
				max_controller_temp, max_flash_temp, max_board_temp,
				mbr_version,
				format_mode,
				'%sGB' % capacity,
				manual_fenced_luns,
				auto_fenced_luns,
				fenced_luns_in_mbr,
				bad_mbrblocks,
				ifmode_ecc,
				flash_clock,
				rndinfo)
		rline = line[line.find('MPT'):]
		if self.nodatabase:
			self.log.info('NO COMMIT MPT status: %s' % rline)
			self.log.success('%s MPT PASS' % self.device)
			return None

		if not self.user or not self.sn:
			autompt_exit('BUGggggggg: user=%s sn=%s' % (self.user, self.sn))
		self.log.info('COMMIT pass status to db ...\n%s' % rline)

		ccmd = 'curl -k -d "%s" https://www.shannon-data.com/inventory/mboards/assembly 2>/dev/null' % line.replace(' ', '%20')
		looptime = 0
		while True:
			r,o = commands.getstatusoutput(ccmd)
			if r == 0 and o == '{"status":"ok"}':
				break
			if (looptime % 3600 == 0):
				self.log.info("Maybe network error: %s. Please check, but don't shutdown! %s seconds" % (o, looptime))
			time.sleep(10)
			looptime += 10
		self.log.success('%s MPT PASS' % self.device)

#-----------------------------------------------------------------------------------------------------
class boards_parser:
	def __init__(self, filename = 'board'):
		self.boards = {}
		self.filename = filename
		self.product_type_list = []
		self.bdfw = {}

	def extend_number(self, nstr):
		m = re.match("^(\d+)$", nstr)
		n = re.match("^(\d+)-(\d+)$", nstr)
		if m:
			lst = [int(m.group(1))]
		elif n:
			lst = range(int(n.group(1)), int(n.group(2)) + 1)
		else:
			autompt_exit("extend_number %s is invalid format!" % nstr)
		return lst

	def parse_fwtag(self, filename='./fwtag'):
		try:
			fh = open(filename, 'r')
		except:
			autompt_exit('open file %s error' % filename)
		lines = fh.readlines()
		fh.close()

		for line in lines:
			line = line.strip()
			if not line or line.startswith('['):
				continue
			line = line.split('=')
			self.bdfw[line[0]] = line[1]

	def parse(self):
		self.parse_fwtag()

		try:
			fh = open(self.filename, 'r')
		except:
			autompt_exit('open file %s error!' % self.filename)
		lines = fh.readlines()
		fh.close()

		'''
		Example
		[G4IH17-3200GB]
		flash_id=98 3C 95 93 7A D1 08 04
		capacity=3200GB
		iowidth=16
		ecc_tmode=58
		ifmode=1
		channel=8
		thread=8
		lun=2
		expluns=128
		Tphylun=0-127
		ncodeword=3
		nplane=1
		raidgroup=4
		mbr_version=default
		power_budget=24
		flash_ifclock=default
		burnin_ecc_limit=default
		burnin_ecc_limit=default
		firmware_tag=FijiHH_T35
		flash_temp_threshold=75
		board_temp_threshold=75
		controller_temp_threshold=75
		desc="Naxos-HH 3.2T, 8x8x2, toshiba 15nm 128GB"
		'''
		for line in lines:
			line = line.strip()
			lineinfo = line

			if line.startswith('#') or not line:
				continue

			if line.startswith('[G'):
				boardtype=line.strip('[]')
				self.boards[boardtype]={}
				self.boards[boardtype]['name'] = boardtype

				m = re.match("G(\d+)[I]([FAHDSMNUB]\d+)-", boardtype)
				if not m:
					autompt_exit('board name %s is nonstandard' % boardtype)
				self.boards[boardtype]['product_type'] = m.group(2)
				if self.boards[boardtype]['product_type'] in self.product_type_list:
					autompt_exit('repeated product_type: %s' % self.boards[boardtype]['product_type'])
				self.product_type_list.append(self.boards[boardtype]['product_type'])
				continue

			line = line.split('=')
			if line[0] == 'flash_id':
				if 'and' not in line[1]:
					self.boards[boardtype]['flash_id'] = line[1].strip()
					self.boards[boardtype]['flash_id_ext'] = 'NotMixedFlashCard'
				else:
					mixid = line[1].split('and')
					self.boards[boardtype]['flash_id'] = mixid[0].strip();
					self.boards[boardtype]['flash_id_ext'] = mixid[1].strip();
			elif line[0] in ('flash_temp_threshold', 'board_temp_threshold', 'controller_temp_threshold'):
				v = line[1].split(',')
				if (len(v) != 2):
					autompt_exit('%s has nonstandard key: %s' % (self.boards[boardtype]['name'], line[1]))
				self.boards[boardtype]['%s_lo' % line[0]] = v[0]
				self.boards[boardtype]['%s_hi' % line[0]] = v[1]
			elif line[0] == 'Tphylun':
				self.boards[boardtype][line[0]] = line[1]

				self.boards[boardtype]['extend_Tphylun'] = []
				for s in line[1].split(','):
					self.boards[boardtype]['extend_Tphylun'].extend(self.extend_number(s))
				self.boards[boardtype]['extend_Tphylun'].sort()
			elif line[0] == 'firmware_tag':
				self.boards[boardtype][line[0]] = self.bdfw[line[1]]
				self.boards[boardtype]['last_firmware_tag'] = self.bdfw['last_%s' % line[1]]
			elif line[0] == 'desc':
				self.boards[boardtype][line[0]] = line[1].strip('"')
				m = re.search('(\w+nm)', line[1])
				if m:
					self.boards[boardtype]['technology'] = m.group(1)
				else:
					self.boards[boardtype]['technology'] = '??nm'
			elif line[0] == 'misc_global_options':
				self.boards[boardtype][line[0]] = lineinfo[lineinfo.find('=')+1:]
			else:
				self.boards[boardtype][line[0]] = line[1]

	def get_boards(self):
		return self.boards

#-----------------------------------------------------------------------------------------------------
class flashs_parser():
	def __init__(self, filename = 'flash'):
		self.flashs = {}
		self.filename = filename
		self.id2partno = {}

	def parse(self):
		try:
			fh = open(self.filename, 'r')
		except:
			autompt_exit('open file %s error!' % self.filename)
		lines = fh.readlines()
		fh.close()

		'''
		[TH58TFG9DDLBA8C]
		id=98 3A 94 93 76 D1 08 04
		blk_num=4212
		page_num=256
		page_size_shift=14
		oob_size=1280
		plane_num=2
		plane_mask=0x0100
		lun_mask=0
		ifmode=toggle
		factory_ivb=[0,0,0] [0,16384,16384] [255,0,0] [255,16384,16384]
		drvmode=[0xEF,0x10,0x06,0,0,0]
		'''
		for line in lines:
			line = line.strip()

			if line.startswith('#') or not line:
				continue

			if line.startswith('['):
				partno=line.strip('[]')
				if partno in self.flashs.keys():
					autompt_exit('repeated flash partno: %s' % partno)
				self.flashs[partno]={}
				self.flashs[partno]['name'] = partno
				continue

			line = line.split('=')
			if line[0] == 'id':
				self.id2partno[line[1]] = partno
			self.flashs[partno][line[0]] = line[1]

	def get_flash(self, id):
		try:
			partno = self.id2partno[id]
		except KeyError:
			autompt_exit('No such partno in flashlib: %s' % id)
		return self.flashs[partno]

#-----------------------------------------------------------------------------------------------------
class manage_listdev():
	def __init__(self, name = "LISTDEV"):
		self.name = name
		self.devices = []
		self.hw_attr = {}	# attribute read from hareware, Note it's 2D dict
		self.flash = {}		# Flash lib read from flash file, Note ut's 2D dict
		self.boards = {}

	def add_device(self, c):
		self.devices.append(alpha2node(c))

	def add_option(self, opt):
		autompt_exit('%s require no argument' % self.name)

	def get_hw_attr(self, device):
		try:
			return self.hw_attr[alpha2node(device)]
		except KeyError:
			autompt_exit("No such device '%s'" % device)

	def get_flash(self, device):
		try:
			return self.flash[alpha2node(device)]
		except KeyError:
			autompt_exit("No such devie '%s'" % device)

	def do_listdev(self, logname=None, whatdo=None, mifmode=None, mmpt=None):
		global GBLVAR

		if mmpt:
			self.log = mmpt.log
		elif mifmode:
			self.log = mifmode.log
		else:
			self.log = logger(logname)
			self.log.info('-'*64 + '\n',raw=True)
			self.log.info(whatdo)
		GBLVAR.inflight_log = self.log

		if not self.devices:
			self.devices = get_devices()
		if not self.devices:
			autompt_exit('do_listdev: No device')

		if RNDOPT.bdfile:
			bp = boards_parser(RNDOPT.bdfile)
		else:
			bp = boards_parser()
		bp.parse()
		self.boards = bp.get_boards()

		if RNDOPT.flashlib:
			fp = flashs_parser(RNDOPT.flashlib)
		else:
			fp = flashs_parser()
		fp.parse()

		self.log.info('list devices')
		for d in self.devices:
			self.log.info('=== %c %s ===\n' % (node2alpha(d), d), raw=True)

			if not device_exist(d):
				print "No such device '%s'" % node2alpha(d)
				if d != self.devices[-1]: print
				continue

			self.hw_attr[d] = {}
			self.hw_attr[d]['displayinfo'] = []
			self.hw_attr[d]['Possible_Bdtypes'] = []
			self.hw_attr[d]['Possible_Bdtypes_with_technology'] = []
			self.hw_attr[d]['Autoselcet_Bdtypes'] = []
			self.hw_attr[d]['Autoselcet_Bdtypes_with_technology'] = []
			self.hw_attr[d]['super_readid'] = []
			self.hw_attr[d]['superid'] = []
			self.hw_attr[d]['log2phylun'] = {}
			self.hw_attr[d]['phy2loglun'] = {}

			# hwinfo
			'''
			Example
			PCI_domains: 1:0.0
			PCI_subsystem: 1CB0:0032
			HW_nchannel: 8
			HW_nthread: 8
			HW_nlun: 2
			HW_iowidth: 16
			HW_ecc_mmode: 14
			HW_ecc_tmode: 58
			Firmware: 3EF37EA0
			SerialNumber: SH16215K731204
			NodeName: /dev/shannon_cdev
			'''
			cmd = '%s --dev=%s hwinfo' % (GBLVAR.apptool, d)
			r,o = commands.getstatusoutput(cmd)
			if r and 'No controller parameter found in NOR' not in o:
				autompt_exit('execute %s fail' % cmd)
			o = o.split('\n')
			if RNDOPT.autocps and ('HW_Generation: G5-FPGA' in o or 'HW_Generation: G5-FFSA' in o):
				GBLVAR.apptool ='%s --cps=auto' % GBLVAR.apptool

			for info in exeshell('%s --dev=%s hwinfo' % (GBLVAR.apptool, d)).split('\n'):
				if True:
					self.hw_attr[d]['displayinfo'].append(info)
				lst = info.split()
				self.hw_attr[d][lst[0].strip(':')] = lst[1] if (len(lst) == 2) else ''

			# info
			'''
			Example
			PCI_domains: 1:0.0
			PCI_subsystem: 1CB0:0032
			HW_nchannel: 8
			HW_nthread: 8
			HW_nlun: 2
			HW_buffer_write_supported: Yes
			Flash_blocks: 4212
			Flash_pages: 256
			Flash_pagesize: 32768
			Flash_oobsize: 2560
			CFG_nplane: 2
			CFG_codeword_size: 1472
			CFG_sector_ncodeword: 3
			CFG_page_nsector: 8
			CFG_chunk_nsector: 16
			Advanced_read_supported: Yes
			'''
			for info in exeshell('%s --dev=%s info' % (GBLVAR.apptool, d)).split('\n'):
				if info.startswith('Advanced_read_supported'):
					self.hw_attr[d]['displayinfo'].append(info)
				lst = info.split()
				self.hw_attr[d][lst[0].strip(':')] = lst[1] if (len(lst) == 2) else ''

			if self.hw_attr[d]['HW_Generation'].startswith('G5-FFSA'):
				tempfile = get_tempfile()
				cmd = ['%s --dev=%s nor read 0 4096 %s > /dev/null 2>&1' % (GBLVAR.apptool, d, tempfile), \
					'cmp -n 32 %s NorFlash_Boot.hex > /dev/null 2>&1' % tempfile, \
					'if [ $? != 0 ]; then', \
					'	echo "Update NorFlash_Boot"', \
					'	%s --dev=%s nor erase 0 4096 > /dev/null 2>&1' % (GBLVAR.apptool, d), \
					'	%s --dev=%s nor write 0 NorFlash_Boot.hex > /dev/null 2>&1' % (GBLVAR.apptool, d), \
					'	%s --dev=%s nor read 0 4096 %s > /dev/null 2>&1' % (GBLVAR.apptool, d, tempfile), \
					'	cmp -n 32 %s NorFlash_Boot.hex > /dev/null 2>&1' % tempfile, \
					'fi']
				exeshell('\n'.join(cmd))

			# flash info
			for line in exeshell('%s --dev=%s super-readid' % (GBLVAR.apptool, d)).split('\n'):
				m = re.match("lun-(\d+) phylun-(\d+) \*hw-channel=(\d+) hw-thread=(\d+) hw-lun=(\d+): (.*)", line)
				if m:
					self.hw_attr[d]['super_readid'].append(line)
					self.hw_attr[d]['superid'].append(m.group(6))
					self.hw_attr[d]['log2phylun'][m.group(1)] = m.group(2)
					self.hw_attr[d]['phy2loglun'][m.group(2)] = m.group(1)
			FlashID = self.hw_attr[d]['superid'][0]
			self.hw_attr[d]['displayinfo'].append('Lun0_FlashID: %s' % FlashID)
			self.hw_attr[d]['displayinfo'].append('Flash_Parameters: blocks=%s pages=%s pagesize=%s planes=%s' % \
				(self.hw_attr[d]['Flash_blocks'], self.hw_attr[d]['Flash_pages'], self.hw_attr[d]['Flash_pagesize'], self.hw_attr[d]['CFG_nplane']))
			self.hw_attr[d]['FlashID'] = FlashID
			self.flash[d] = fp.get_flash(FlashID)
			if RNDOPT.fblocks:
				if RNDOPT.fblocks > int(self.flash[d]['blk_num']):
					autompt_exit('rnd option --fblocks should be less than %s' % self.flash[d]['blk_num'])
				if RNDOPT.fblocks % 128:
					autompt_exit('rnd option --fblocks should be divided exactly by 256')

			# pcie LinkStat info and subsystem id
			LinkStat = exeshell("lspci -s %s -vv | grep -w LnkSta | sed 's/^\s\+//'" % self.hw_attr[d]['PCI_domains'])
			self.hw_attr[d]['displayinfo'].append(LinkStat)
			m = re.search('Width x(\d+)', LinkStat)
			if m:
				self.hw_attr[d]['LinkStat'] = m.groups()[0]
			else:
				self.hw_attr[d]['LinkStat'] = 'NotParse'

			self.hw_attr[d]['subsystem_id'] = self.hw_attr[d]['PCI_subsystem'].split(':')[1]

			# parse board type
			map = {	'channel':'HW_nchannel',
				'thread':'HW_nthread',
				'lun':'HW_nlun',
				'iowidth':'HW_iowidth',
				'ecc_tmode':'HW_ecc_tmode',
				'ncodeword':'CFG_sector_ncodeword',
				'flash_id':'FlashID',
				'subsystem_id':'subsystem_id',
				'generation':'HW_Generation' }
			for boardtype in self.boards.keys():
				match = 0

				for key in self.boards[boardtype].keys():
					if key in map.keys():
						if self.boards[boardtype][key] == self.hw_attr[d][map[key]]:
							match += 1
						elif self.boards[boardtype][key] == 'todo':
							match += 1
				if match == len(map):
					self.hw_attr[d]['Possible_Bdtypes'].append(boardtype)
					self.hw_attr[d]['Possible_Bdtypes_with_technology'].append('%s(%s)' % (boardtype, self.boards[boardtype]['desc']))
			self.hw_attr[d]['Possible_Bdtypes'].sort()
			self.hw_attr[d]['displayinfo'].append('Possible_Bdtypes: %s' % ', '.join(self.hw_attr[d]['Possible_Bdtypes']))

			# parse autoselcet board type
			for boardtype in self.hw_attr[d]['Possible_Bdtypes']:
				detphylun = []
				for loglun,id in enumerate(self.hw_attr[d]['superid']):
					if id.find(self.boards[boardtype]['flash_id']) != -1 or id.find(self.boards[boardtype]['flash_id_ext']) != -1:
						detphylun.append(int(self.hw_attr[d]['log2phylun']['%03d' % loglun], 10))
				detphylun.sort()

				if detphylun == self.boards[boardtype]['extend_Tphylun']:
					self.hw_attr[d]['Autoselcet_Bdtypes'].append(boardtype)
					self.hw_attr[d]['Autoselcet_Bdtypes_with_technology'].append('%s(%s)' % (boardtype, self.boards[boardtype]['desc']))

			if RNDOPT.forcebdname and len(self.devices) == 1:
				boardtype = RNDOPT.forcebdname
				if not self.boards.has_key(boardtype):
					autompt_exit('No such board %s to be forcebdname!' % boardtype)
				self.hw_attr[d]['Autoselcet_Bdtypes'] = []
				self.hw_attr[d]['Autoselcet_Bdtypes_with_technology'] = []

				self.hw_attr[d]['Autoselcet_Bdtypes'].append(boardtype)
				self.hw_attr[d]['Autoselcet_Bdtypes_with_technology'].append('%s(%s)' % (boardtype, self.boards[boardtype]['desc']))

			self.hw_attr[d]['displayinfo'].append('Autoselcet_Bdtypes: %s' % ', '.join(self.hw_attr[d]['Autoselcet_Bdtypes_with_technology']))

			# end
			'''print '\nDEBUG:'
			for key in self.hw_attr[d].keys(): print '%s=%s' % (key, self.hw_attr[d][key])'''

			self.log.info('%s\n' % '\n'.join(self.hw_attr[d]['displayinfo']), raw=True)
			if not self.hw_attr[d]['Possible_Bdtypes']:
				self.log.info('\033[0;1;31mERROR %s(%c): Maybe You Update a Mismatch Firmware!\033[0m\n' % (d, node2alpha(d)), raw=True)
			if d != self.devices[-1]: self.log.info('\n', raw=True)


		if mmpt:
			# check DB board
			if len(self.devices) != 1:
				autompt_exit('BUGggggggg %s' % ' '.join(self.devices))
			d = self.devices[0]
			mmpt.db.check_board(self.hw_attr[d]['SerialNumber'])

			# check initloops
			if mmpt.initloops and not RNDOPT.nocheckcounter and '-u' not in mmpt.mode:
				if mmpt.db.obtain_counter('init') or mmpt.db.obtain_counter('verify'):
					autompt_exit('Board [%s] INIT counter in DB is not 0. Please clear the counter in our inventory website!' % self.hw_attr[d]['SerialNumber'])

		return self.boards

#-----------------------------------------------------------------------------------------------------
class manage_ifmode():
	def __init__(self, name = 'IFMODE'):
		self.name = name
		self.device = ''
		self.mode = ''
		self.boards = {}	# 2D dict parsed from board file
		self.board = {}		# 1D dict, this board info
		self.hw_attr = {}	# 1D dict, attribute read from hareware
		self.flash = {}		# 1D dict, read from flash file
		self.mf_lunlist = []		# manual fenced lun list
		self.af_lunlist = []		# automatic fenced lun list because of ifmode
		self.using_lunlist = []		# using luns except for manual and atomic fenced luns
		self.ecc_lunlist_info = {}	# the luns that have ECC
		self.opts = ''
		self.gopts = ''
		self.ifmodeloops = RNDOPT.ifmodeloops
		self.highlowbyte = None

	def add_device(self, c):
		self.device = alpha2node(c)

	def set_mode(self, mode):
		s = '%s %s' % (self.mode, mode)
		self.mode = s.strip()

	def global_option(self):
		self.gopts += ' --dev=%s' % self.device
		self.gopts += ' --manual-nplane=%s' % self.board['nplane']

		# rnd option will overwrite that read from board file
		for k,s in zip(['power_budget', 'flash_ifclock'], ['--power-budget', '--ifclock']):
			if self.board[k] != 'default':
				self.gopts += ' %s=%s' % (s, self.board[k])
		if RNDOPT.ifclock:
			self.gopts += ' --ifclock=%d' % (RNDOPT.ifclock)
		if RNDOPT.fblocks:
			self.gopts += ' --fblocks=%d' % (RNDOPT.fblocks)
		if RNDOPT.downgrade:
			if self.board['flash_ifclock'] == '7':
				autompt_exit("cannot downgrade frequency that is minimum: 7!")
			self.gopts += ' --ifclock=%d' % ((5+1) if self.board['flash_ifclock'] == 'default' else (int(self.board['flash_ifclock'])+1))
			self.gopts += ' --downgrade'

		# misc options from board
		if self.board['misc_global_options'] != 'None':
			self.gopts += ' %s' % self.board['misc_global_options'].strip('"')

		# high low 8 bit ifmode draw
		if self.mode == '-d':
			if not self.highlowbyte:
				autompt_exit('You should input -0 -1 or -2 to select high-low high or low byte!')
		else:
			self.highlowbyte = '0'
		if self.highlowbyte != '0':
			if self.highlowbyte not in ('1', '2'):
				autompt_exit('BUGggggggg')
			self.gopts += ' --per-byte-dis=%s' % self.highlowbyte

		# delete redundant blank space
		self.gopts = ' '.join(self.gopts.split())

	def add_option(self, opt, outside=False):
		if not opt.startswith('-'):
			autompt_exit("option should start with '-'")

		if opt[0:2] == '--':
			self.opts += ' %s' % opt
		elif opt[:2] == '-t':
			if not opt[2:]:
				autompt_exit('option -t require argument')

			if outside:
				self.mf_lunlist = [int(x) for x in opt[2:].split(',')]
			else:
				self.opts += ' -t loglun:%s' % opt[2:]
		elif opt[:2] in ('-0', '-1', '-2') and self.mode == '-d':
			if not outside:
				autompt_exit('BUGggggggg')
			self.highlowbyte = opt[1]
		else:
			self.opts += ' %s %s' % (opt[0:2], opt[2:])
		self.opts = self.opts.strip(' ')

	def parse_ifmode_outlog(self, filename):
		for line in fileinput.input(filename):
			m = re.match('#lun-(\d+) phylun-(\d+) \*hwchannel-(\d+) hwthread-(\d+) hwlun-(\d+) ECC sum=(\d+)', line)
			if not m:
				continue
			favlst = [int(s, 10) for s in m.groups()]

			linelst = line.split()
			if linelst[-1] == 'ShouldBeFenced':
				favlst.append('F')
				self.af_lunlist.append(favlst[0])
				del linelst[-1]
			else:
				favlst.append('N')
			for s in linelst[-1].replace('[', '').replace(']', '').split('='):
				favlst.append(int(s, 10))
			self.ecc_lunlist_info[favlst[0]] = favlst
		self.af_lunlist.sort()
		#print 'favlst format: [loglun, phylun, channel, thread, lun, SumECC, FencedOrNot, MaxECC, NumOfMaxECC]'
		#for l in sorted(self.ecc_lunlist_info.keys()): print self.ecc_lunlist_info[l]
		#print 'automatic fenced lun because ifmode:', self.af_lunlist

	def check_flashid(self):
		if RNDOPT.forcebdname:
			return

		self.log.info('CHECK FlashID ...')

		topt = ''
		if self.mf_lunlist:
			topt = '-t loglun:%s' % ','.join([str(x) for x in self.mf_lunlist])

		for id in exeshell('%s --dev=%s super-readid -T phylun:%s %s' % (GBLVAR.apptool, self.device, self.board['Tphylun'], topt)).split('\n'):
			if not id.startswith('lun-'):
				continue

			m1 = re.match('lun-(\d+).*: %s' % self.board['flash_id'], id)
			m2 = re.match('lun-(\d+).*: %s' % self.board['flash_id_ext'], id)
			if m1:
				self.using_lunlist.append(int(m1.group(1)))
			elif m2:
				self.using_lunlist.append(int(m2.group(1)))
			else:
				autompt_exit('Lost lun ID, %s, maybe you select a wrong board number, please check!' % id)

		for id in exeshell('%s --dev=%s super-readid -t phylun:%s %s' % (GBLVAR.apptool, self.device, self.board['Tphylun'], topt)).split('\n'):
			if not id.startswith('lun-'):
				continue

			if re.match('lun-.*: %s' % self.board['flash_id'], id) or re.match('lun-.*: %s' % self.board['flash_id_ext'], id):
				autompt_exit('Redundant lun ID, %s, check your selected board' % id)

	def show_mbr_info(self):
		cmd = '%s %s mpt %s %s' % (GBLVAR.apptool, self.gopts, self.mode, self.opts)
		self.log.info('DISPLAY mbr info ...')
		return os.system(cmd) >> 8

	def show_board_info(self):
		tag = '#*!*#  '

		info = exeshell('%s --dev=%s --manual-nplane=%s info' % (GBLVAR.apptool, self.device, self.board['nplane'])).split('\n')
		hwinfo = exeshell('%s --dev=%s --manual-nplane=%s hwinfo' % (GBLVAR.apptool, self.device, self.board['nplane'])).split('\n')
		for line in info+hwinfo:
			print '%s%s' % (tag, line)

		for key in sorted(self.board.keys()):
			print '%s%s=%s' % (tag, key, self.board[key])
		return 0

	def do_ifmode(self, logname=None, whatdo=None, mmpt=None):
		global GBLVAR
		global RNDOPT

		if mmpt:
			self.log = mmpt.log
		else:
			self.log = logger(logname)
			self.log.info('-'*64 + '\n',raw=True)
			self.log.info(whatdo)
		GBLVAR.inflight_log = self.log
		GBLVAR.inflight_device = self.device
		beacon(self.device, 'off')

		# do listdev firstly
		listdev = manage_listdev()
		listdev.add_device(node2alpha(self.device))
		self.boards = listdev.do_listdev(mifmode = self, mmpt=mmpt)
		self.hw_attr = listdev.get_hw_attr(node2alpha(self.device))
		self.flash = listdev.get_flash(node2alpha(self.device))
		self.log.add_prefix('%s[%s]' % (node2alpha(self.device), self.hw_attr['SerialNumber']))

		if RNDOPT.autobdtype:
			if len(self.hw_attr['Autoselcet_Bdtypes']) == 0:
				autompt_exit('Have none Autoselcet_Bdtypes')
			elif len(self.hw_attr['Autoselcet_Bdtypes']) == 1:
				self.board = self.boards[self.hw_attr['Autoselcet_Bdtypes'][0]]
			else:
				if RNDOPT.forceautobdtype:
					if (RNDOPT.forceautobdtype > len(self.hw_attr['Autoselcet_Bdtypes'])):
						autompt_exit('rnd option --forceautobdtype should between 1 and %d' % len(self.hw_attr['Autoselcet_Bdtypes']))
					self.board = self.boards[self.hw_attr['Autoselcet_Bdtypes'][RNDOPT.forceautobdtype-1]]
				else:
					autompt_exit("One more matched boards are detected, --autobdtype is out of work")
			self.log.add_prefix('%s' % self.board['name'])
			self.log.info('Auto selected board is %s' % self.board['name'])
		else:
			print '\nSelect board:'
			if self.hw_attr['Autoselcet_Bdtypes']:
				List_Bdtypes = self.hw_attr['Autoselcet_Bdtypes']
			else:
				List_Bdtypes = self.hw_attr['Possible_Bdtypes']

			for i, b in enumerate(List_Bdtypes):
				print '\t%d) %s: %s' % (i+1, b, self.boards[b]['desc'].strip('"'))

			s = raw_input('Please select the board type:')
			if s[0:1] == 'q' or s[0:1] == 'Q':
				autompt_exit('Exit without select board')
			if not s.isdigit():
				autompt_exit("Invaid input '%s', please input digit!" % s)
			i = int(s)
			if i <= 0:
				autompt_exit('Please input a number between %d and %d' % (1, len(List_Bdtypes)))
			try:
				self.board = self.boards[List_Bdtypes[i-1]]
			except IndexError:
				autompt_exit('Please input a number between %d and %d' % (1, len(List_Bdtypes)))
			self.log.add_prefix('%s' % self.board['name'])
			self.log.info('Your selected board is %s' % self.board['name'])

		if mmpt and not RNDOPT.skipfirmwarecheck:
			if RNDOPT.forcelastfirmware:
				if self.board['last_firmware_tag'].upper() != self.hw_attr['Firmware'].upper():
					autompt_exit('last firmware is %s but now is %s' % \
						(self.board['last_firmware_tag'].upper(), self.hw_attr['Firmware'].upper()))
			else:
				if self.board['firmware_tag'].upper() != self.hw_attr['Firmware'].upper():
					autompt_exit('Please update firmware from %s to latest %s' % \
						(self.hw_attr['Firmware'].upper(), self.board['firmware_tag'].upper()))
		self.check_flashid()

		if self.mode == '-w':
			sys.exit(self.show_board_info())

		# ifmode command and options
		self.global_option()
		self.add_option('-Tphylun:%s' % self.board['Tphylun'])
		if self.mf_lunlist:
			self.add_option('-t%s' % ','.join([str(x) for x in sorted(self.mf_lunlist)]))

		if self.mode[0:2] == '-M' or self.mode[0:2] == '-B':
			sys.exit(self.show_mbr_info())

		self.add_option('-f')
		self.add_option('-o')
		self.add_option('-v')
		ifmodelog = get_tempfile()
		self.add_option('-g%s' % ifmodelog)
		self.add_option('-l20')
		self.add_option('-m2')
		if self.mode == '-d':
			self.add_option('-d')
		cmd = '%s %s ifmode 0 %d %s' % (GBLVAR.apptool, self.gopts, self.ifmodeloops, self.opts)
		if RNDOPT.quiet:
			cmd += ' 1>/dev/null 2>&1'

		self.log.info('IFMODE ...')
		self.log.info(cmd)
		stime = long(time.time())
		status = os.system(cmd) >> 8
		if status == 0xFC:
			autompt_exit('DO IFMODE ERROR: %s, INVALID ECC 0xFC or 0xFD' % cmd)
		elif status:
			autompt_exit('DO IFMODE ERROR: %s' % cmd)
		etime = long(time.time())
		self.log.info('ifmode took %s (%s)' % (timespan(etime-stime), etime-stime))
		self.parse_ifmode_outlog(ifmodelog)

		return self.flash, self.boards, self.board, self.hw_attr, self.mf_lunlist, self.af_lunlist, self.using_lunlist, self.ecc_lunlist_info

#-----------------------------------------------------------------------------------------------------
class manage_mpt():
	def __init__(self, name = 'MPT'):
		self.name = name
		self.mode = ''
		self.device = ''
		self.boards = {}	# 2D dict parsed from board file
		self.board = {}		# 1D dict, this board info
		self.hw_attr = {}	# 2D dict, read from hareware
		self.flash = {}		# 1D dict, read from flash file
		self.mf_lunlist = []		# manual fenced lun list
		self.af_lunlist = []		# automatic fenced lun list because of ifmode
		self.df_lunlist = []		# fenced luns get from database
		self.using_lunlist = []		# configed luns excpet manual and atomic fenced luns
		self.ecc_lunlist_info = None	# the luns that have ECC
		self.ifmode_badlun_threshold = 4
		self.mpt_badlun_threshold = 0	# will be set to luns/2
		self.opts = ''
		self.gopts = ''
		self.t_opt = ''			# this option will send to ifmode if have, then rebuilt
		self.db = None
		self.record = {}
		self.initloops = 0
		self.exitlog = ''
		self.rndinfo = ''

	def add_device(self, c):
		self.device = alpha2node(c)

	def set_mode(self, mode):
		s = '%s %s' % (self.mode, mode)
		self.mode = s.strip()

	def parse_mpt_recordfile(self, filename):
		try:
			fh = open(filename, 'r')
		except:
			autompt_exit('open file %s error!' % filename)
		lines = fh.readlines()
		fh.close()

		for line in lines:
			a = line.split()
			self.record[a[0]] = a[1]

		for k in ('dynamic_bad_blocks', 'max_controller_temp', 'max_flash_temp', 'max_board_temp'):
			if k not in self.record.keys():
				autompt_exit('mpt record file lost keyname %s' % k)

	def parse_read_mbr(self):
		cmd = '%s %s mpt -M -T phylun:%s 2>/dev/null' % (GBLVAR.apptool, self.gopts, self.board['Tphylun'])
		self.log.info('READ MBR ...\n%s' % cmd)

		tmplst = []
		mbr = exeshell(cmd)
		self.record['fenced_luns_in_mbr'] = ''
		self.record['fenced_phyluns_in_mbr'] = ''

		for line in mbr.split('\n'):
			if line.find('lost MBR') != -1:
				m = re.match('### NOTE: lun-(\d+) phylun-(\d+) block-(\d+) lost MBR', line)
				if not m:
					autompt_exit('BUGggggggg')
				lun = int(m.group(1), 10)
				blk = int(m.group(3), 10)
				if lun not in self.df_lunlist:
					tmplst.append('%d,%d' % (lun, blk))
			elif line.find('Fenced Bad Log Luns:') != -1:
				a = line.split()[4:]
				if a:
					del(a[-1])
				self.record['fenced_luns_in_mbr'] = ','.join(a)
			elif line.find('Fenced Bad Phy Luns:') != -1:
				a = line.split()[4:]
				if a:
					del(a[-1])
				self.record['fenced_phyluns_in_mbr'] = ','.join(a)
			else:
				a = line.split('=')
				#a rare bug out of index list a
				if len(a) < 2:
					self.log.info('MBR format Bug: %s' % str(a))
					continue
				self.record[a[0]] = a[1]
		self.record['bad_mbrblocks'] = ' '.join(tmplst)

	def check_ifmode_badluns(self):
		if self.ecc_lunlist_info == None:
			autompt_exit('BUGggggggg')

		dt = {}
		for key in self.ecc_lunlist_info.keys():
			if self.ecc_lunlist_info[key][-2] > 251:
				dt[self.ecc_lunlist_info[key][0]] = '%02X:%d' % (self.ecc_lunlist_info[key][-2], self.ecc_lunlist_info[key][-1])
		if dt:
			autompt_exit('IFMODE Uncorrectable ECC: %s!' % ','.join(['%d:%s' % (x, dt[x]) for x in sorted(dt.keys())]))

		lst = []
		for key in self.ecc_lunlist_info.keys():
			if self.ecc_lunlist_info[key][6] == 'F':
				lst.append(self.ecc_lunlist_info[key][0])
		lst.sort()
		if (len(lst) > self.ifmode_badlun_threshold):
			autompt_exit('IFMODE found %d bad lun: %s!' % (len(lst), ','.join([str(x) for x in lst])))

	def check_fenced_lun_nombr(self):
		if not self.record['fenced_luns_in_mbr'] or self.board['generation'].upper().startswith('G5'):
			return None

		cmd = '%s %s mpt -M -T loglun:%s 2>/dev/null' % (GBLVAR.apptool, self.gopts, self.record['fenced_luns_in_mbr'])
		self.log.info('CHECK fenced lun have no MBR info ...')

		mbr = exeshell(cmd, check = False)
		if not mbr.startswith('No MBR found'):
			autompt_exit('Fenced lun %s have MBR info' % self.record['fenced_luns_in_mbr'])

	def global_option(self):
		self.exitlog = get_tempfile()
		self.gopts += ' --exitlog=%s' % self.exitlog
		self.gopts = ' '.join(self.gopts.split())	# delete redundant blank space

	def add_option(self, opt, outside = False):
		if not opt.startswith('-'):
			autompt_exit("option should start with '-'")

		if opt[0:2] == '--':
			self.opts += ' %s' % opt
		elif opt[:2] == '-t':
			if not opt[2:]:
				autompt_exit('option -t require argument')

			if outside:
				self.t_opt = opt
			else:
				self.opts += ' -t loglun:%s' % opt[2:]
		else:
			self.opts += ' %s %s' % (opt[0:2], opt[2:])
		self.opts = self.opts.strip(' ')

	def check_temperature(self):
		if '-o' not in self.mode:
			return None
		if (int(self.record['max_controller_temp']) < int(self.board['controller_temp_threshold_lo']) and \
			int(self.record['max_flash_temp']) < int(self.board['flash_temp_threshold_lo']) and \
			int(self.record['max_board_temp']) < int(self.board['board_temp_threshold_lo'])):
			whyexit = "temperature don't meet upper limit: %s,%s,%s, please redo init" % \
				(self.record['max_controller_temp'], self.record['max_flash_temp'], self.record['max_board_temp'])
			autompt_exit('check temperature error, FW:%s FM:%s, %s' % (self.hw_attr['Firmware'], self.mode, whyexit))

	def do_mpt(self, logname=None, whatdo=None):
		global GBLVAR
		global RNDOPT

		self.log = logger(logname)
		self.log.info('-'*64 + '\n',raw=True)
		self.log.info(whatdo)

		GBLVAR.inflight_log = self.log
		GBLVAR.inflight_device = self.device
		beacon(self.device, 'off')

		self.db = product_database(self.device, self.log, nodatabase=RNDOPT.nodatabase)
		if not RNDOPT.nodatabase:
			if RNDOPT.user:
				self.db.check_user(RNDOPT.user)
			else:
				self.db.check_user(raw_input('Please enter your name: '))

		if RNDOPT.initloops:
			doloops = RNDOPT.initloops
		else:
			doloops = raw_input('Please input INIT buring loops (30 or 50): ')
		if doloops.isdigit():
			doloops = int(doloops, 10)
			if doloops != 30 and doloops != 50:
				autompt_exit('Init loops shoud be 30 or 50!')
			self.add_option('-o%d' % doloops)
			self.set_mode('-o %d' % doloops)
			self.initloops = doloops
		elif doloops[0:6] == 'justdo':
			if not doloops[6:].isdigit():
				autompt_exit('Pelase input justdo[digit]')
			doloops = int(doloops[6:], 10)
			self.add_option('-o%d' % doloops)
			self.set_mode('-o %d' % doloops)
			self.initloops = doloops
		elif doloops == 'none' or doloops == 'prettygirl':
			self.initloops = 0
			pass
		else:
			autompt_exit("Invaid input '%s', please input digit!" % doloops)

		ifmode = manage_ifmode()
		if self.t_opt:
			ifmode.add_option(self.t_opt, True)
		ifmode.add_device(node2alpha(self.device))
		self.flash, self.boards, self.board, self.hw_attr, self.mf_lunlist, self.af_lunlist, self.using_lunlist, self.ecc_lunlist_info = ifmode.do_ifmode(mmpt=self)
		self.gopts = ifmode.gopts
		GBLVAR.inflight_db = self.db

		self.mpt_badlun_threshold = len(self.board['extend_Tphylun'])/2
		if self.mpt_badlun_threshold <= 0 or self.mpt_badlun_threshold > 128:
			autompt_exit('BUGggggggg %d' % self.mpt_badlun_threshold)

		self.check_ifmode_badluns()
		self.db.push_badlun(self.mf_lunlist, 'manual')
		self.db.push_badlun(self.af_lunlist, 'auto', self.ecc_lunlist_info)
		self.df_lunlist = self.db.get_badlun();
		self.df_lunlist.sort()

		# mpt command and options
		self.global_option()
		for k, s in zip(['mbr_version', 'burnin_ecc_limit'], ['--mbr-version', '--sorting-ecc-limit']):
			if self.board[k] != 'default':
				self.add_option('%s=%s' % (s, self.board[k]))
		if RNDOPT.fblocks:
			amp = int(self.flash['blk_num'])/RNDOPT.fblocks
			self.board['capacity'] = '%dGB' % (int(self.board['capacity'].strip('GB'))/amp)
			self.rndinfo += ' fblocks=%d' % (RNDOPT.fblocks)
		if RNDOPT.ifclock:
			self.rndinfo += ' ifclock=%d' % (RNDOPT.ifclock)
		if RNDOPT.downgrade:
			self.rndinfo += ' downgrade-frequency'
		if not RNDOPT.constoverprovision:
			self.add_option('-c%s' % self.board['capacity'])
		self.add_option('-Tphylun:%s' % self.board['Tphylun'])
		if self.df_lunlist:
			self.add_option('-t%s' % ','.join([str(x) for x in self.df_lunlist]))
		self.add_option('--raid-stripes=%s' % self.board['raidgroup'])
		logfile = get_tempfile()
		recordfile = get_tempfile()
		self.add_option('--logfile=%s' % logfile)
		self.add_option('--record=%s' % recordfile)
		self.add_option('--disable-ecc-histogram')
		self.add_option('--check-bad-luns=%s' % self.mpt_badlun_threshold)
		self.add_option('--sorting-prefix-string="[%s %s %s]"' % (GBLVAR.autompt_version, node2alpha(self.device), self.hw_attr['SerialNumber']))
		self.add_option('--temperature-threshold=%s,%s,%s' % \
			(self.board['controller_temp_threshold_hi'], self.board['flash_temp_threshold_hi'], self.board['board_temp_threshold_hi']))
		if self.board['write_nor_mbr'].lower() == 'yes':
			self.add_option('--write-nor-mbr')
		cmd = '%s %s mpt %s' % (GBLVAR.apptool, self.gopts, self.opts)

		#self.db.reset_counter('init', 13)
		#self.db.reset_counter('verify', 0)

		self.log.info('FORMAT ...')
		self.log.info(cmd)
		stime = long(time.time())
		if os.system(cmd):
			try:
				lines = []
				for line in fileinput.input(self.exitlog):
					lines.append(line.strip('\n'))
				whyexit = '\n'.join(lines)
			except:
				self.log.info('operate exitlog file %s fail' % self.exitlog)
			autompt_exit('run mpt error, FW:%s FM:%s, %s' % (self.hw_attr['Firmware'], self.mode, whyexit))
		etime = long(time.time())
		self.log.info('fomart took %s (%s)' % (timespan(etime-stime), etime-stime))

		self.parse_mpt_recordfile(recordfile)
		self.check_temperature()
		self.parse_read_mbr()
		self.check_fenced_lun_nombr()

		nlst = self.record['fenced_luns_in_mbr'].replace(',', ' ').split()
		if (len(nlst) >= self.mpt_badlun_threshold):
			autompt_exit('Found %d bad lun: %s!' % (len(nlst), ','.join(nlst)))

		# [loglun, phylun, channel, thread, lun, SumECC, FencedOrNot, MaxECC, NumOfMaxECC]'
		info = ''
		for lun in sorted(self.ecc_lunlist_info.keys()):
			lst = self.ecc_lunlist_info[lun]
			if lst[6] == 'N':
				info += ' %s,%s,%s,%s' % (lst[0], lst[5], lst[7], lst[8])
		ifmode_ecc = info.strip()

		commitinitloops = self.initloops
		if RNDOPT.cheatinitloops:
			commitinitloops = RNDOPT.cheatinitloops
			self.rndinfo += ' cheatinitloops=%d' % (RNDOPT.cheatinitloops)

		self.db.commit_success_format(firmware = self.hw_attr['Firmware'].strip(),
					capacity = self.board['capacity'].strip().strip('GB'),
					type = 'init',
					inc = commitinitloops,
					product_type=self.board['product_type'],
					dynamic_bad_blocks = self.record['dynamic_bad_blocks'],
					max_controller_temp = self.record['max_controller_temp'],
					max_flash_temp = self.record['max_flash_temp'],
					max_board_temp = self.record['max_board_temp'],
					mbr_version = self.record['mbr_version'][2:],
					format_mode = self.mode,
					manual_fenced_luns = '%s' % ','.join([str(x) for x in self.mf_lunlist]),
					auto_fenced_luns = '%s' % ','.join([str(x) for x in self.af_lunlist]),
					fenced_luns_in_mbr = self.record['fenced_luns_in_mbr'],
					bad_mbrblocks = self.record['bad_mbrblocks'],
					ifmode_ecc = ifmode_ecc,
					flash_clock = self.board['flash_ifclock'].replace('default', ''),
					rndinfo = self.rndinfo.strip()
					)

#-----------------------------------------------------------------------------------------------------
def usage():
	print 'Usage:'
	print '\t%s [rnd-options] <mode> [-tFL1,FL2...] <devnodes>' % sys.argv[0].strip('./')

	print 'mode:'
	print '\t-n, format new devices'
	print '\t-u, format used devices with resident MBR info'
	print '\t-f, format used devices without resident MBR info'
	print "\t-l, list devices"
	print "\t-i, do ifmode then exit"
	print "\t-M, display MBR then exit"
	print "\t-B, display BBT then exit"
	print "\t-w, display board details then exit"
	print "\t-d -0|-1|-2, display the status of all the packages on the subcard, 0->word 1->highbyte 2->lowbyte"

	print 'FL1,FL2...:'
	print "\tFence logical luns"

	print 'devnodes:'
	print "\ta b c ..."

	print 'rnd-options:'
	print "\tNOTE: Only for R&D users. Make sure understand them accurately when you use those options!!!"
	print '\t--fblocks=N, use N instead of flash actual blocks number'
	print '\t--bdfile=FILE, use FILE instead of default board file'
	print "\t--nodatabase, don't commit to database"
	print '\t--initloops=N, set init loops'
	print '\t--ifmodeloops=N, set ifmode loops instead of default value 5'
	print '\t--autobdtype, auto select board type'
	print '\t--forceautobdtype=N, if autobdtype is set but one more board are matched, use this option to select one'

def main():
	logname = ''
	whatdo = sys.argv

	if (len(sys.argv) < 2):
		usage()
		sys.exit(1)

	if sys.argv[1].startswith('-h'):
		usage()
		sys.exit(0)

	# parse rnd options
	global RNDOPT
	n = 1
	for opt in sys.argv[1:]:
		if not opt.startswith('--'):
			break
		n += 1

		try:
			if opt.startswith('--fblocks'):
				RNDOPT.fblocks = opt.split('=')[1]
				if not RNDOPT.fblocks:
					raise IndexError
				if not RNDOPT.fblocks.isdigit():
					autompt_exit('rnd option --fblocks should be digit')
				RNDOPT.fblocks = int(RNDOPT.fblocks)
				if RNDOPT.fblocks <= 0:
					autompt_exit('rnd option --fblocks should large than 0')
			elif opt.startswith('--constoverprovision') or opt[:5] == '--cop':
				RNDOPT.constoverprovision = True
			elif opt.startswith('--ifclock'):
				RNDOPT.ifclock = opt.split('=')[1]
				if not RNDOPT.ifclock:
					raise IndexError
				if not RNDOPT.ifclock.isdigit():
					autompt_exit('rnd option --ifclock should be digit')
				RNDOPT.ifclock = int(RNDOPT.ifclock)
				if RNDOPT.ifclock < 4 or RNDOPT.ifclock > 7:
					autompt_exit('rnd option --ifclock should between 4 and 7')
			elif opt.startswith('--bdfile'):
				RNDOPT.bdfile = opt.split('=')[1]
				if not RNDOPT.bdfile:
					raise IndexError
				if not os.path.exists(RNDOPT.bdfile):
					autompt_exit('No such file: %s' % RNDOPT.bdfile)
			elif opt.startswith('--flashlib'):
				RNDOPT.flashlib = opt.split('=')[1]
				if not RNDOPT.flashlib:
					raise IndexError
				if not os.path.exists(RNDOPT.flashlib):
					autompt_exit('No such file: %s' % RNDOPT.flashlib)
			elif opt.startswith('--nodatabase') or opt[:6] == '--nodb':
				RNDOPT.nodatabase = True
			elif opt.startswith('--initloops'):
				RNDOPT.initloops = opt.split('=')[1]
				if not RNDOPT.initloops:
					raise IndexError
			elif opt.startswith('--ifmodeloops'):
				RNDOPT.ifmodeloops = opt.split('=')[1]
				if not RNDOPT.ifmodeloops:
					raise IndexError
				if not RNDOPT.ifmodeloops.isdigit():
					autompt_exit('rnd option --ifmodeloops is not digit')
				RNDOPT.ifmodeloops = int(RNDOPT.ifmodeloops)
				if RNDOPT.ifmodeloops <= 0:
					autompt_exit('rnd option --ifmodeloops should > 0')
			elif opt.startswith('--autobdtype'):
				RNDOPT.autobdtype = True
			elif opt.startswith('--forceautobdtype'):
				RNDOPT.forceautobdtype = opt.split('=')[1]
				if not RNDOPT.forceautobdtype:
					raise IndexError
				RNDOPT.forceautobdtype = int(RNDOPT.forceautobdtype)
				if (RNDOPT.forceautobdtype <= 0):
					autompt_exit('rnd option --forceautobdtype should > 0')
			elif opt.startswith('--skipfirmwarecheck') or opt[:6] == '--nocf':
				RNDOPT.skipfirmwarecheck = True
			elif opt.startswith('--forcelastfirmware'):
				RNDOPT.forcelastfirmware = True
			elif opt.startswith('--nocheckcounter') or opt[:6] == '--nocc':
				RNDOPT.nocheckcounter = True
			elif opt.startswith('--user'):
				RNDOPT.user = opt.split('=')[1].strip()
				if not RNDOPT.user:
					raise IndexError
			elif opt.startswith('--cheatinitloops'):
				RNDOPT.cheatinitloops = opt.split('=')[1]
				if not RNDOPT.cheatinitloops:
					raise IndexError
				if not RNDOPT.cheatinitloops.isdigit():
					autompt_exit('rnd option --cheatinitloops is not digit')
				RNDOPT.cheatinitloops = int(RNDOPT.cheatinitloops)
				if RNDOPT.cheatinitloops <= 0:
					autompt_exit('rnd option --cheatinitloops should > 0')
			elif opt.startswith('--forcebdname'):
				RNDOPT.forcebdname = opt.split('=')[1]
				if not RNDOPT.forcebdname:
					raise IndexError
			elif opt.startswith('--downgrade'):
				RNDOPT.downgrade = True
			elif opt.startswith('--quiet'):
				RNDOPT.quiet = True
			elif opt.startswith('--noupdatecps'):
				RNDOPT.autocps = False
			else:
				autompt_exit("Don't support this rnd option: %s" % opt)
		except IndexError:
			autompt_exit('Invalid rnd option: %s' % opt)

	# select mode option
	try:
		if sys.argv[n] in ('-n', '-u', '-f'):
			m = manage_mpt()
			m.add_option(sys.argv[n], True)
			m.set_mode(sys.argv[n])
		elif sys.argv[n][0:2] in ('-i', '-M', '-B', '-w', '-d'):
			m = manage_ifmode()
			m.set_mode(sys.argv[n])
		elif sys.argv[n] in ('-l'):
			m = manage_listdev()
		else:
			autompt_exit('No such mpt mode %s' % sys.argv[n])
	except IndexError:
		usage()
		sys.exit(1)

	# other options
	n += 1
	for opt in sys.argv[n:]:
		if opt.startswith('-'):
			m.add_option(opt, True)
			n += 1
		else:
			break
	devices = sys.argv[n:]

	# parse device
	if m.name == 'MPT':
		if len(devices) != 1:
			autompt_exit('MPT needs exactly one device')
		m.add_device(devices[0])
		logname = '%s_mptlog_%s' % (gethostname(), devices[0])
		dox = m.do_mpt
	elif m.name == 'IFMODE':
		if len(devices) != 1:
			autompt_exit('IFMODE needs exactly one device')
		m.add_device(devices[0])
		logname = '%s_mptlog_%s' % (gethostname(), devices[0])
		dox = m.do_ifmode
	elif m.name == 'LISTDEV':
		for c in devices:
			m.add_device(c)
		logname = '%s_mptlog' % gethostname()
		dox = m.do_listdev
	else:
		autompt_exit('BUG')

	install()
	dox(logname = 'LOGS/%s' % logname, whatdo = ' '.join(whatdo))
	if m.name == 'IFMODE' and RNDOPT.quiet:
		if m.af_lunlist:
			autompt_exit('Factory Test Fail!')
		else:
			GBLVAR.inflight_log.success('Factory Test Success!')
	m.log.close()
	uninstall()

#-----------------------------------------------------------------------------------------------------
try:
	# global variables
	# NOTE! don't do other things before the following code
	GBLVAR = gbl_variables()
	RNDOPT = rnd_options()

	r,o = commands.getstatusoutput('git log | head -n1')
	line = o.split()
	if line[0] == 'commit':
		GBLVAR.autompt_version = line[1][0:8]

	# main function
	main()
except KeyboardInterrupt:
	autompt_exit('Press ctrl+c to exit')
finally:
	uninstall()
	rm_tempfiles()

# END
#-----------------------------------------------------------------------------------------------------
