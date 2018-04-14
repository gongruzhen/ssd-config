#!/usr/bin/perl -w

use 5.010;
use strict;
use Data::Dumper;

# -------------------------------------------------------------
# The example used to show the special characters in regular
# expression 
#
# Author:
# --------------------
#    peter.shi <peter_soc_vrf@163.com>
# -------------------------------------------------------------
# ext4.1.pl
$_ = "a";
if (/.?/) {
    print "\n�ɹ�ƥ������з�֮��������ַ�0�λ���1��\n\n";
}
$_ = "\\\\\"ƥ��\"";
if (/\\+/) {
    print "�ɹ�ƥ�䷴б������1��\n\n";
}

if (/\\{2,}/) {
    print "�ɹ�ƥ�䷴б������2��\n\n";
}

$_ = "goodgoodgoodbadbad";
if (/(good){2,4}/) {
    print "�ɹ�ƥ��\"good\"�ַ���2�ε�4��\n\n";
}

if (/(good){4,9}/) {
    print "�ɹ�ƥ��\"good\"�ַ���4�ε�9��\n\n";
}
else {
    print "ƥ��\"good\"�ַ���4�ε�9��ʧ��\n\n";
}

if (/(bye)*/) {
    print "�ɹ�ƥ��\"bye\"�ַ�������\n\n";
}
if (/(bye)+/) {
    print "ƥ��\"bye\"�ַ�����һ�γɹ�\n\n";
}
else {
    print "ƥ��\"bye\"�ַ�������һ��ʧ��\n\n";
}

# ģʽ�����ʵ��
$_ = "yabba dabba doo";
if (/y(....) d\1/) {
    print "�ɹ�ƥ�䵽��������һ���ַ���: y������4���ǻ����ַ���֮���ǿո������ĸd,�ٺ����ظ�֮ǰ��4���ǻ����ַ�\n\n";
}
else {
    print "ƥ����������һ���ַ���ʧ�� : y������4���ǻ����ַ���֮���ǿո������ĸd,�ٺ����ظ�֮ǰ��4���ǻ����ַ�\n\n";    
}

$_ = "aa11bb";
if (/(.)\111/) {                # perl�ᾡ���ܶ�ĳ��Է������ã���������111�����ţ�����ƥ��ʧ��
    print "matched!\n\n";
}

# ������������ķ�����ʹ��"\g{N}"�ķ���������ʽ (perl 5.10������: use 5.010;)
if (/(.)\g{1}11/) {
    print "g\{N\} format matched!\n\n";
}
else {
    print "g\{N\} format do not matched!\n\n";
}


