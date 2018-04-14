#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext6.1.pl                     
#   
# Description:                                
#     the example used to show how to use the
#     file test operators in Perl
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext6.1.pl 
my @files = qw(ext4.0.pl ext4.1.pl ext4.2.pl ext4.3.pl ext4.4.pl ext4.5.pl ext4.6.pl);
my @small_files;
print "\n";
foreach my $file (@files) {
    if (! -e $file) {
        print "$file does not exist in current dir\n\n";
    }
    elsif (-s $file < 100_000) { # 100KB
        push (@small_files, $file);
    }
}

if (defined $small_files[0]) {
    my $num = @small_files;
    print "\nThe following $num files' size are smaller than 100KB:\n";
    print "-"x40 . "\n";
    print "@small_files\n\n";
}

