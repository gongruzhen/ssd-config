#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Description:                                
#     The example used to show how to use =~
#   operator in perl language to do expression
#   matching
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
$_ = "just for a test";
print "\nThe value for the default variable \"\$_\" is \"$_\" \n";
if (/^just.*TEST$/i) {
    print "\n[1] Matched a string starts with \"just\" and ends with \"test\"\n\n";
}
else {
    print "\n[1] Failed to match a string starts with \"just\" and ends with \"test\"\n\n";
}

my $val = "just test it";
print "the specified variable val = \"$val\" \n";
if ($val =~ /^just.*it$/) {
    print "\n[2] Matched a string starts with \"just\" and ends with \"it\"\n\n";
}
else {
    print "\n[2] Failed to match a string starts with \"just\" and ends with \"it\"\n\n";
}
