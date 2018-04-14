#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext4.14.pl                     
#   
# Description:                                
#     The simple example used to show the following
#     itmes in Perl:
#        1) Different Delimiters for replacement
#        2) Option Modifiers for replacement
#        3) The Binding Operator for replacement
#        4) Case Shifting operation
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------

# 1) Different Delimiters
$_ = "today is 12th Jan. 2014";
print "\n [1]before replacement and value = \"$_\"\n";
s/today/tommorw/;
print "\n [1]after  replacement and value = \"$_\"\n\n";


$_ = "today is 12th Jan. 2014";
print "\n [2]before replacement and value = \"$_\"\n";
s#today#tommorw#;
print "\n [2]after  replacement and value = \"$_\"\n\n";


$_ = "today is 12th Jan. 2014";
print "\n [3]before replacement and value = \"$_\"\n";
s<today>{tommorw};
print "\n [3]after  replacement and value = \"$_\"\n\n";

# 2) Option Modifiers
$_ = "TODAY is 12th Jan. 2014";
print "\n [4]before replacement and value = \"$_\"\n";
s/today/tommorw/;
print "\n [4]after  replacement and value = \"$_\"\n\n";


s/today/tommorw/i;
print "\n [5]after  replacement and value = \"$_\"\n\n";


$_ = "\n The following is the final result:\n- status: pass \n- __END__ \n\n Simulation finished\n";
print "\n [7]before replacement and value = \"$_\"\n";
s/.*(__END__).*/$1/;
print "\n [7]after  replacement and value = \"$_\"\n\n";

$_ = "\n The following is the final result:\n- status: pass \n- __END__ \n\n Simulation finished\n";
print "\n [8]before replacement and value = \"$_\"\n";
s/.*(__END__).*/$1/s;
print "\n [8]after  replacement and value = \"$_\"\n\n";


# 3) The Binding Operator
$_ = "today is 12th Jan. 2014";
my $val = "TODAY is 12th Jan. 2014";
print "[9] before replacement:\n";
print "                       \$_   = \"$_\"\n";
print "                       \$val = \"$val\"\n";
$val =~ s/today/tommorw/i;
print "[9] after  replacement:\n";
print "                       \$_   = \"$_\"\n";
print "                       \$val = \"$val\"\n";

# 4) Case Shifting 
$_ = "I saw Barney with Fred.";
print "[10] before replacement and value = \"$_\"\n";
s/(fred|barney)/\U$1/gi; # $_ is now "I saw BARNEY with FRED."
print "[11] after  replacement and value = \"$_\"\n\n";

s/(fred|barney)/\L$1/gi; # $_ is now "I saw barney with fred."
print "[12] after  replacement and value = \"$_\"\n\n";

s/(\w+) with (\w+)/\U$2\E with $1/i; # $_ is now "I saw FRED with barney."
print "[13] after  replacement and value = \"$_\"\n\n";

s/(fred|barney)/\u$1/ig; # $_ is now "I saw FRED with Barney."
print "[14] after  replacement and value = \"$_\"\n\n";

s/(fred|barney)/\u\L$1/ig; # $_ is now "I saw Fred with Barney."
print "[15] after  replacement and value = \"$_\"\n\n";

my $name = "barney";
print "Hello, \L\u$name\E, would you like to play a game?\n\n";
