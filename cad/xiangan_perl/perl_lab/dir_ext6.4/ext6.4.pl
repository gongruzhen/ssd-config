#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext6.4.pl                     
#   
# Description:                                
#     
#     
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext6.4.pl 
foreach my $file (glob "./logs/*.old") {
    my $newfile = $file;
    $newfile =~ s/\.old$/.new/;
    if (-e $newfile) {
        warn "can't rename $file to $newfile: $newfile exists\n";
    }
    elsif (rename $file, $newfile) {
        ## success, do nothing
        print "rename $file to $newfile successfully!\n";
    }
    else {
        warn "rename $file to $newfile failed: $!\n";
    }
}
