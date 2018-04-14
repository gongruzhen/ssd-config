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
    print "\nƥ���ַ���ͷ��\"just\"�Ӵ��ɹ���\n\n";
}
else {
    print "\nƥ���ַ���ͷ��\"just\"�Ӵ�ʧ�ܣ�\n\n";
}

if (/^it.*test$/) {
    print "\nƥ�俪ʼΪ\"it\", ��βΪ\"test\"���ַ����ɹ�\n\n";
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

