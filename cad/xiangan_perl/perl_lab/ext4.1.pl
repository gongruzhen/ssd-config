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
    print "\n成功匹配除换行符之外的任意字符0次或者1次\n\n";
}
$_ = "\\\\\"匹配\"";
if (/\\+/) {
    print "成功匹配反斜线至少1次\n\n";
}

if (/\\{2,}/) {
    print "成功匹配反斜线至少2次\n\n";
}

$_ = "goodgoodgoodbadbad";
if (/(good){2,4}/) {
    print "成功匹配\"good\"字符串2次到4次\n\n";
}

if (/(good){4,9}/) {
    print "成功匹配\"good\"字符串4次到9次\n\n";
}
else {
    print "匹配\"good\"字符串4次到9次失败\n\n";
}

if (/(bye)*/) {
    print "成功匹配\"bye\"字符任意多次\n\n";
}
if (/(bye)+/) {
    print "匹配\"bye\"字符至少一次成功\n\n";
}
else {
    print "匹配\"bye\"字符串至少一次失败\n\n";
}

# 模式分组的实例
$_ = "yabba dabba doo";
if (/y(....) d\1/) {
    print "成功匹配到下面这样一个字符串: y后面是4个非换行字符，之后是空格符接字母d,再后面重复之前的4个非换行字符\n\n";
}
else {
    print "匹配下面这样一个字符串失败 : y后面是4个非换行字符，之后是空格符接字母d,再后面重复之前的4个非换行字符\n\n";    
}

$_ = "aa11bb";
if (/(.)\111/) {                # perl会尽可能多的尝试方向引用，但不存在111组括号，所以匹配失败
    print "matched!\n\n";
}

# 消除上述歧义的方法是使用"\g{N}"的方向引用形式 (perl 5.10的特性: use 5.010;)
if (/(.)\g{1}11/) {
    print "g\{N\} format matched!\n\n";
}
else {
    print "g\{N\} format do not matched!\n\n";
}


