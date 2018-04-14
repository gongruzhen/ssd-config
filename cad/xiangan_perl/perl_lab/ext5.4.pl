#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext5.4.pl                     
#   
# Description:                                
#     the example for "for loop" in Perl
#     
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext5.4.pl 
print "\n";
for (my $i = 0; $i < 5; $i++) {
    print "i = $i \n";
}

my $j = 0;
print "-----------------------------------------\n";
while($j < 5) {
    print "j = $j \n";
    $j += 1;
}

