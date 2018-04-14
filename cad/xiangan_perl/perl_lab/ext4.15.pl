#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext4.15.pl                     
#   
# Description:                                
#     the example used to show the useage of 
#     split operator in Perl 
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
my @fields = split /:/, "abc:def:g:h";
print "\n[1] obtained list = @fields \n\n";

@fields = split /:/, "abc:def::g:h";
print "\n[2] obtained list = @fields \n\n";

@fields = split /:/, ":::a:b:c:::";
print "\n[3] obtained list = @fields \n\n";


my $some_input = "This is a \t test.\n";
my @args = split(/\s+/, $some_input); # ("This", "is", "a", "test.")
print "\n[4] obtained list = @args \n\n";


$_ = "This is a \t test.\n";
@fields = split; # like split /\s+/, $_;
print "\n[5] obtained list = @fields \n\n";
