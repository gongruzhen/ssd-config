#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext6.3.pl                     
#   
# Description:                                
#     The example used to show how to use 
#     directory handle in Perl
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext6.3.pl 
my $dir = "./";
opendir DIR, $dir or die "Cannot open $dir: $!";
print "\n";
foreach my $file (readdir DIR) {
    if ($file eq ".") {
        print "[WARN] -- current obtained file in $dir dir starts with \".\"  and skip it\n";
    }
    elsif ($file eq "..") {
        print "[WARN] -- current obtained file in $dir dir starts with \"..\" and skip it\n";
    }
    else {
        print "[INFO] -- current obtained file in $dir dir is $file\n";
    }
}
closedir DIR;

