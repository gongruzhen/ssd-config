#!/usr/bin/perl -w

# ----------------------------------------------------------
# ���ʵ����Ϊ�˶Ե������ַ�����˫�����ַ�����һ����˵
#
# Author:
# -----------------------
#      peter.shi <peter_soc_vrf@163.com
# ----------------------------------------------------------

use strict;

my $val1 = 'hello world\n\n';
my $val2 = "hello world\n\n";
print $val1;
print "\n";
print $val2;

my $val3 = '\'\\';
print $val3;
print "\n\n";

my $val4 = 'verification';
my $val5 = "\U$val4\n";
my $val6 = "\L$val5\n";

print $val4;
print "\n";
print $val5;
print $val6;
