#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext4.10.pl                     
#   
# Description:                                
#     The example used to show the "Noncapturing 
#     Parentheses" (不捕获模式) in Perl
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext4.10.pl
my $val = "This is just a simple example";
if ($val =~ /^this\s+is\s+(?:just)\s+(.*)$/i) {
    print "\nThe matched value is \"$1\" \n\n";
}
