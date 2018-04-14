#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext4.11.pl                     
#   
# Description:                                
#     The example used to show the "Named 
#     Captures" (ÃüÃû²¶»ñ) in Perl
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext4.11.pl
use 5.010;
my $names = 'Fred or Barney';
if( $names =~ m/(?<name1>\w+) (?:and|or) (?<name2>\w+)/ ) {
    print "\nI saw $+{name1} and $+{name2} \n\n";
}

$names = 'Fred Flinstone and Wilma Flinstone';
if( $names =~ m/(?<last_name>\w+) and \w+ \g{last_name}/ ) {
    print "\nI saw $+{last_name}\n\n";
}
