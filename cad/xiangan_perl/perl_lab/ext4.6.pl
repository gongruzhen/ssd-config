#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Description:
#     the example used to show the useage of
# anchors in Perl language
#
# Author:
#     Peter.Shi <peter_soc_vrf@163.com>
# --------------------------------------------
$_ = "it is just a test for the useage of anchors in Perl. just a test";
if (/^just/) {
    print "\n匹配字符串头的\"just\"子串成功！\n\n";
}
else {
    print "\n匹配字符串头的\"just\"子串失败！\n\n";
}

if (/^it.*test$/) {
    print "\n匹配开始为\"it\", 串尾为\"test\"的字符串成功\n\n";
}

$_ = "called fred and so ...";
if (/\bfred\b/) {
    print "\n[1] Matched \"fred\" word successfully!\n\n";
}

$_ = "frederick";
if (/\bfred\b/) {
    print "\n[2] Matched \"fred\" word successfully!\n\n";
}
else {
    print "\n[2] Failed to match \"fred\" word!\n\n";
}

