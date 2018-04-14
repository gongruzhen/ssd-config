#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext4.13.pl                     
#   
# Description:                                
#     The example used to show the usage of
#     replace operator "s///" and "/g" option
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
$_ = "He's out bowling with Barney tonight";
print "\n[1] Before replacement and  val = \"$_\"\n";
s/Barney/Fred/;
print "[1] after replacement and  val = \"$_\"\n\n";

# the value will not be changed if failed to do replacement
s/TOnight/this afternoon/;
print "[2] after replacement and  val = \"$_\"\n\n";

# -------------------------------
# the useage of "/g" option
# -------------------------------
$_ = "home, sweet home!";
print "[3] before replacement and val = \"$_\"\n";
s/home/cave/;
print "[3] after  replacement and val = \"$_\"\n\n";

$_ = "home, sweet home!";
print "[4] before replacement and val = \"$_\"\n";
s/home/cave/g;
print "[4] after  replacement and val = \"$_\"\n\n";

$_ = " home, sweet home! ";
print "[5] before replacement and val = \"$_\"\n";
s/^\s*|\s*$//g;
print "[5] after  replacement and val = \"$_\"\n\n";
