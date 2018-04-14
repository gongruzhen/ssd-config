#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext4.12.pl                     
#   
# Description:                                
#     The example used to show the usage of 
#     "The Automatic Match Variables" in Perl
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext4.12.pl
if ("Hello there, neighbor" =~ /\s(\w+),/) {
    print "\nThat was ($`)($&)($').\n\n";
}
