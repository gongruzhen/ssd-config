#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext5.6.pl                     
#   
# Description:                                
#     a example for "?:" operator
#     
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext5.6.pl 
for (my $width = 0; $width < 70; $width = $width + 10) {
    my $size = ($width < 10) ? "small"  :
               ($width < 20) ? "medium" :
               ($width < 50) ? "large"  :
               "extra-large"; # default
    print "width = $width and corresponding size = $size \n";
}
