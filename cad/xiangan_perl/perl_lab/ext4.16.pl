#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext4.16.pl                     
#   
# Description:                                
#     The example used to show the usage of 
#     join function in Perl
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
my $x = join ":", 4, 6, 8, 10, 12; # $x is "4:6:8:10:12"
print "\n[1]after join and the value = \"$x\"\n\n";

my @values = split /:/, $x; # @values is (4, 6, 8, 10, 12)
print "[2]after split and the value = \"@values\"\n\n";

my $z = join "-", @values; # $z is "4-6-8-10-12"
print "[3]after join and the value = \"$z\"\n\n";
