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
def merge_number(numlist):
	if len(numlist) <= 2:
		return [str(x) for x in numlist]
	b = []
	a = [int(x) for x in numlist]
	for i in range(0, len(a)):
		if i == len(a) - 1:
			b.append('%d' % a[i])
			break
		if a[i+1] == a[i]+1:
			if len(b) == 0:
				b.append('%d-' % a[i])
				continue
			if '-' not in b[-1]:
				b.append('%d-' % a[i])
		else:
			b.append('%d,' % a[i])
	return ''.join(b)

def parse_dump(device, file):
	if device:
		dumpfile = '/debug/df%s/dump' % device
	elif file:
		dumpfile = file
	else:
		abort('Specify device or dump-file for function parse_dump!')
	try:
		fh = open(dumpfile, 'r')
	except:
		abort('open file %s error!' % dumpfile)
	dump = {'context' : fh.readlines()}
	fh.close()

	# ['variables', 'log2phy', 'sbs']
	for line in dump['context']:
		line = line.strip()
		m = re.match('\[section-tag:\s*(\w+)\]', line)
		if m:
			section = m.group(1)
			dump[section] = []
		else:
			dump[section].append(line)

	# rebuild ['variables', 'log2phy'] to dict
	for section in ('variables', 'log2phy'):
		d = {}
		for line in dump[section]:
			a = line.split('=')
			d[a[0].strip()] = a[1].strip()
		dump[section] = d
	return dump

def parse_sb(all_sbs_info, sb_index):
	sbinfo = []
	for i, line in enumerate(all_sbs_info):
		m = re.match('sb_index=%s,state' % sb_index, line)
		if m:
			sbinfo.append(line)
			break
	for line in all_sbs_info[i+1:]:
		if line.startswith('------'):
			break
		sbinfo.append(line)

	sb = {'info': sbinfo, 'info_kv': {}, 'rg': {}, 'bad_luns': []}
	for line in sb['info']:
		m = re.match('sb_index.*', line)
		if m:
			for w in line.split(','):
				a = w.split('=')
				sb['info_kv'][a[0].strip()] = a[1].strip()
			continue

		m = re.match('phy_index=(-*\d+).*start_lun=(\d+).*parity_lun=(\d+).*used_data_luns=([-\d]+)', line)
		if m:
			rg_index = int(m.group(1))
			sb['rg'][rg_index] = {}
			sb['rg'][rg_index]['start_lun'] = m.group(2)
			sb['rg'][rg_index]['parity_lun'] = m.group(3)
			sb['rg'][rg_index]['data_luns'] = m.group(4).split('-')
			continue

		m = re.match('badlun_bitmap.*', line)
		if m:
			sb['info_kv']['badlun_bitmap'] = line.split('=')[1]
			continue

	lun = 0
	for qw in sb['info_kv']['badlun_bitmap'].split('-'):
		for b in range(0, 64):
			if (1L << b) & long(qw, 16):
				sb['bad_luns'].append(lun)
			lun += 1
	# sb-keys: info, info_kv, rg, bad_luns; rg-X-keys: start_lun, parity_lun, data_luns
	return sb

# -----------------------------------------------------------
file = None
device = None
sb_index = -1

try:
	opts, args = getopt.gnu_getopt(sys.argv[1:], 'd:f:s:', ['device', 'file', 'super-block-index'])
	for name, value in opts:
		if name in ('-d', '--device'):
			device = value
		elif name in ('-f', '--file'):
			file = value
		elif name in ('-s', 'super-block-index'):
			sb_index = int(value)
			if sb_index < 0:
				abort('sb_index should be >= 0!')
	if not device and not file:
		raise Exception
except:
	sys.exit('Usage: %s <-d --device=(a b c ...)> <-f, --dump-file=sbs-file> [-s, super-block-index=sb_index]' % sys.argv[0])

dump = parse_dump(device, file)
if sb_index < 0:
	for line in dump['sbs']:
		print line
	sys.exit(0)

if sb_index >= int(dump['variables']['sb_count']):
	abort('sb_index %d overange %d!' % (sb_index, int(dump['variables']['sb_count'])-1))

sb = parse_sb(dump['sbs'], sb_index)
for line in sb['info']:
	print line
print '--------------------------------------------------------------------'
print 'sb_index=%d' % sb_index
print 'sb_count=%s' % dump['variables']['sb_count']
print 'plane_count=%s' % dump['variables']['plane_count']
print 'rg_count=%s' % dump['variables']['rg_count']
print 'rg_max_lun_count=%s' % dump['variables']['rg_max_luns']
print 'sb_rg_lun_count=%s' % sb['info_kv']['min_available_luns']
print 'bad_luns=%s' % merge_number(sb['bad_luns'])
for i in sorted(sb['rg'].keys()):
	rg = sb['rg'][i]
	if len(rg['data_luns'])+1 != int(sb['info_kv']['min_available_luns']):
		abort('error data_luns length %d!' % len(rg['data_luns'])+1)
	print 'rg[%d]: start_lun=%s data_luns=%s parity_lun=%s' % (i, rg['start_lun'], merge_number(rg['data_luns']), rg['parity_lun'])
