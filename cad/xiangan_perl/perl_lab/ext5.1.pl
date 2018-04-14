#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext5.1.pl                     
#   
# Description:                                
#     the example is for unless control struct
#     
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext5.1.pl 
my $fred = "Cody";
unless ($fred =~ /^[A-Z_]\w*$/i) {
    print "\nThe value of \$fred doesn't look like a Perl identifier name.\n\n";
}

my $mon = "Feb";
unless ($mon =/^Feb/) {
    print "This month has at least thirty days.\n\n";
} 
else {
    print "Do you see what's going on here?\n\n";
}

$mon = "Mar";
unless ($mon =~ /^Feb/) {
    print "This month has at least thirty days.\n\n";
} 
else {
    print "Do you see what's going on here?\n\n";
}
