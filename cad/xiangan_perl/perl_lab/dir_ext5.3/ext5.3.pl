#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext5.3.pl                     
#   
# Description:                                
#     the example used to show the usage of 
#     elsif struct in Perl
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext5.3.pl 
my $file = "sim.log";
print "\n";
open (LOG, "<", $file) or die "Can not open $file for reading!\n";
while (defined (my $line = <LOG>)) {
    if ($line =~ /^\s*$/) {
        print "it is a empty line!\n\n";
    }
    elsif ($line =~ /compile\s+rtl/i) {
        print "start to compile rtl\n\n";
    }
    elsif ($line =~/teststatus:\s*(\w+)/) {
        print "detected the test status and status is \"$1\"\n\n";
    }
    elsif ($line =~/failed_reason:\s+(.*)/) {
        print " detect the failed reason and the reason is " ."\"" ."$1". "\"\n\n";
    }
}
close (LOG);
