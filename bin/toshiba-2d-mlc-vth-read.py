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
def extract_bits(lines):
	a = []
	for line in lines.split('\n'):
		if line.startswith('page_bit_cnt'):
			a.append(int(line.split(':')[1]))
	return a

# -----------------------------------------------------------
xchars = 128
pagebits = 32*1024*8
lowerpages = [0] + range(1, 254, 2)
upperpages = range(2, 255, 2) + [255]

npage = 1
output = None
device = 'a'
try:
	opts, args = getopt.gnu_getopt(sys.argv[1:], 'n:o:x:d:', ['npage=', 'output=', 'xaxis-chars=', 'device='])
	for name, value in opts:
		if name in ('-n', '--npage'):
			npage = int(value)
		elif name in ('-o', '--output'):
			output = value
		elif name in ('-x', '--xaxis-chars'):
			xchars = int(value)
		elif name in ('-d', '--device'):
			device = value
	lun = int(args[0])
	block = int(args[1])
	page = int(args[2])
except:
	sys.exit('Usage:\n\t%s lun block page [-n, --npage=N] [-o, --output=FILE] [-x, --xaxis-chars=N, default 128] [-d, --device=devnod, default a]!' % (sys.argv[0]))

length = 0
bits = [0 for i in range(0, 256)]
apptool = './ztool --dev=%s --silent-config --disable-ecc' % device

for page in range(page, page + npage):
	offset = 0
	print 'read lun=%d block=%d page=%d' % (lun, block, page)

	# Erase state bit count
	a = extract_bits(getcmd('%s vth-read %d %d %d -rB N64 N64 4' % (apptool, lun, block, page)))
	bits[offset] += a[0]
	offset += 1

	# State A and B
	a = extract_bits(getcmd('%s vth-read %d %d %d -rB N64 63 4' % (apptool, lun, block, page)))
	for i in range(0, len(a) - 1):
		bits[offset] += abs(a[i+1] - a[i])
		offset += 1

	# State C
	a = extract_bits(getcmd('%s vth-read %d %d %d -rC 0 63 4' % (apptool, lun, block, page)))
	for i in range(0, len(a) - 1):
		bits[offset] += abs(a[i+1] - a[i])
		offset += 1

	if not length:
		length = offset

bits = bits[0:length]
if output:
	fh = open(output, 'w')
	fh.write('%s\n' % '\n'.join([str(x) for x in bits]))
	fh.close()

plotemu = []
maxbits = max(bits[1:])
percent = 0.0
for x in bits[1:]:
	if x == 0 or maxbits == 0 or x*xchars/maxbits == 0:
		plotemu.append('|')
	else:
		percent += (100.0*x)/(pagebits*npage)
		plotemu.append('-'*(x*xchars/maxbits) + '%.1f (%.1f)' % ((100.0*x)/(pagebits*npage), percent))
print '\n===== PLOT ====='
print 'Erase state bits: %d (%.1f%%)' % (bits[0], (bits[0]*100.0)/(pagebits*npage))
for s in plotemu:
	print s
