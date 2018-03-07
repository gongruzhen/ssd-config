#!/usr/bin/python -u

# init david.miao 20160617

import os
import re
import sys
import time
import random
import signal
import getopt
import commands
import thread
from socket import gethostname

#-----------------------------------------------------------------------------------------------------
def qctool_exit(info):
	# NOTE! All functions called by me can't use qctool_exit, or it will trap in dead recursion loop
	try:
		raise Exception
	except:
		f = sys.exc_info()[2].tb_frame.f_back
	func = f.f_code.co_name
	lineno = f.f_lineno

	ss = long(time.time()) - mdev.stime

	if mdev.devnode:
		mdev.beacon(light=True, no_call_qctool_exit=True)

	if mdev.log:
		mdev.log.error('%s() +%d %ld: %s' % (func, lineno, ss, info))
	else:
		print '\033[0;1;31m[%s %s() +%d %ld]. %s\033[0m' % (mdev.qc_version, func, lineno, ss, info)

	if mdev.db and not mdev.ncfi:
		mdev.db.commit_failure(info)

	sys.exit(23)

def exeshell(cmd, check = True):
	r,o = commands.getstatusoutput(cmd)
	if check and r != 0:
		qctool_exit("execute shell command \'%s\' error: code=%d, %s" % (cmd, r>>8, o))
	return o

def timespan(sec):
	sh = ''
	sm = ''
	ss = ''

	h = sec / 3600
	m = (sec % 3600) / 60
	s = sec % 60

	if h:
		sh = '%d hours' % h
	if m:
		sm = '%d minutes' % m
	if s:
		ss = '%d seconds' % s

	ts = '%s %s %s' % (sh, sm, ss)
	return ' '.join(ts.split())

#-----------------------------------------------------------------------------------------------------
class logger:
	def __init__(self, name, prefix=''):
		self.name = name
		if prefix:
			self.prefix = '%s' % prefix
		self.filehandler = open(self.name, 'a', buffering=0)

	def __del__(self):
		self.filehandler.close()

	def close(self):
		self.filehandler.close()

	def flush(self):
		self.filehandler.flush()

	def add_prefix(self, p):
		self.prefix += ' %s' % p
		self.prefix = self.prefix.strip()

	def info(self, info, raw=False, xlog=True, xprint=True, nolf=False):
		if not raw:
			ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
			if xprint:
				if nolf:
					print '===> %s %s, %s' % (self.prefix, ts, info),
					sys.stdout.flush()
				else:
					print '===> %s %s, %s' % (self.prefix, ts, info)
			if xlog:
				if nolf:
					self.filehandler.write('===> %s %s, %s' % (self.prefix, ts, info))
					self.filehandler.flush()
				else:
					self.filehandler.write('===> %s %s, %s\n' % (self.prefix, ts, info))
		else:
			if xprint:
				print info,
			if xlog:
				self.filehandler.write('%s' % info)

	def debug(self, debug):
		ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		print '===> \033[0;1;34m%s %s DEBUG\033[0m, %s' % (self.prefix, ts, debug)
		self.filehandler.write('===> %s %s DEBUG, %s\n' % (self.prefix, ts, debug))

	def warn(self, warn):
		ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		print '===> \033[0;1;33m%s %s WARNNING\033[0m, %s' % (self.prefix, ts, warn)
		self.filehandler.write('===> %s %s WARNNING, %s\n' % (self.prefix, ts, warn))

	def error(self, error, raw=False):
		if not raw:
			ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
			print '===> \033[0;1;31m%s %s ERROR\033[0m, %s' % (self.prefix, ts, error)
			self.filehandler.write('===> %s %s ERROR, %s\n' % (self.prefix, ts, error))
		else:
			print '\033[0;1;31mERROR %s\033[0m' % error.strip()
			self.filehandler.write('ERROR %s' % error)

	def success(self, success):
		ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		print '===> \033[0;1;32m%s %s SUCCESS\033[0m, %s' % (self.prefix, ts, success)
		self.filehandler.write('===> %s %s SUCCESS, %s\n' % (self.prefix, ts, success))

	def checkpoint(self, checkpoint):
		ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
		print '===> \033[0;1;35m%s %s CHECKPOINT\033[0m, %s' % (self.prefix, ts, checkpoint)
		self.filehandler.write('===> %s %s CHECKPOINT, %s\n' % (self.prefix, ts, checkpoint))

#-----------------------------------------------------------------------------------------------------
class product_database:
	def __init__(self, log):
		self.log = log
		self.user = ''
		self.sn = ''
		self.bdtype = ''
		self.init_loops = 0
		self.hostname = gethostname()

	def stage2_init(self, m):
		self.m = m
		self.devnode = self.m.devnode
		self.qc_version = self.m.qc_version

	def curl(self, ccmd, retry=True):
		r,o = commands.getstatusoutput('curl %s 2>/dev/null' % ccmd)
		if not retry:
			return (r, o)
		else:
			for loop in range(3):
				if r == 0 and o.lower().find('error') == -1:
					return (r, o)
				time.sleep(1)
			return (r, o)

	def check_user(self):
		self.log.info('Check user ...')
		self.user = raw_input('Please enter your name: ').strip()

		ccmd = '-k https://www.shannon-data.com/inventory/users/checkExist?uid=%s' % self.user
		ret = self.curl(ccmd)
		if ret[0] != 0 or ret[1] != '{"status":"ok"}':
			qctool_exit('Fail to find user %s: r=%s c=%s' % (self.user, ret[0], ret[1]))

	def check_board(self, sn):
		self.log.info('Check board in inventory ...')

		self.sn = sn.strip()
		ccmd = '-k https://www.shannon-data.com/inventory/mboards/checkExist?no=%s' % self.sn
		ret = self.curl(ccmd)
		if ret[0] != 0 or ret[1] != '{"status":"ok"}':
			qctool_exit('Fail to find board %s in inventory: r=%s c=%s' % (self.sn, ret[0], ret[1]))

	def obtain(self, wh, type):
		if not self.sn:
			qctool_exit('BUGggggggggg user=%s sn=%s' % (self.user, self.sn))

		cmd = 'curl -k https://www.shannon-data.com/inventory/mboards/%s?no=%s\&type=%s 2>/dev/null' % (wh, self.sn, type)
		for retry in range(3):
			(status, value) = commands.getstatusoutput(cmd)
			if status == 0:
				break
			time.sleep(1)
		if status != 0:
			qctool_exit('obtain %s from inventory error' % self.type)
		return value

	def obtain_boardtype(self):
		self.bdtype = self.obtain('getInfo', 'product_type')
		return self.bdtype

	def obtain_init_loops(self):
		self.init_loops = self.obtain('queryCounter', 'init')
		if not self.init_loops.isdigit():
			qctool_exit('obtain error init_loops from inventory: %s' % self.init_loops)
		self.init_loops = int(self.init_loops)
		return self.init_loops

	def obtain_verify_hours(self):
		verify_hours = self.obtain('queryCounter', 'verify')
		if not verify_hours.isdigit():
			qctool_exit('obtain error verify_hours from inventory: %s' % verify_hours)
		return int(verify_hours)

	def commit_failure(self, info):
		# XXX: this function only called by qctool_exit
		# DONOT use qctool_exit() in this function, or it maybe trap in dead loop
		if not self.user or not self.sn:
			return None

		line = 'no=%s&person=%s&note=QC %s FAIL! HT:%s(%s) TS:%s SS:%ld %s' % \
			(self.sn, self.user, self.m.whatdo.upper(), self.hostname, \
			 self.qc_version, time.strftime("%H%M%S",time.localtime()), long(time.time())-self.m.stime, info[0:200])
		cmd = 'curl -k -d "%s" https://www.shannon-data.com/inventory/mboards/assembly 2>/dev/null' % line.replace(' ', '%20')

		self.log.info('Commit failure status to DB: %s' % cmd, xprint=False)
		for retry in range(3):
			r,o = commands.getstatusoutput(cmd)
			if r == 0 and o == '{"status":"ok"}':
				break
			time.sleep(1)
		if r != 0 or o != '{"status":"ok"}':
			self.log.error('commit failure info to inventory error: %s' % cmd)

	def commit_ship_success(self, info):
		if not self.user or not self.sn:
			qctool_exit('BUGggggggggg user=%s sn=%s' % (self.user, self.sn))

		line = 'no=%s&person=%s&firmware_tag=%s&capacity=%s&op=%s&model_id=%s&note=QC SHIP PASS! HT:%s(%s) TS:%s SS:%ld %s' % \
			(self.sn, self.user, self.m.sysfs['firmware_build'], self.m.sysfs['user_capacity_gb'], self.m.sysfs['overprovision'], \
			 self.m.sysfs['model'], self.hostname, self.qc_version, time.strftime("%H%M%S",time.localtime()), long(time.time())-self.m.stime, info[0:200])
		cmd = 'curl -k -d "%s" https://www.shannon-data.com/inventory/mboards/assembly 2>/dev/null' % line.replace(' ', '%20')

		self.log.info('Commit ship success to DB: %s' % cmd, xprint=False)
		for retry in range(3):
			r,o = commands.getstatusoutput(cmd)
			if r == 0 and o == '{"status":"ok"}':
				break
			time.sleep(1)
		if r != 0 or o != '{"status":"ok"}':
			qctool_exit('commit ship info error: %s' % cmd)
		self.log.success(info)

	def commit_verify_success(self, info):
		if not self.user or not self.sn:
			qctool_exit('BUGggggggggg user=%s sn=%s' % (self.user, self.sn))

		line = 'no=%s&person=%s&firmware_tag=%s&capacity=%s&op=%s&type=%s&inc=%d&note=QC VERIFY PASS: HT:%s(%s) TS:%s SS:%ld %s' % \
			(self.sn, self.user, self.m.sysfs['firmware_build'], self.m.sysfs['user_capacity_gb'], \
			 self.m.sysfs['overprovision'], 'verify', self.m.verify_hours, \
			 self.hostname, self.qc_version, time.strftime("%H%M%S",time.localtime()), long(time.time())-self.m.stime, info[0:200])
		cmd = 'curl -k -d "%s" https://www.shannon-data.com/inventory/mboards/assembly 2>/dev/null' % line.replace(' ', '%20')

		self.log.info('Commit verify success to DB: %s' % cmd, xprint=False)
		looptime = 0
		while True:
			r,o = commands.getstatusoutput(cmd)
			if r == 0 and o == '{"status":"ok"}':
				break
			if (looptime % 3600 == 0):
				self.log.info("Maybe network error: %s. Please check, but don't shutdown! %s seconds. curlcmd: %s" % \
				(o, looptime, cmd))
			time.sleep(10)
			looptime += 10
		self.log.success(info)

#-----------------------------------------------------------------------------------------------------
class boards_parser:
	def __init__(self, filename = '../board'):
		self.boards = {}
		self.rawboards = {}
		self.filename = filename
		self.product_type_list = []

	def extend_number(self, nstr):
		m = re.match("^(\d+)$", nstr)
		n = re.match("^(\d+)-(\d+)$", nstr)
		if m:
			lst = [int(m.group(1))]
		elif n:
			lst = range(int(n.group(1)), int(n.group(2)) + 1)
		else:
			qctool_exit("extend_number %s is invalid format!" % nstr)
		return lst

	def parse(self):
		try:
			fh = open(self.filename, 'r')
		except:
			qctool_exit('open file %s error!' % self.filename)
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

			if line.startswith('#') or not line:
				continue

			if line.startswith('[G'):
				boardtype=line.strip('[]')
				self.boards[boardtype]={}
				self.boards[boardtype]['name'] = boardtype
				self.rawboards[boardtype] = line

				m = re.match("G(\d+)[I]([FAHDSMNUB]\d+)-", boardtype)
				if not m:
					qctool_exit('board name %s is nonstandard' % boardtype)
				self.boards[boardtype]['product_type'] = m.group(2)
				if self.boards[boardtype]['product_type'] in self.product_type_list:
					qctool_exit('repeated product_type: %s' % self.boards[boardtype]['product_type'])
				self.product_type_list.append(self.boards[boardtype]['product_type'])
				continue

			self.rawboards[boardtype] += '\n%s' % line
			line = line.split('=')
			if line[0] == 'flash_id':
				if 'and' not in line[1]:
					self.boards[boardtype]['flash_id'] = line[1].strip()
					self.boards[boardtype]['flash_id_ext'] = 'NotMixedFlashCard'
				else:
					mixid = line[1].split('and')
					self.boards[boardtype]['flash_id'] = mixid[0].strip();
					self.boards[boardtype]['flash_id_ext'] = mixid[1].strip();
			elif line[0] in ('flash_temp_threshold', 'board_temp_threshold'):
				v = line[1].split(',')
				if (len(v) != 2):
					qctool_exit('%s has nonstandard key: %s' % (self.boards[boardtype]['name'], line[1]))
				self.boards[boardtype]['%s_lo' % line[0]] = v[0]
				self.boards[boardtype]['%s_hi' % line[0]] = str(int(v[1]) + 10)
			elif line[0] == 'controller_temp_threshold':
				v = line[1].split(',')
				if (len(v) != 2):
					qctool_exit('%s has nonstandard key: %s' % (self.boards[boardtype]['name'], line[1]))
				self.boards[boardtype]['%s_lo' % line[0]] = v[0]
				self.boards[boardtype]['%s_hi' % line[0]] = str(int(v[1]) + 7)
			elif line[0] == 'Tphylun':
				self.boards[boardtype][line[0]] = line[1]

				self.boards[boardtype]['extend_Tphylun'] = []
				for s in line[1].split(','):
					self.boards[boardtype]['extend_Tphylun'].extend(self.extend_number(s))
				self.boards[boardtype]['extend_Tphylun'].sort()
			elif line[0] == 'capacity':
				m = re.match('(\d+)GB', line[1])
				if not m:
					qctool_exit('BUGggggggggg!')
				self.boards[boardtype]['__capacity__'] = m.group(1)
				self.boards[boardtype][line[0]] = line[1]
			elif line[0] == 'ecapacity':
				self.boards[boardtype]['ecapacity'] = []
				self.boards[boardtype]['__ecapacity__'] = []
				if line[1].lower().startswith('none'):
					continue
				for c in line[1].split(','):
					m = re.match('(\d+)GB', c)
					if not m:
						qctool_exit('BUGggggggggg')
					self.boards[boardtype]['__ecapacity__'].append(m.group(1))
					self.boards[boardtype]['ecapacity'].append('%sGB' % m.group(1))
			elif line[0] == 'eop':
				self.boards[boardtype]['eop'] = []
				if not line[1].lower().startswith('none'):
					self.boards[boardtype]['eop'] = line[1].split(',')
				if 2*len(self.boards[boardtype]['ecapacity']) != len(self.boards[boardtype]['eop']):
					qctool_exit('BUGggggggggg')
			else:
				self.boards[boardtype][line[0]] = line[1]

	def designated_board(self, bdtype):
		self.parse()
		for type in self.boards.keys():
			if self.boards[type]['product_type'] == bdtype:
				return self.boards[type], self.rawboards[type]
		qctool_exit('board file has no such board %s' % bdtype)

class flashs_parser():
	def __init__(self, filename = '../flash'):
		self.flashs = {}
		self.filename = filename
		self.id2partno = {}

	def parse(self):
		try:
			fh = open(self.filename, 'r')
		except:
			qctool_exit('open file %s error!' % self.filename)
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
					qctool_exit('repeated flash partno: %s' % partno)
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
			qctool_exit('No such partno in flashlib: %s' % id)
		return self.flashs[partno]

#-----------------------------------------------------------------------------------------------------
class manage_device():
	def __init__(self, cmds):
		self.shannon_format = './shannon/shannon-format'
		self.shannon_status = './shannon/shannon-status'
		self.shannon_beacon = './shannon/shannon-beacon'
		self.shannon_detach = './shannon/shannon-detach'
		self.shannon = './shannon/shannon.ko'
		self.shannon_modelid = './modelid/modify_modelid'

		self.qc_version = 'Undetermined'
		r,o = commands.getstatusoutput('git log | head -n1')
		line = o.split()
		if line[0] == 'commit':
			self.qc_version = line[1][0:8]
		self.hostname = gethostname()

		self.cmds = cmds
		self.parse_options()

		self.name = 'ManageDevice'
		self.devnode = 'df%s' % self.device
		self.cdevnode = 'sct%s' % self.device

		self.status = {}
		self.sysfs = {}
		self.statistics = {}
		self.mbr = {}
		self.rawstatus = ''
		self.rawstatistics = ''
		self.rawsysfs = ''
		self.rawmbr = ''
		self.rawboard = ''
		self.displayinfo = {}

		self.log = logger('../LOGS/%s_qclog_%s' % (self.hostname, self.device), '%s(%s)' % (self.hostname, self.qc_version))
		self.log.info('-'*64 + '\n',raw=True)
		self.log.info('%s\n' % ' '.join(sys.argv), raw=True)
		self.log.add_prefix('%s' % self.whatdo.upper())
		self.log.add_prefix('%s' % self.device)

		self.bglog = logger('../LOGS/%s_qcbglog_%s' % (self.hostname, self.device), '%s(%s)' % (self.hostname, self.qc_version))
		self.bglog.info('-'*64 + '\n', xprint=False, raw=True)
		self.bglog.info('%s\n' % ' '.join(sys.argv), xprint=False, raw=True)
		self.bglog.add_prefix('%s' % self.whatdo.upper())
		self.bglog.add_prefix('%s' % self.device)

		self.sgcfg = {}
		self.fwtag = {}
		self.board = {}
		self.flash = {}
		self.logicss = 0

		self.db = product_database(self.log)
		self.common_counter = 0
		self.vendor = ''
		self.verify_hours = 0
		self.stime = long(time.time())

	def parse_options(self):
		self.ncfi = False
		self.boardfile = '../board'
		self.fwtagfile = '../fwtag'
		self.sgcfgfile = './sgcfg'
		self.forcelastfirmware = False
		self.downgrade = False
		self.disable_reconfig = False
		self.skipfirmwarecheck = False
		self.ship_cheat_verify_hours = None
		self.ship_cheat_init_loops = None

		opts, args = getopt.gnu_getopt(self.cmds, 'ABCDEFGHI:J:', ['xboard', 'xfwtag', 'xsgcfg', \
			'nocommitfailinfo', 'forcelastfirmware', 'downgrade',\
			'disablereconfig', 'skipfirmwarecheck', 'shipcheatverifyhours=', 'shipcheatinitloops='])
		for name, value in opts:
			if name in ('-A', '--xboard'):
				self.xboard = '../xboard'
			elif name in ('-B', '--xfwtag'):
				self.xfwtag = '../.xfwtag'
			elif name in ('-C', '--xsgcfg'):
				self.xsgcfg = './.xsgcfg'
			elif name in ('-D', '--nocommitfailinfo'):
				self.ncfi = True
			elif name in ('-E', '--forcelastfirmware'):
				self.forcelastfirmware = True
			elif name in ('-F', '--downgrade'):
				self.downgrade = True
			elif name in ('-G', '--disablereconfig'):
				self.disable_reconfig = True
			elif name in ('-H', '--skipfirmwarecheck'):
				self.skipfirmwarecheck = True
			elif name in ('-I', '--shipcheatverifyhours'):
				self.ship_cheat_verify_hours = value
			elif name in ('-J', '--shipcheatinitloops'):
				self.ship_cheat_init_loops = value

		try:
			if args[0] not in ('help', 'verify', 'ship', 'format', 'list', 'status', 'statistics', 'sysfs', 'mbr', 'board', 'beacon', 'spec', 'stable', 'model', 'hotplug'):
				usage()
				os._exit(1)
			if args[0] == 'help':
				usage()
				os._exit(0)
			else:
				self.whatdo = args[0]
				self.device = args[1]
		except IndexError:
			usage()
			os._exit(1)

	def prepare_check(self):
		self.log.info('Start prepare check ...')

		for f in (self.shannon, self.shannon_format, self.shannon_status, self.shannon_beacon, self.shannon_detach, self.shannon_modelid):
			if not os.path.exists(f):
				qctool_exit('%s is not exists' % f)

		for exe in ('fio', 'curl', 'blockdev'):
			if os.system('which %s 1>/dev/null 2>&1' % exe):
				qctool_exit('please install %s' % exe)

		if self.whatdo in ('verify', 'ship'):
			self.db.check_user()

	def parse_ini(self, filename):
		try:
			fh = open(filename, 'r')
		except:
			qctool_exit('open file %s error' % filename)
		lines = fh.readlines()
		fh.close()

		outdict = {}
		for line in lines:
			line = line.strip()
			if not line or line.startswith('['):
				continue
			line = line.split('=')
			outdict[line[0]] = line[1].rstrip('.')
		return outdict

	def parse_status(self, tolog=False):
		self.rawstatus = exeshell('%s /dev/%s' % (self.shannon_status, self.cdevnode))
		for line in self.rawstatus.split('\n'):
			idx = line.find(':')
			if idx != -1:
				key = line[0:idx].strip().replace(' ', '')
				val = line[idx+1:].strip()
				self.status[key] = val

		for key in ('PCIBusAddress', 'PCILinkSpeed'):
			self.displayinfo[key] = self.status[key]

		# m = re.match('[pP][cC][iI][eE].*[xX]\s*(\d+)', self.status['PCILinkSpeed'])
		m = re.match('.*[xX]\s*(\d+)', self.status['PCILinkSpeed'])
		if m:
			self.status['PCILinkLanes'] = m.group(1)
		else:
			self.status['PCILinkLanes'] = 'Undetermined'

		if tolog:
			self.log.info('shannon-status', xprint=False)
			for key in sorted(self.status):
				self.log.info('%s: %s\n' % (key, self.status[key]), raw=True, xprint=False)

	def parse_sysfs(self, tolog=False):
		self.rawsysfs = ''
		for rt,dirs,files in os.walk('/sys/block/%s/shannon' % self.devnode):
			for f in files:
				key = f
				val = exeshell('cat %s/%s' % (rt, f))
				if key == 'firmware_build':
					val = val.upper()
				self.sysfs[key] = val
				self.rawsysfs += '%s: %s\n' % (key, val)

		for key in ('serial_number', 'firmware_build', 'overprovision', 'user_capacity'):
			val = self.sysfs[key]
			if key == 'user_capacity':
				self.sysfs['user_capacity_gb'] = str(long(val)*512/(1000*1000*1000))
				self.displayinfo[key] = '%s (%sGB)' % (val, self.sysfs['user_capacity_gb'])
			self.displayinfo[key] = val

		if tolog:
			self.log.info('shannon sysfs', xprint=False)
			for key in sorted(self.sysfs):
				self.log.info('%s: %s\n' % (key, self.sysfs[key]), raw=True, xprint=False)

	def parse_statistics(self, tolog=False):
		try:
			fh = open('/debug/%s/statistics' % self.devnode, 'r')
		except:
			qctool_exit('open file /debug/%s/statistics error!' % self.devnode)
		lines = fh.readlines()
		fh.close()
		self.rawstatistics = ''.join(lines)

		for line in lines:
			line = line.strip().strip('.')
			if not line or line.startswith('='):
				continue
			line = line.split()
			self.statistics[line[0]] = line[1]

		if tolog:
			self.log.info('shannon statistics', xprint=False)
			for key in sorted(self.statistics):
				self.log.info('%s: %s\n' % (key, self.statistics[key]), raw=True, xprint=False)

	def parse_mbr(self, tolog=False):
		filename = '/debug/%s/mbr' % self.devnode

		try:
			fh = open(filename, 'r')
		except:
			qctool_exit('open file %s error' % filename)
		self.rawmbr = ''.join(fh.readlines())
		fh.close()

		self.mbr = self.parse_ini(filename)
		self.displayinfo['plane_number'] = 2**int(self.mbr['plane_order'])

		if tolog:
			self.log.info('shannon MBR', xprint=False)
			for key in sorted(self.mbr):
				self.log.info('%s: %s\n' % (key, self.mbr[key]), raw=True, xprint=False)

	def insmod(self):
		mode = exeshell('lsmod | grep shannon', False)
		if mode:
			mode = mode.split()[0]
		if mode == 'shannon':
			self.log.info('shannon has been installed')
		else:
			if mode == 'shannon_cdev':
				self.log.info('rmmod shannon-cdev ...')
				exeshell('rmmod shannon_cdev')
				time.sleep(1)
			self.log.info('insmod shannon ...')
			exeshell('insmod %s' % self.shannon)

		if exeshell('grep shannon /proc/modules').find('Loading') != -1:
			self.log.info('Waiting insmod shannon complete ...')
			for i in range(200):
				info = exeshell('grep shannon /proc/modules')
				if info.find('Live') != -1:
					break
				time.sleep(3)
			if i >= 199:
				qctool_exit('Waiting insmod shannon timeout')

		self.log.info('mount debugfs and sysfs')
		os.system('mount -t debugfs debugfs /debug 1>/dev/null 2>&1')
		os.system('mount -t sysfs sysfs /sys 1>/dev/null 2>&1')

		for d in ('/debug/%s' % self.devnode, '/sys/block/%s/shannon' % self.devnode):
			if not os.path.exists(d):
				qctool_exit('%s is not exists' % d)

		# get logical sector size
		self.logicss = int(exeshell('blockdev --getss /dev/%s' % self.devnode))
		if (self.logicss != 512):
			qctool_exit('%s logical sector size should be 512' % self.devnode)

		# parse sysfs info
		self.log.info('parse shannon sysfs')
		self.parse_sysfs(tolog=True)

		self.db.stage2_init(self)
		self.log.add_prefix('[%s]' % self.sysfs['serial_number'])
		self.bglog.add_prefix('[%s]' % self.sysfs['serial_number'])

		if self.whatdo in ('verify', 'ship', 'board'):
			bp = boards_parser(filename=self.boardfile)
			self.db.check_board(self.sysfs['serial_number'])
			self.board, self.rawboard = bp.designated_board(self.db.obtain_boardtype())
			fp = flashs_parser()
			fp.parse()
			self.flash = fp.get_flash(self.board['flash_id'])
			self.log.add_prefix('[%s]' % self.board['product_type'])
			self.bglog.add_prefix('[%s]' % self.board['product_type'])

		# parse shannon status
		self.log.info('parse shannon status')
		self.parse_status(tolog=True)

		# parse statistics
		self.log.info('parse shannon debugfs statistics')
		self.parse_statistics(tolog=True)

		# parse mbr
		self.log.info('parse shannon MBR')
		self.parse_mbr(tolog=True)

		# show displayinfo
		for key in sorted(self.displayinfo.keys()):
			self.log.info('%-16s %s\n' % ('%s:' % key, self.displayinfo[key]), raw=True)

	def parse_fwtag(self):
		self.fwtag = self.parse_ini(self.fwtagfile)

	def parse_sgcfg(self):
		self.sgcfg =  self.parse_ini(self.sgcfgfile)

	def format(self, option=''):
		status = os.system('%s -m -f -y %s -b 512 /dev/%s' % (self.shannon_format, option, self.cdevnode))
		if status != 0:
			qctool_exit('format %s Error' % self.devnode)

	def beacon(self, light=True, no_call_qctool_exit=False):
		if not os.path.exists('/dev/%s' % self.cdevnode):
			return None
		if light:
			status = os.system('%s -l /dev/%s' % (self.shannon_beacon, self.cdevnode))
		else:
			status = os.system('%s -o /dev/%s 1>/dev/null 2>&1' % (self.shannon_beacon, self.cdevnode))
		if not no_call_qctool_exit and status != 0:
			qctool_exit('beacon %s Error' % self.devnode)

	def bg_reconfig(self, fixtime, randtime):
		self.bglog.info('background reconfig start', xprint=False)
		self.bglog.flush()
		count = 1
		self.running_reconfig = True
		while self.start_reconfig:
			status = os.system('%s --recanfig 1020 /dev/%s' % (self.shannon_detach, self.cdevnode))
			if status != 0:
				self.bglog.info('%s trigger reconfig error: %d' % (self.devnode, count), xprint=False)
			else:
				self.bglog.info('%s trigger reconfig count %d finished' % (self.devnode, count), xprint=False)
			self.bglog.flush()
			sleeptime = fixtime + random.randint(0, randtime)
			for n in range(sleeptime):
				if not self.start_reconfig:
					break
				time.sleep(1)
			count += 1
		self.running_reconfig = False

	def check_verify_pass(self):
		# parse all info
		self.log.info('sleep 10 second ...')
		time.sleep(10)
		self.parse_sysfs(tolog=True)
		self.parse_status(tolog=True)
		self.parse_statistics(tolog=True)

		# check invalid ecc
		if self.statistics['ecc_fc_statistics'] != '0':
			qctool_exit('Found %s INVALID ECC VALUE: 0xFC!' % self.statistics['ecc_fc_statistics'])

		# check temperature
		self.log.info('check temperature')
		info = 'INT:%s,%s FLASH:%s,%s BOARD:%s,%s' % \
			(self.sysfs['temperature_int_max'], self.board['controller_temp_threshold_hi'],	\
			self.sysfs['temperature_flash_max'], self.board['flash_temp_threshold_hi'],\
			self.sysfs['temperature_board_max'], self.board['board_temp_threshold_hi'])
		sysfs_temp = ('temperature_board_max', 'temperature_flash_max', 'temperature_int_max')
		limit_temp = ('board_temp_threshold_hi', 'flash_temp_threshold_hi', 'controller_temp_threshold_hi')
		for i,v in enumerate(sysfs_temp):
			if (int(self.sysfs[sysfs_temp[i]]) > int(self.board[limit_temp[i]])):
				qctool_exit('Check temperature Error %s' % info)

		self.log.info('cold down 5 minutes')
		time.sleep(300)

		# check per-lun dynamic bad block
		try:
			fh = open('/debug/%s/lun_statistics' % self.devnode, 'r')
		except:
			qctool_exit('open file /debug/%s/lun_statistics error!' % self.devnode)
		lines = fh.readlines()
		fh.close()

		perlun_dbb = []
		nopss = []
		for line in lines:
			line = line.strip()
			m = re.match('lun\s+(\d+):.*dynamic_bad_blkcnt=(\d+),\s*next_empty_page=(\d+)', line)
			if m:
				lun = int(m.group(1))
				cnt = int(m.group(2))
				if cnt != 0:
					perlun_dbb.append('%d(%d)' % (lun, cnt))
				if (cnt > int(self.sgcfg['perlun_dynamic_bad_blkcnt'])):
					nopss.append('%d(%d)' % (lun, cnt))
		self.log.info('Per-lun dynamic bad block: %s\n' % (' '.join(perlun_dbb)), raw=True, xprint=False)
		if nopss:
			qctool_exit('Too many per-lun dynamic bad blk, limit is %s but: %s' % \
				(self.sgcfg['perlun_dynamic_bad_blkcnt'], ' '.join(nopss)))

		# check total dynamic bad block
		if int(self.statistics['dynamic_bad_blkcnt']) > int(self.sgcfg['dynamic_bad_blkcnt']):
			qctool_exit('Too many total dynamic bad block limit is %s but %s!' % \
				(self.sgcfg['dynamic_bad_blkcnt'], self.statistics['dynamic_bad_blkcnt']))

		# check reconfig
		if self.sysfs['reconfig_support'] == '1' and not self.disable_reconfig:
			if int(self.statistics['total_reconfig_times']) < self.verify_hours:
				qctool_exit('%s just reconfig %s times' % (self.devnode, self.statistics['total_reconfig_times']))
			self.log.info('reconfig %s times' % self.statistics['total_reconfig_times'])

	def doqc(self):
		do = 'qc_%s' % self.whatdo
		getattr(self, do)()

	def qc_init(self):
		self.log.error("This tool don't support qc init")
		sys.exit(1)

	def qc_verify(self):
		self.log.info('Start verify')
		self.beacon(False)

		self.parse_fwtag()
		self.parse_sgcfg()
		self.sgcfg['perlun_dynamic_bad_blkcnt'] = '5'
		self.sgcfg['dynamic_bad_blkcnt'] = '20'

		# check key parameter
		if self.skipfirmwarecheck:
			pass
		elif self.forcelastfirmware:
			if self.sysfs['firmware_build'] != self.fwtag['last_%s' % self.board['firmware_tag']]:
				qctool_exit('last firmware is %s but now is %s' % (self.fwtag['last_%s' % self.board['firmware_tag']], self.sysfs['firmware_build']))
		else:
			if self.sysfs['firmware_build'] != self.fwtag[self.board['firmware_tag']]:
				qctool_exit('Please update firmware from %s to latest %s' % (self.sysfs['firmware_build'], self.fwtag[self.board['firmware_tag']]))

		# check nplane
		if self.board['generation'].startswith('G5') and self.mbr['pseudo_plane'] == '1':
			if self.mbr['plane_count'] != self.board['nplane']:
				qctool_exit('Plane number error! please use "autompt.py -u" with initloops=None to reformat this card')
		elif str(2**int(self.mbr['plane_order'])) != self.board['nplane']:
			qctool_exit('Plane number error! please use "autompt.py -u" with initloops=None to reformat this card')

		# select vendor
		self.vendor = raw_input('\nEnter Vendor (ali or shannon): ').strip()
		if self.vendor == 'ali':
			self.sgcfg['init_loops'] = self.sgcfg['ali_init_loops']
		elif self.vendor == 'shannon':
			self.sgcfg['init_loops'] = self.sgcfg['shannon_init_loops']
		else:
			self.log.error('Invalid Vendor: %s' % self.vendor)
			sys.exit(1)
		self.log.info('Your input vendor is: %s' % self.vendor)

		# check init done
		self.log.info('Check init_loops ...')
		init_loops = self.db.obtain_init_loops()
		if (init_loops < int(self.sgcfg['init_loops'])):
			qctool_exit('init loops %s should be done but %d' % (self.sgcfg['init_loops'], init_loops))

		# input verify hours
		self.verify_hours = raw_input('\nEnter verify hours (default 12): ').strip()
		if not self.verify_hours:
			self.verify_hours = 12
			self.log.info('Use default %d hours' % self.verify_hours)
		elif self.verify_hours.startswith('justdo'):
			if not self.verify_hours[6:].isdigit():
				qctool_exit('Please input justdo[digit]')
			self.verify_hours = int(self.verify_hours[6:])
			self.log.info('You input justdo %d hours' % self.verify_hours)
		elif self.verify_hours.isdigit():
			self.verify_hours = int(self.verify_hours)
			if self.verify_hours < 12 or self.verify_hours > 100:
				qctool_exit('verify hours should between 12 and 100')
			self.log.info('You input %d hours' % self.verify_hours)
		else:
			qctool_exit('You input invalid verify hours')

		# Clear history temperature
		self.log.info('Format %s to clear history temperature' % self.devnode)
		self.format('-c')

		# start backgroud reconfig process if has
		if self.sysfs['reconfig_support'] == '1' and not self.disable_reconfig:
			self.log.info('Try reconfig on front ground ...', nolf=True)
			status = os.system('%s --recanfig 1020 /dev/%s' % (self.shannon_detach, self.cdevnode))
			if status != 0:
				qctool_exit('reconfig fail')
			self.log.info('OK\n', raw=True)
			self.start_reconfig = True
			self.running_reconfig = False
			thread.start_new_thread(self.bg_reconfig, (600, 200))
			while not self.running_reconfig: time.sleep(1)

		runtime1 = int(3600 * int(self.verify_hours) * 0.1)
		runcap2  = 100
		runtime4 = int(3600 * int(self.verify_hours) * 0.1)
		runtime3 = 3600 * self.verify_hours - runtime1 - runtime4

		# Step 1
		self.log.info('QC Verify Test Step 1: Sequential Write %s.' % timespan(runtime1))
		cmd = ' ' .join([\
			'fio',\
			'--name=heavyseqw',\
			'--filename=/dev/%s' % (self.devnode),\
			'--numjobs=1',\
			'--bs=128k',\
			'--ioengine=libaio',\
			'--direct=1',\
			'--randrepeat=0',\
			'--rw=write',\
			'--group_reporting',\
			'--iodepth=128',\
			'--iodepth_batch=64',\
			'--iodepth_batch_complete=64',\
			'--loops=1000',\
			'--time_based',\
			'--runtime=%d' % (runtime1)\
		])
		status = os.system(cmd)
		if status != 0:
			qctool_exit('Sequential write Error.')

		# step 2
		self.log.info('QC Verify Test Step 2: Integrity test %dGB With CRC32.' % runcap2)
		cmd = ' '.join([ \
			'fio',\
			'--name=integrity',\
			'--filename=/dev/%s' % (self.devnode),\
			'--numjobs=1',\
			'--bs=128k',\
			'--ioengine=libaio',\
			'--direct=1',\
			'--randrepeat=0',\
			'--rw=randwrite',\
			'--group_reporting',\
			'--iodepth=128',\
			'--iodepth_batch=64',\
			'--iodepth_batch_complete=64',\
			'--filesize=%sg' % (runcap2),\
			'--verify=crc32c-intel',\
			'--verify_fatal=1',\
			'--verify_backlog=2048'\
			])
		status = os.system(cmd)
		if status != 0:
			qctool_exit('integrity test with CRC32 Error.')

		# step 3
		self.log.info('QC Verify Test Step 3: Heavy workload Full-range Random Mixed Rw %s.' % timespan(runtime3))
		cmd = ' ' .join([\
			'fio',\
			'--name=heavyrwmix',\
			'--filename=/dev/%s' % (self.devnode),\
			'--numjobs=4',\
			'--bsrange=4k-128k',\
			'--ioengine=libaio',\
			'--direct=1',\
			'--randrepeat=0',\
			'--rw=randrw',\
			'--group_reporting',\
			'--iodepth=128',\
			'--iodepth_batch=64',\
			'--iodepth_batch_complete=64',\
			'--loops=1000',\
			'--time_based',\
			'--runtime=%d' % (runtime3)\
		])
		status = os.system(cmd)
		if status != 0:
			qctool_exit('heavy workload Full-range Random Mixed RW Error.')

		# Step 4
		self.log.info('QC Verify Test Step 4: Sequential Read %s' % timespan(runtime4))
		cmd = ' ' .join([\
			'fio',\
			'--name=heavyseqr',\
			'--filename=/dev/%s' % (self.devnode),\
			'--numjobs=1',\
			'--bs=128k',\
			'--ioengine=libaio',\
			'--direct=1',\
			'--randrepeat=0',\
			'--rw=read',\
			'--group_reporting',\
			'--iodepth=128',\
			'--iodepth_batch=64',\
			'--iodepth_batch_complete=64',\
			'--loops=1000',\
			'--time_based',\
			'--runtime=%d' % (runtime4)\
		])
		status = os.system(cmd)
		if status != 0:
			qctool_exit('Sequential Read Error.')

		self.log.info('Stop reconfig thread ...', nolf=True)
		if self.sysfs['reconfig_support'] == '1' and not self.disable_reconfig:
			self.start_reconfig = False
			while self.running_reconfig: time.sleep(1)
		self.log.info('OK!\n', raw=True)

		self.check_verify_pass()

		info = 'MODEL:%s RUNTIME:%d CAP:%sGB DYNBAD:%s STABAD:%s OP:%s TEMP:%s,%s,%s' % \
			(self.sysfs['model'], self.verify_hours, self.sysfs['user_capacity_gb'], \
			 self.statistics['dynamic_bad_blkcnt'], self.statistics['static_bad_blkcnt'], self.sysfs['overprovision'], \
			 self.sysfs['temperature_int_max'], self.sysfs['temperature_flash_max'], self.sysfs['temperature_board_max'])
		self.db.commit_verify_success(info)

	def check_item(self, type, abtype, act, exp, digit=False, digit_reverse_cmp=False):
		self.log.info('Check %2d: %s ...' % (self.common_counter, type), nolf=True)
		self.common_counter += 1
		lst = [type, abtype, act, exp]

		if digit:
			if re.search('\.', act) or re.search('\.', exp):
				a = float(act) * 1000L
				e = float(exp) * 1000L
			else:
				a = long(act)
				e = long(exp)

			if digit_reverse_cmp:
				cmp = (a <= e)
			else:
				cmp = (a >= e)
		else:
			cmp = (act == exp)

		if cmp:
			self.log.info('[%s/%s] PASS\n' % (act, exp), raw=True)
			lst.append('P')
		else:
			self.log.error('[%s/%s]\n' % (act, exp), raw=True)
			lst.append('F')
		return lst

	def qc_ship(self):
		self.log.info('Start auto ship check')
		self.beacon(False)
		bdoptions = (
			('Direct-IO G2i', None, 'shannon'),
			('Direct-IO G3i-B-Ali', '(board type 6B)', 'ali'),
			('Direct-IO G3i-Ali', '(board type non-6B)', 'ali'),
			('Direct-IO G4i-Ali', None, 'ali'),
			('Direct-IO G3i', None, 'shannon'),
			('Direct-IO G3i-B', None, 'shannon'),
			('Direct-IO G3i-K', None, 'shannon'),
			('Direct-IO G3S', None, 'shannon'),
			('Direct-IO G4i', None, 'shannon'),
			('Direct-IO G4i-K', None, 'shannon'),
			('Direct-IO 8639 G3', None, 'shannon'),
			('Direct-IO G4i-U.2', None, 'shannon'),
			('Direct-IO G4i-U.2-Ali', None, 'ali'),
		)
		self.log.info('Board modelid options:\n', raw=True)
		for n,b in enumerate(bdoptions):
			self.log.info('    %-2d %s%s' % (n+1, b[0], ' %s\n'%b[1] if b[1] else '\n'), raw=True)
		s = raw_input('Please select: ').strip()
		if not s:
			self.log.error('Please input a number!')
			sys.exit(1)
		t = int(s)
		if t <= 0 or t > len(bdoptions):
			self.log.error('Board modelid selection should be 1 ~ %d but your input %d' % (len(bdoptions), t))
			sys.exit(1)
		self.log.info('Your selection is %s' % t)
		self.vendor = bdoptions[t-1][2]

		if self.board['ecapacity']:
			self.log.info('Capacity selection:\n', raw=True)
			for n,c in enumerate(self.board['ecapacity']):
				self.log.info('    %-2d %s\n' % (n+1, c), raw=True)
			s = raw_input('Please select: ').strip()
			if not s:
				self.log.error('Please input a number!')
				sys.exit(1)
			e = int(s)
			if e <= 0 or e > len(self.board['ecapacity']):
				self.log.error('Capacity selection should be 1 ~ %d but your input %d' % (len(self.board['ecapacity']), e))
				sys.exit(1)
			self.log.info('Your selection is %s' % e)

			self.board['capacity'] = self.board['ecapacity'][e-1]
			self.board['__capacity__'] = self.board['__ecapacity__'][e-1]
			self.board['stdop'] = self.board['eop'][2*(e-1)]
			self.board['aliop'] = self.board['eop'][2*(e-1)+1]

		cmd = '%s -d /dev/%s -y -m "%s %s%s"' % (self.shannon_modelid, self.cdevnode, bdoptions[t-1][0], self.board['__capacity__'], 'G' if self.vendor == 'ali' else 'GB')
		if os.system(cmd):
			qctool_exit('run command %s fail' % cmd)

		self.parse_fwtag()
		self.parse_sgcfg()
		self.parse_sysfs()
		self.sgcfg['perlun_dynamic_bad_blkcnt'] = '0'
		self.sgcfg['dynamic_bad_blkcnt'] = '0'

		if self.vendor == 'ali':
			self.sgcfg['init_loops'] = self.sgcfg['ali_init_loops']
		elif self.vendor == 'shannon':
			self.sgcfg['init_loops'] = self.sgcfg['shannon_init_loops']
		else:
			qctool_exit('BUGggggggggg')

		self.log.info('Format %s with clear history' % self.devnode)
		self.format('-c -S %s' % self.board['capacity'])

		self.log.info('Shipping Test Step 1: Reconfig %s ...' % self.devnode, nolf=True)
		if self.sysfs['reconfig_support'] == '1' and not self.disable_reconfig:
			status = os.system('%s --recanfig 1020 /dev/%s' % (self.shannon_detach, self.cdevnode))
			if status != 0:
				qctool_exit('Shipping Test Step1 Reconfig error')
			self.log.info('OK\n', raw=True)
		else:
			self.log.info("hardware don't support reconfig\n", raw=True)

		self.log.info('Shipping Test Step 2: Write %s 16GB with Zero ...' % self.devnode, nolf=True)
		cmd = 'dd if=/dev/zero of=/dev/%s bs=1M count=16k oflag=direct 1>/dev/null 2>&1' % self.devnode
		if os.system(cmd):
			qctool_exit('Shipping Test Step 2 Write 16GB data error')
		self.log.info('OK\n', raw=True)

		self.log.info('Shipping Test Step 3: Read %s 16GB ...' % self.devnode, nolf=True)
		cmd = 'dd if=/dev/%s of=/dev/null bs=1M count=16k iflag=direct 1>/dev/null 2>&1' % self.devnode
		if os.system(cmd):
			qctool_exit('Shipping Test Step 3 Read 16GB data error')
		self.log.info('OK\n', raw=True)

		self.parse_sysfs(tolog=True)
		self.parse_status(tolog=True)
		self.parse_statistics(tolog=True)
		self.parse_mbr(tolog=True)

		# check ship items
		if self.ship_cheat_verify_hours:
			self.board['min_verify_hours'] = self.ship_cheat_verify_hours
		if self.ship_cheat_init_loops:
			self.sgcfg['init_loops'] = self.ship_cheat_init_loops

		ship_list = []
		err_list = []
		abbreviation_list = []
		self.common_counter = 1

		ship_list.append(self.check_item('pcie link status', 'LS', self.status['PCILinkLanes'], self.board['lanes']))
		ship_list.append(self.check_item('init loops', 'IL', str(self.db.obtain_init_loops()), self.sgcfg['init_loops'], digit=True))
		ship_list.append(self.check_item('verify hours', 'VH', str(self.db.obtain_verify_hours()), self.board['min_verify_hours'], digit=True))
		if self.skipfirmwarecheck:
			pass
		elif self.forcelastfirmware:
			ship_list.append(self.check_item('firmware version', 'FV', self.sysfs['firmware_build'].upper(), self.fwtag['last_%s' % self.board['firmware_tag']].upper()))
		else:
			ship_list.append(self.check_item('firmware version', 'FV', self.sysfs['firmware_build'].upper(), self.fwtag[self.board['firmware_tag']].upper()))
		ship_list.append(self.check_item('capacity', 'CAP', '%sGB' % self.sysfs['user_capacity_gb'], self.board['capacity']))
		# ship_list.append(self.check_item('LBA count', 'LBA', self.sysfs['user_capacity'], str(97696368+1953504*(int(self.sysfs['user_capacity_gb'])-50))))
		ship_list.append(self.check_item('OP', 'OP', self.sysfs['overprovision'], self.board['stdop' if self.vendor == 'shannon' else 'aliop'], digit=True))
		ship_list.append(self.check_item('raid group', 'RG', self.mbr['raid_stripes'], self.board['raidgroup']))
		if self.board['generation'].startswith('G5') and self.mbr['pseudo_plane'] == '1':
			ship_list.append(self.check_item('plane number', 'PN', self.mbr['plane_count'], self.board['nplane']))
		else:
			ship_list.append(self.check_item('plane number', 'PN', str(2**int(self.mbr['plane_order'])), self.board['nplane']))
		ship_list.append(self.check_item('power on seconds', 'POS', self.statistics['power_on_seconds'], str(long(self.board['min_verify_hours']) * 3600), digit=True))
		ship_list.append(self.check_item('estimated life left', 'ELL', self.sysfs['estimated_life_left'], self.sgcfg['estimated_life_left'], digit=True))
		ship_list.append(self.check_item('host write data', 'WD',
						str(int(long(self.sysfs['host_write_sectors'])*512/(1000*1000*1000))),
						str((long(self.board['min_verify_hours'])*3600*80)/1000), digit=True))
		ship_list.append(self.check_item('host read data', 'RD',
						str(int(long(self.sysfs['host_read_sectors'])*512/(1000*1000*1000))),
						str((long(self.board['min_verify_hours'])*3600*80)/1000), digit=True))
		act_vendor = self.sysfs['model']
		if re.match('Direct-IO', act_vendor):
			if re.search('[aA][lL][iI]', act_vendor):
				act_vendor = 'ali'
			else:
				act_vendor = 'shannon'
		ship_list.append(self.check_item('vendor', 'VD', self.vendor, act_vendor))
		ship_list.append(self.check_item('dynamic bad block', 'DB', self.statistics['dynamic_bad_blkcnt'], self.sgcfg['dynamic_bad_blkcnt'], digit=True, digit_reverse_cmp=True))
		if self.board['power_budget'] != 'default':
			ship_list.append(self.check_item('power budget', 'PB', self.board['power_budget'], self.mbr['power_budget']))
		if self.board['flash_ifclock'] == 'default':
			ifclock = '0'
		else:
			ifclock = str(int(self.board['flash_ifclock']) + 1)
		if self.downgrade:
			ifclock = ('7' if ifclock == '0' else str(int(ifclock) + 1))
		ship_list.append(self.check_item('MBR ifclock', 'MC', self.mbr['clk'], ifclock))
		ship_list.append(self.check_item('NOR MBR', 'NM', 'yes' if self.mbr.has_key('NM-watermark') else 'no', self.board['write_nor_mbr'].lower()))
		ship_list.append(self.check_item('FC ECC', 'FC', self.statistics['ecc_fc_statistics'], '0'))
		ship_list.append(self.check_item('DRIVER', 'DV', self.sysfs['driver_version'], self.sgcfg['driver_version']))
		# MBR VERSION default value 0x5400 used from 2017.11.08
		self.parse_mbr()
		mbr_version = '0x5400'
		if self.flash['importstage'] == '1':
			mbr_version = '0x5410'
		if int(self.sysfs['hardware_version'], 16) >= 0x10:
			mbr_version = '0x5420'
		ship_list.append(self.check_item('MBR VERSION', 'MV', self.mbr['mbr_version'], mbr_version))

		for lst in ship_list:
			if lst[4] == 'P':
				if lst[1] in ('IL', 'VH', 'FV', 'CAP', 'LBA', 'OP', 'RG', 'PN', 'VD', 'DB', 'MV', 'DV'):
					abbreviation_list.append('%s:%s' % (lst[1], lst[2]))
			else:
				err_list.append('%s:%s,%s' % (lst[0], lst[2], lst[3]))

		if err_list:
			qctool_exit('Ship Fail: %s' % ' '.join(err_list))

		if self.downgrade:
			abbreviation_list.append('DG:yes')
		info = ' '.join(abbreviation_list)
		self.db.commit_ship_success(info)

	def qc_stable(self):
		self.log.info('Show Stable Write Performance')

		self.log.info('Clean Disk ...')
		self.format('-c')

		self.log.info('Make Stable Disk ...')
		cmd = 'fio --name=precondition --filename=/dev/%s --numjobs=2 --bs=128k --ioengine=libaio --direct=1 '\
		      '--rw=randwrite --group_reporting --randrepeat=0 --iodepth=256 --iodepth_batch=128 --iodepth_batch_complete=128 '\
		      '--gtod_reduce=1' % self.devnode
		self.log.info(cmd)
		if os.system(cmd):
			qctool_exit('Make Stable Disk Error.')

		# stable write performance
		self.log.info('Stable 4K Write Latency:', nolf=True)
		cmd = 'fio --name=wlat --filename=/dev/%s --numjobs=1 --ramp_time=30 --runtime=60 --bs=4k --ioengine=libaio --direct=1 --norandommap '\
                      '--randrepeat=0 --rw=randwrite --group_reporting --iodepth=1 --iodepth_batch_complete=0 -minimal' % self.devnode
		output = exeshell(cmd).split(';')
		wrlat = output[80]
		self.log.info('%sus\n' % wrlat, raw=True)

		self.log.info('Stable Write Bandwidth:', nolf=True)
		cmd = 'fio --name=wbw --filename=/dev/%s --numjobs=4 --bs=4k --ioengine=libaio --direct=1 --randrepeat=0 --norandommap '\
		      '--rw=randwrite --group_reporting --iodepth=512 --iodepth_batch=128 --iodepth_batch_complete=128 '\
		      '--gtod_reduce=1 --ramp_time=30 --runtime=60 --minimal' % self.devnode
		output = exeshell(cmd).split(';')
		wrbw = str(long(output[47])/1000)
		self.log.info('%sMB/s\n' % wrbw, raw=True)

		self.log.info('Stable 4K Write IOPS:', nolf=True)
		cmd = 'fio --name=wiops --filename=/dev/%s --numjobs=4 --bs=4k --ioengine=libaio --direct=1 --randrepeat=0 --norandommap '\
		      '--rw=randwrite --group_reporting --iodepth=512 --iodepth_batch=128 --iodepth_batch_complete=128 '\
		      '--gtod_reduce=1 --ramp_time=30 --runtime=60 --minimal' % self.devnode
		output = exeshell(cmd).split(';')
		wriops = str(long(output[48])/1000)
		self.log.info('%sK\n' % wriops, raw=True)

		info = 'Stable Write Performance: W_lat=%s,W_bw=%s,W_iops=%s' % (wrlat, wrbw, wriops)
		self.log.success(info)

	def qc_spec(self):
		self.log.info('Show Basic Performance Figures')

		# write performance
		self.log.info('Clean Disk to Get Best Write Performance...')
		self.format('-c')

		self.log.info('Sleep 5 second ...')
		time.sleep(5)

		self.log.info('Testing 4K Write Latency:', nolf=True)
		cmd = 'fio --name=wlat --filename=/dev/%s --numjobs=1 --runtime=30 --bs=4k --ioengine=libaio --direct=1 --norandommap '\
                      '--randrepeat=0 --rw=randwrite --group_reporting --iodepth=1 --iodepth_batch_complete=0 -minimal' % self.devnode
		output = exeshell(cmd).split(';')
		wrlat = output[80]
		self.log.info('%sus\n' % wrlat, raw=True)

		self.log.info('Testing Write Bandwidth:', nolf=True)
		cmd = 'fio --name=wbw --filename=/dev/%s --numjobs=4 --bs=128k --ioengine=libaio --direct=1 --randrepeat=0 --norandommap '\
		      '--rw=randwrite --group_reporting --iodepth=512 --iodepth_batch=128 --iodepth_batch_complete=128 '\
		      '--gtod_reduce=1 --runtime=30 --minimal' % self.devnode
		output = exeshell(cmd).split(';')
		wrbw = str(long(output[47])/1000)
		self.log.info('%sMB/s\n' % wrbw, raw=True)

		self.log.info('Testing 4K Write IOPS:', nolf=True)
		cmd = 'fio --name=wiops --filename=/dev/%s --numjobs=4 --bs=4k --ioengine=libaio --direct=1 --randrepeat=0 --norandommap '\
		      '--rw=randwrite --group_reporting --iodepth=512 --iodepth_batch=128 --iodepth_batch_complete=128 '\
		      '--gtod_reduce=1 --runtime=30 --minimal' % self.devnode
		output = exeshell(cmd).split(';')
		wriops = str(long(output[48])/1000)
		self.log.info('%sK\n' % wriops, raw=True)

		# read performance
		self.log.info('Sequential Write 100g to Get Real Read Performance...')
		cmd = 'fio --name=full-range --filename=/dev/%s --numjobs=1 --bs=128k --ioengine=libaio --direct=1 --randrepeat=0 --rw=randwrite '\
		      '--group_reporting --iodepth=128 --iodepth_batch=64 --iodepth_batch_complete=64 --filesize=100g --minimal' % self.devnode
		exeshell(cmd)

		self.log.info('Sleep 10 second ...')
		time.sleep(10)

		self.log.info('Testing 4K Read Latency:', nolf=True)
		cmd = 'fio --name=rlat --filename=/dev/%s --numjobs=1 --runtime=30 --bs=4k --ioengine=libaio --direct=1 --randrepeat=0 '\
		      '--rw=randread --group_reporting --iodepth=1 --iodepth_batch_complete=0 --filesize=100g --minimal' % self.devnode
		output = exeshell(cmd).split(';')
		rdlat = output[39]
		self.log.info('%sus\n' % rdlat, raw=True)

		self.log.info('Testing 4K Read Bandwidth:', nolf=True)
		cmd = 'fio --name=rbw --filename=/dev/%s --numjobs=4 --bs=128k --ioengine=libaio --direct=1 --randrepeat=0 --norandommap '\
		      '--rw=randread --group_reporting --iodepth=512 --iodepth_batch=128 --filesize=100g --iodepth_batch_complete=128 '\
		      '--gtod_reduce=1 --runtime=30 --minimal' % self.devnode
		output = exeshell(cmd).split(';')
		rdbw = str(long(output[6])/1000)
		self.log.info('%sMB/s\n' % rdbw, raw=True)

		self.log.info('Testing 4K Read IOPS:', nolf=True)
		cmd = 'fio --name=riops --filename=/dev/%s --numjobs=4 --bs=4k --ioengine=libaio --direct=1 --randrepeat=0 --norandommap '\
		      '--rw=randread --group_reporting --iodepth=512 --iodepth_batch=128 --iodepth_batch_complete=128 '\
		      '--gtod_reduce=1 --runtime=30 --filesize=100g --minimal' % self.devnode
		output = exeshell(cmd).split(';')
		rdiops = str(long(output[7])/1000)
		self.log.info('%sK\n' % rdiops, raw=True)

		info = 'QC SPEC: W_lat=%s,W_bw=%s,W_iops=%s,R_lat=%s,R_bw=%s,R_iops=%s' % (wrlat, wrbw, wriops, rdlat, rdbw, rdiops)
		self.log.success(info)

	def qc_list(self):
		pass

	def qc_status(self):
		self.log.info('Shannon status')
		self.parse_status()
		self.log.info(self.rawstatus, raw=True)

	def qc_statistics(self):
		self.log.info('Shannon statistics')
		self.parse_statistics()
		self.log.info(self.rawstatistics, raw=True)

	def qc_sysfs(self):
		self.log.info('Shannon sysfs')
		self.parse_sysfs()
		self.log.info(self.rawsysfs, raw=True)

	def qc_mbr(self):
		self.log.info('Shannon MBR')
		self.parse_mbr()
		self.log.info(self.rawmbr, raw=True)

	def qc_board(self):
		self.log.info('Shannon board')
		if not self.rawboard:
			qctool_exit('BUGggggggggg')
		self.log.info(self.rawboard, raw=True)

	def qc_format(self):
		self.log.info('Start format')
		self.format('-c')
		self.log.success('Formatted %s to capacity:%sGB, OP:%s' % (self.devnode, self.sysfs['user_capacity_gb'], self.sysfs['overprovision']))

	def qc_beacon(self):
		self.log.info('Start beacon on')
		self.beacon()

	def qc_model(self):
		self.log.info('Change model ID')

		self.log.info('Model ID options:\n', raw=True)
		self.log.info('        1 Direct-IO G3i-B-Ali\n', raw=True)
		self.log.info('        2 Direct-IO G3i-Ali\n', raw=True)
		self.log.info('        3 Direct-IO G3i\n', raw=True)
		type = raw_input('Please select: ').strip()
		if type == '1':
			cmd = '%s -d /dev/%s -b -y' % (self.shannon_modelid, self.cdevnode)
		elif type == '2':
			cmd = '%s -d /dev/%s -y' % (self.shannon_modelid, self.cdevnode)
		elif type == '3':
			cmd = '%s -d /dev/%s -m "Direct-IO G3i" -y' % (self.shannon_modelid, self.cdevnode)
		else:
			self.log.error('Selection should be 1~3')
			sys.exit(1)
		self.log.info('Your selection is %s' % type)
		if os.system(cmd):
			qctool_exit('run command %s fail' % cmd)

	def qc_hotplug(self):
		self.log.info('Start hotplug test')
		tool = './testboard/sendcmd'
		usbcom = '/dev/ttyACM0'
		pciportmap = ['03','04','05','06','08','09','0a','07']
		if not os.path.exists(usbcom):
			qctool_exit('%s not exsit' % usbcom)
		self.parse_sysfs()
		if int(''.join(self.sysfs['driver_version'].split('.'))[:2]) < 31:
			qctool_exit('driver_version must higher than 3.1')
		pci_address = self.sysfs['pci_address'].split(':')
		port = 1 << pciportmap.index(pci_address[0])

		hotplug_times = raw_input('\nEnter hotplug test times (default 3): ').strip()
		if not hotplug_times:
                        hotplug_times = 3
                        self.log.info('Use default %d times' % hotplug_times)
		elif hotplug_times.isdigit() and int(hotplug_times) > 0:
			hotplug_times = int(hotplug_times)
			self.log.info('input hotplug times is %d' % hotplug_times)
		else:
			qctool_exit('invalid hotplug times')

		for i in range(hotplug_times):
			cmd = 'fio --name=randrw --filename=/dev/%s --numjobs=32 --runtime=30 --bs=32k --ioengine=sync --direct=1 --norandommap ' \
				'--randrepeat=0 --rw=randrw --group_reporting ' % self.devnode
			os.system('%s &' % cmd)
			time.sleep(random.randint(1,30))
			os.system('echo 1 > /sys/bus/pci/devices/0000:%s:%s.%s/remove' % (pci_address[0],pci_address[1],pci_address[2]))
			time.sleep(1)
			exeshell('%s %s 01 FF %02x > /dev/null' % (tool,usbcom,port))
			time.sleep(5)
			exeshell('%s %s 01 00 %02x' % (tool,usbcom,port))
			time.sleep(1)
			os.system('echo 1 > /sys/bus/pci/rescan')
			if not os.path.exists('/dev/%s' % self.devnode):
				qctool_exit('%s not exists' % self.devnode)
			self.parse_sysfs()
			if self.sysfs['readonly_reason'] != '0' or self.sysfs['reduced_write_reason'] != '0':
				qctool_exit('access mode error')
		self.log.success('hotplug')

def usage():
	try:
		raise Exception
	except:
		f = sys.exc_info()[2].tb_frame.f_back
	func = f.f_code.co_name
	lineno = f.f_lineno

	print '''\
Usage:
	qctool <mode> [devnode]
Mode:
	verify       do verify QC
	ship         QC shipping check
	format       high-level format SSD card
	list         list this device
	status       show status
	sysfs        show sysfs
	statistics   show debugfs statistics
	mbr          show MBR
	board        show board info
	beacon       light the device yellow LED
	spec         show basic performance figures
	stable       show stable write performance
	hotplug      U.2 hotplug test
	help         show help message'''

#-----------------------------------------------------------------------------------------------------
mdev = manage_device(sys.argv[1:])
if os.geteuid() != 0:
	sys.exit('Operation not permitted! Prefix "sudo" then try again')
mdev.prepare_check()
mdev.insmod()
mdev.doqc()

# END
#-----------------------------------------------------------------------------------------------------
