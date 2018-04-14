#!/usr/bin/perl -w
use strict;

# file name: ext4.4.pl
#
# the example used to show how to use Character 
# Class Shortcuts in perl
# Author: peter.shi <peter_soc_vrf@163.com>

my $_ = "just for test";
if (/\w+\s+\w+\s+\w/) {
    print "\nMatched string $_ \n\n";
}
else {
    print "\nDo not matched string $_ \n\n";
}

$_ = "test_id = 20010";
if (/\w\s+\=\s+\d+/) {
    print "\nMatched string \"$_\" \n\n";
} else {
    print "\nDo not matched string \"$_\" \n\n";
}

