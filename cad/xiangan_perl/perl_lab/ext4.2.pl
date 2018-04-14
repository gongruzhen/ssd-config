#!/usr/bin/perl -w
use strict;
my $_ = "one day";
if (/[oda]/) {
    print "matched for string $_\n";
}
else {
    print "not matched!\n";
}
