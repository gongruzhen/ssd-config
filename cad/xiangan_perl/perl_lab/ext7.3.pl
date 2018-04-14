#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : .\ext7.3.pl                     
#   
# Description:                                
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# .\ext7.3.pl 

my @data_arrays = qw(4 2 10 23 7 40 30 20);
my @rise_arrays = sort {$a <=> $b} @data_arrays;
my @fail_arrays = sort {$b <=> $a} @data_arrays;
print "\n[INFO_1] data_arrays = @data_arrays\n";
print   "[INFO_1] rise_arrays = @rise_arrays\n";
print   "[INFO_1] fail_arrays = @fail_arrays\n\n";

my @str_arrays = qw(an good buy eggs cups);
my @rise_strs  = sort {$a cmp $b} @str_arrays;
my @fail_strs  = sort {$b cmp $a} @str_arrays;
print "[INFO_2] str_arrays = @str_arrays\n";
print "[INFO_2] rise_strs  = @rise_strs\n";
print "[INFO_2] fail_strs  = @fail_strs\n\n";


