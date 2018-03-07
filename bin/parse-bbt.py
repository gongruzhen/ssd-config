#!/usr/bin/python

# David Miao, 2017-08-03

import os
import sys
import commands
import getopt
import time
import fileinput
import re

###-------------------------------------------------------------------------------------------------###
def abort(info, rc=23):
	try: raise Exception
	except: f = sys.exc_info()[2].tb_frame.f_back
	__file__ = f.f_code.co_filename
	__func__ = f.f_code.co_name
	__lineno__ = f.f_lineno

	print '\033[0;1;31m[%s %s() +%d]. %s\033[0m' % (__file__, __func__, __lineno__, info)
	docmd('pkill -KILL iocheck', check=False)
	os._exit(rc)

def docmd(cmd, check=True, value=0):
	if not cmd.strip():
		abort('docmd empty string!')
	r, o = commands.getstatusoutput(cmd)
	if check and r != value:
		abort("docmd '%s' error! rt=%d." % (cmd, r))
	return r

def getcmd(cmd, check=True, value=0):
	if not cmd.strip():
		abort('getcmd empty string!')
	r, o = commands.getstatusoutput(cmd)
	if check and r != value:
		abort("getcmd '%s' error! rt=%d." % (cmd, r))
	return o

###-------------------------------------------------------------------------------------------------###
if len(sys.argv) < 2:
	sys.exit('Usage: %s bbt-file' % sys.argv[0])
if not os.path.exists(sys.argv[1]):
	abort('No such file %s' % sys.argv[1])

luns = []
bbts = {}
total = 0
for line in fileinput.input(sys.argv[1]):
	a = line.strip().split('[')
	m = re.match('lun-(\d+) phylun-(\d+) bad blocks:(.*)', a[0].strip())
	if m:
		lun = int(m.group(1))
		luns.append(lun)
		bbts[lun] = [ int(s) for s in m.group(3).strip().split()]
		total += len(bbts[lun])
		# print lun, bbts[lun], len(bbts[lun])

###-------------------------------------------------------------------------------------------------###
# DO YOUR WORK HERE!
nplane = 2
n = 1
for lun in luns:
	for blk in bbts[lun]:
		r = docmd('./ztool read -C %d %d 0 -pE | grep FD' % (lun, blk/nplane), check = False)
		if r:
			print('\033[0;1;31m[%d/%d] lun-%d block-%d maybe not factory bad block!\033[0m' % (n, total, lun, blk))
		else:
			sys.stdout.write('\r\033[K')
			sys.stdout.write('[%d/%d] lun-%d block-%d check OK!' % (n, total, lun, blk))
			sys.stdout.flush()
		n += 1
print
