#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext5.2.pl                     
#   
# Description:                                
#     the simple used to show the useage of
#     until struct in Perl
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext5.2.pl 
my $j = 1;
my $i = 20;
print "\n";
until ($j > $i) {
    $j *= 2;
    print "j = $j \n\n";
}
