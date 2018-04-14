#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext9.1.pl                     
#   
# Description:                                
#     The simple used to show how to obtain the 
#     command line arguments from @AGRV array
#     directly
#                                              
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext9.1.pl 
my $val1;
my $val2;
my $ERROR = "[ERROR] --";
my $DEBUG = "[DEBUG] --";
print "\n";
if (@ARGV != 2) {
    print "$ERROR You must input two command line arguments. Exiting...\n\n";
    exit;
}
else {
    ($val1, $val2) = @ARGV;
}
print "$DEBUG The obtained value: val1 = $val1, val2 = $val2\n\n";
