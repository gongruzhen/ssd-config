#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext7.1.pl                     
#   
# Description:                                
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext6.6.pl 
my $stuff = "Howdy world!";
my $where = index($stuff, "wor");
print "\n[INFO_1] input string = \"$stuff\", where = $where\n\n";

my $where1 = index($stuff, "w"); # 2
my $where2 = index($stuff, "w", $where1 + 1); # 6
my $where3 = index($stuff, "w", $where2 + 1); # -1 (not found)
print "[INFO_2] input string = \"$stuff\", where1 = $where1, where2 = $where2, where3 = $where3\n\n";

my $fred = "Yabba dabba doo!";
$where1 = rindex($fred, "abba");              # 7
$where2 = rindex($fred, "abba", $where1 - 1); # 1
$where3 = rindex($fred, "abba", $where2 - 1); # -1
print "[INFO_3] input string = \"$fred\", where1 = $where1, where2 = $where2, where3 = $where3\n\n";



