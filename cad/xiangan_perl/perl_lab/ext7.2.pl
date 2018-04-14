#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext7.2.pl                     
#   
# Description:                                
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext7.2.pl 
# $part = substr($string, $initial_position, $length);
my $mineral = substr("Fred J. Flintstone", 8, 5); # gets "Flint"
my $rock = substr "Fred J. Flintstone", 13, 1000; # gets "stone"
print "\n[INFO_1] mineral = \"$mineral\", rock = \"$rock\"\n\n";

my $pebble = substr "Fred J. Flintstone", 13; # gets "stone"
my $out = substr("some very long string", -3, 2); # gets "in"
print "[INFO_2] pebble = \"$pebble\", out = \"$out\"\n\n";

my $long = "some very very long string";
my $right = substr($long, index($long, "l") ); # index($long, "l") = 15
print "[INFO_3] long = \"$long\", right = \"$right\"\n\n";

my $string = "Hello, world!";
substr($string, 0, 5) = "Goodbye"; # $string is now "Goodbye, world!"
print "[INFO_3] string = \"$string\"\n\n";

substr($string, 0, 7) =~ s/goodbye/ByeBye/gi;
print "[INFO_4] string = \"$string\"\n\n";

my $previous_value = substr($string, 0, 5, "Goodbye");

