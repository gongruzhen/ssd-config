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
my @small_files;

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
         
       if (-s $file < 100_000) { # 100KB
        push (@small_files, $file);
        }
        print "[INFO] -- current obtained file in $dir dir is $file\n";
    }
}
closedir DIR;
if (defined $small_files[0]) {
    my $num = @small_files;
    print "\nThe following $num files' size are smaller than 100KB:\n";
    print "-"x40 . "\n";
    print "@small_files\n\n";
}




















