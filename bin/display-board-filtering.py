#!/usr/bin/python

import os
import sys
import re

try:
	if sys.argv[1] == '-h':
		print 'Usage:\n\t%s [filter-keys ...]' % sys.argv[0]
		sys.exit(0)
except IndexError:
	pass

try:
	fh = open('board', 'r')
except:
	sys.exit('Open board error!')
lines = fh.readlines()
fh.close()

item = []
for line in lines:
	line = line.strip()

	if re.match('\[', line):
		if item: print ' '.join(item)
		item = []
		item.append(line)
		continue

	for filter in sys.argv[1:]:
		if re.match('%s' % filter, line):
			item.append(line)
if item: print ' '.join(item)
