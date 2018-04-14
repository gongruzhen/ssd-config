#!/usr/bin/perl -w
use strict;
use File::Find;
#my $sv_src_dir = "./"; #sv src dir current directory
#opendir DIR, $sv_src_dir or die "Cannot open $sv_src_dir: $!";
#foreach my $file (readdir DIR) {
#    if ($file =~ /(\w+).sv$/) {
#       system" perl -pi -e 's/test_spw_reg_write_read/$1/g' $file "; #$1 is equal to (\w+)
#    }
#}
#closedir DIR;

my $sv_src_dir = "./";
sub wanted {
my $file=$File::Find::name;
   if ($file =~ /(\w+).sv$/) {
     system" perl -pi -e 's/test_spw_reg_write_read/$1/g' $1.sv "; #$1 is equal to (\w+)
    }
}
find(\&wanted,  $sv_src_dir); # recursive path for finding all the *.sv file

