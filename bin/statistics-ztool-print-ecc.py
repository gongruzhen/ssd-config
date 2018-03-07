#!/usr/bin/python

# david miao

import os
import sys
import re
import getopt

skip_fc = False
convert_fd = False
opts, args = getopt.gnu_getopt(sys.argv[1:], 'cd', ['skip-fc', 'convert-fd'])
for name, value in opts:
	if name in ['-c', '--skip-fc']:
		skip_fc = True
	elif name in ['-d', '--convert-fd']:
		convert_fd = True
if len(args) != 2:
	sys.exit('Usgae: %s file ecc-power [-c, --skip-fc] [-d, convert-fd]' % sys.argv[0])

file = args[0]
power = int(args[1])

fh = open(file, 'r')
lines = fh.readlines()
fh.close()

ecc = {}
for i in range(0, 256):
	ecc[i] = 0

for line in lines:
	m = re.match('#ECC.*: (.*)', line)
	if not m:
		continue
	for x in [int(s, 16) for s in m.group(1).split()]:
		if x == 0xFC and not skip_fc:
			sys.exit('ECC 0xFC error!\n%s' % line.strip())
		ecc[x] += 1

for i in range(0, power+1):
	print '%d %d' % (i, ecc[i])

if ecc[0xFB] != 0:
	print '%d %d' % (0xFB, ecc[0xFB])

if ecc[0xFD] != 0:
	if not convert_fd:
		print '%d %d' % (0xFD, ecc[0xFD])
	else:
		print '%d %d' % (power+10, ecc[0xFD])
