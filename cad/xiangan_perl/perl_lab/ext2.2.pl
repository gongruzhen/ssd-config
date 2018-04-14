#!/usr/bin/perl -w
use strict;
my $value1 = 5;
my $value2 = 7;
my $res1 = $value1 | $value2;
my $res2 = $value1 & $value2;
my $res3 = ~ $value1;
my $res4 = $value1 << 2;
my $res5 = $value1 >> 2;
print "value1 = $value1, $value2 = $value2 \n";
print "-"x30 . "\n";
print "value1 | value2 = $res1\n";
print "value1 & value2 = $res2\n";
print "~ value1 = $res3\n";
print "value1 << 2 = $res4\n";
print "value1 >> 2 = $res5\n";

