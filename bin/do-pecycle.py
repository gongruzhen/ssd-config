#!/usr/bin/python

import os
import sys
import commands
import subprocess
import time

#------------------------------------------------------------------------------------------------------------#
def abort(info, rc=23):
	try: raise Exception
	except: f = sys.exc_info()[2].tb_frame.f_back
	__file__ = f.f_code.co_filename
	__func__ = f.f_code.co_name
	__lineno__ = f.f_lineno

	print '\033[0;1;31m[%s %s() +%d]. %s\033[0m' % (__file__, __func__, __lineno__, info)
	os._exit(rc)

def __file__():
	try: raise Exception
	except: f = sys.exc_info()[2].tb_frame.f_back
	return f.f_code.co_filename

def __func__():
	try: raise Exception
	except: f = sys.exc_info()[2].tb_frame.f_back
	return f.f_code.co_name

def __line__():
	try: raise Exception
	except: f = sys.exc_info()[2].tb_frame.f_back
	return f.f_lineno

def docmd(cmd, check=True, value=0, prompt=''):
	'''
	return cmd exit code, abort if cmd return non-zero, set check to disable abort.
	support all commands: pipe, multiple commands, Redirection IO and so on.
	call this function when you only care execute success or failure.
	'''
	if not cmd.strip():
		abort('docmd empty string!')
	r, o = commands.getstatusoutput(cmd)
	if check and r != value:
		abort("docmd '%s' error! rt=%d." % (cmd, r) if not prompt else prompt)
	return r

def getcmd(cmd, check=True, value=0, prompt=''):
	'''
	return cmd output, abort if cmd return non-zero, set check to disable abort.
	support all commands: pipe, multiple commands, Redirection IO and so on.
	call this function when you want get command output.
	'''
	if not cmd.strip():
		abort('getcmd empty string!')
	r, o = commands.getstatusoutput(cmd)
	if check and r != value:
		abort("getcmd '%s' error! rt=%d." % (cmd, r) if not prompt else prompt)
	return o

def callcmd(cmd, workdir='', check=True, value=0, ShowOut=True, ShowErr=True, prompt=''):
	'''
	return cmd exit code, abort if cmd return non-zero, set check to disable abort.
	just support single command. don't support pipe and multiple cmds,
	but support Redirection IO by ShowOut and ShowErr parameter.
	call this function when you want monitor cmd execution process.
	'''
	if not cmd.strip():
		abort('callcmd empty string!')

	fh = open('/dev/null', 'w') if not ShowOut or not ShowErr else None
	out = fh if not ShowOut else None
	err = fh if not ShowErr else None
	if workdir:
		if not os.path.isdir(workdir):
			abort('No such directory: %s' % workdir)
		cwd = os.getcwd()
		os.chdir(workdir)
	a = cmd.split()
	r = subprocess.Popen(a, stdout=out, stderr=err).wait()
	if workdir:
		os.chdir(cwd)

	if check and r != value:
		abort("callcmd '%s' error! rt=%d." % (cmd, r) if not prompt else prompt)
	if fh:
		fh.close()
	return r

def permittion():
	if os.geteuid() != 0:
		abort('Operation not permitted! Prefix "sudo" then try again')

class logger:
	def __init__(self, name, appendlog=False):
		from socket import gethostname

		gittag = 'Undetermined'
		r,o = commands.getstatusoutput('git log | head -n1')
		if r == 0:
			line = o.split()
			if line[0] == 'commit':
				gittag = line[1][0:8]
		self.prefix = '%s(%s)' % (gethostname(), gittag)
		self.filehandler = open(name, 'a' if appendlog else 'w', buffering=0)

	def __del__(self):
		self.filehandler.close()

	def close(self):
		self.filehandler.close()

	def flush(self):
		self.filehandler.flush()

	def add_prefix(self, p):
		if p.strip():
			self.prefix += ' %s' % p.strip()
			self.prefix = self.prefix.strip()

	def info(self, info, raw=False, xlog=True, xprint=True, nolf=False):
		if not raw:
			ts = time.strftime("%Y-%m-%d %H:%M:%S",time.localtime(time.time()))
			if xprint:
				if nolf:
					print '===> %s %s, %s' % (self.prefix, ts, info),
					sys.stdout.flush()
				else:   print '===> %s %s, %s' % (self.prefix, ts, info)
			if xlog:
				if nolf:
					self.filehandler.write('===> %s %s, %s' % (self.prefix, ts, info))
				else:   self.filehandler.write('===> %s %s, %s\n' % (self.prefix, ts, info))
		else:
			if xprint: print info,
			if xlog: self.filehandler.write('%s' % info)

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

def seconds2timeval(seconds):
	h = seconds/3600
	m = (seconds%3600)/60
	s = seconds % 60
	return '%d hours %d minutes %d seconds' % (h, m, s)

def progress(s):
	sys.stdout.write('\r\033[K')
	sys.stdout.flush()
	sys.stdout.write(s)
	sys.stdout.flush()
	log.info(s, xprint=False)

#------------------------------------------------------------------------------------------------------------#
# XXX: MODIFY HERE
pecycle = {}

pecycle[1000] = 100
pecycle[2000] = 101
pecycle[3000] = 102
pecycle[4000] = 103
pecycle[5000] = 104

tlogluns = ''
# tlogluns = '-t loglun:16-23'

delay_after_write = 1

#------------------------------------------------------------------------------------------------------------#
if len(sys.argv) != 2:
	sys.exit('Usage: %s device (a b c ...)' % sys.argv[0])
device = sys.argv[1]
apptool = './ztool --dev=%s' % device

cycles = sorted(pecycle.keys())
sbs = [pecycle[c] for c in cycles]

btime = time.time()
log = logger('pecycle.log')

ts = 0
cs = 0
log.info('check whether selected sbs %s at cycles %s have bad lun' % (sbs, cycles))
for c in cycles:
	sb = pecycle[c]
	log.info('check sb %d ...' % sb, nolf=True)

	stime = long(time.time())
	docmd('%s super-erase %s %d 1' % (apptool, tlogluns, sb))
	docmd('%s super-write %s %d 1' % (apptool, tlogluns, sb))
	docmd('%s super-read %s %d 1' % (apptool, tlogluns, sb))
	docmd('%s super-read %s %d 1' % (apptool, tlogluns, sb))
	etime = long(time.time())
	ts += (etime - stime);
	cs += c

	line = getcmd('%s super-read %s %d 1 -pE | grep -e"FC" -e"FD"' % (apptool, tlogluns, sb), check=False)
	if line:
		abort('sb %d have bad lun! %s\n' % (sb, line))
	log.info('OK\n', raw=True)

ts = (ts/len(sbs) + delay_after_write)
log.info('Estimated Time: %ds/cycle; total %ds, i.e. %s.' % (ts, ts*cs, seconds2timeval(ts*cs)), raw=True, nolf=True)
ans = raw_input('Continue? [yes|no] ')
if ans != 'yes':
	sys.exit(1)

for idx, c in enumerate(cycles):
	sb = pecycle[c]
	log.info('[%d/%d] do sb %d pecycle ... ' % (idx+1, len(cycles), sb))

	for i in range(1, c+1):
		progress('===> %d/%d in erase' % (i, c))
		docmd('%s super-erase %s %d 1' % (apptool, tlogluns, sb))

		progress('===> %d/%d in write' % (i, c))
		docmd('%s super-write %s %d 1' % (apptool, tlogluns, sb))

		progress('===> %d/%d in read' % (i, c))
		docmd('%s super-read %s %d 1' % (apptool, tlogluns, sb))
		docmd('%s super-read %s %d 1' % (apptool, tlogluns, sb))

		progress('===> %d/%d in sleep' % (i, c))
		time.sleep(delay_after_write)
	progress('===> %d/%d complete\n' % (i, c))

log.info('Complete! Taken time: %s' % seconds2timeval(long(time.time() - btime)))
