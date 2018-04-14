#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext4.9.pl                     
#   
# Description:                                
#     The example used to show how to use the 
#     "match the variables" (±‰¡ø≤∂ªÒ)
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
my $val = "hello there, neighbor";
my $val2;
if ($val =~ /(\w+)\s*(\w+),\s*(\w+)/) {
    print "\n v1 = $1, v2 = $2, v3 = $3 \n\n";
    $val2 = $2;
}

$val = "I fear that I will be extinct after 1000 years.";
if ($val =~ /(\d+)\s*(\w+)/) {
    print " [2] v1 = $1, v2 = $2 \n\n";
}

print "\n After some operatons\n\n";
print " The obtained value is \"$val2\" \n";

