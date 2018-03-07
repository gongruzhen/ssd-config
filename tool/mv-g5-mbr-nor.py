#!/usr/bin/python

import os
import sys
import commands
import getopt
import re
import fileinput

def abort(info, rc=23):
	try: raise Exception
	except: f = sys.exc_info()[2].tb_frame.f_back
	__file__ = f.f_code.co_filename
	__func__ = f.f_code.co_name
	__lineno__ = f.f_lineno

	print '\033[0;1;31m[%s %s() +%d]. %s\033[0m' % (__file__, __func__, __lineno__, info)
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

# -----------------------------------------------------------
try:
	device = sys.argv[1]
except IndexError:
	sys.exit('Usage: %s device (a b c ...)' % sys.argv[0])

oldlocation = 30*1024*1024
newlocation = 31*1024*1024
mbroffset = 128*1024
tmp = getcmd('mktemp')

# old
docmd('./ztool --dev=%s nor read 0x%X 4096 %s' % (device, oldlocation + mbroffset, tmp))
fh = open(tmp, 'r')
oldtag = fh.read(len('sh-shannon-pcie-ssd'))
fh.close()

# new
docmd('./ztool --dev=%s nor read 0x%X 4096 %s' % (device, newlocation + mbroffset, tmp))
fh = open(tmp, 'r')
newtag = fh.read(len('sh-shannon-pcie-ssd'))
fh.close()

print 'tag at old location: %s' % oldtag
print 'tag at new location: %s' % newtag

# check condition
if oldtag != 'sh-shannon-pcie-ssd':
	abort('oldtag is not sh-shannon-pcie-ssd!')

if newtag == 'sh-shannon-pcie-ssd':
	abort('newtag is sh-shannon-pcie-ssd!')

# move
print 'read old ...'
docmd('./ztool --dev=%s nor read 0x%X %d %s' % (device, oldlocation, 1024*1024, tmp))

print 'erase new ...'
docmd('./ztool --dev=%s nor erase 0x%X %d' % (device, newlocation, 1024*1024))

print 'write old to new ...'
docmd('./ztool --dev=%s nor write 0x%X %s' % (device, newlocation, tmp))

print 'erase old ...'
docmd('./ztool --dev=%s nor erase 0x%X %d' % (device, oldlocation, 1024*1024))

docmd('rm -f %s' % tmp)
