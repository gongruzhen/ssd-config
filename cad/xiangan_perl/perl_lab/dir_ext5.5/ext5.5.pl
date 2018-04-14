#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext5.5.pl                     
#   
# Description:                                
#     
#     
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext5.5.pl 
my $file = "info.log";
open (LOG, "<", $file) or die "Can not open $file for reading!\n";
my $line_num = 0;
while (defined (my $line = <LOG>)) {
    $line_num++;
    print "line_num = $line_num \n";
    next if ($line =~ /^phone/i);
    last if ($line =~ /^version/i);
    print "current line = $line\n\n";    
}
close (LOG);

print "\n=============================\n";
for (my $i = 0; $i < 2; $i++) {
    print "\ni = $i \n";
    for(2..4) {
        last if ($_ == 3);
        print "i = $i, j = $_ \n";
    }
}

print "\n-----------------------------\n";
FOR_LOOP: for (my $i = 0; $i < 2; $i++) {
    print "\ni = $i \n";
    for(2..4) {
        last FOR_LOOP if ($_ == 3);
        print "i = $i, j = $_ \n";
    }
}
