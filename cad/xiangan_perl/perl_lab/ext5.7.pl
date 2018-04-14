#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : .\ext5.7.pl                     
#   
# Description:                                
#     the example for "&&" and "||" operator
#     
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# .\ext5.7.pl 
for (1..6) {
    my $num = $_;
    if ($num < 4 && $num > 1) {
        print "num = $num and this is the \"&&\" branch\n\n";
    }
    elsif ($num == 4 || $num == 6) {
        print "num = $num and this is the \"||\" branch\n\n";
    }
}
