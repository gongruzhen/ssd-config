#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename: ext4.8.pl
# 
# Description:                                
#     The example used to show how to use the 
#  Interpolating into Patterns feature in perl
#      
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext4.8.pl
my $val = "just";
my $val2 = "This is just a test example";
if ($val2 =~ /($val)/) {
    print "\n\"$val2\" matched with \"$val\"!\n\n";
}
else {
    print "\n\"$val2\" failed to match with \"$val\"!\n\n";
}

if ($val2 =~ /${val}/) {
    print "\n[2] \"$val2\" matched with \"$val\"!\n\n";
}
else {
    print "\n[2] \"$val2\" failed to match with \"$val\"!\n\n";
}
