#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : .\ext4.17.pl                     
#   
# Description:                                
#     a example for using m// operator in
#     List Context
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext4.17.pl
my $test = "Hello there, neighbor!";
my($first, $second, $third) = ($test =~ /(\S+) (\S+), (\S+)/);
print "\nfirst = \"$first\", second = \"$second\", third = \"$third\"\n\n";

my $text = "Fred dropped a 5 ton granite block on Mr. Slate";
my @words = ($text =~ /([a-z]+)/ig);
print "Result: \"@words\"\n\n";

