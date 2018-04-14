#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext9.2.pl                     
#   
# Description:                                
#     The example used to show how to obtain 
#     arguments according to different input
# `   options
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext9.2.pl 
my $DEBUG = "[DEBUG] --";
my $ERROR = "[ERROR] --";
my $help = 0;
my $file_name;
my $case_num;
if ( @ARGV > 0 ) {
    for (my $i=0; $i <= $#ARGV; $i++) {
        if ($ARGV[$i] eq "-file") {
            $file_name = $ARGV[++$i];
        }
        elsif ($ARGV[$i] eq "-case_num") {
            $case_num = $ARGV[++$i];
        }
        elsif ($ARGV[$i] eq "-help" || $ARGV[$i] eq "-h") {
            $help = 1;
            &help_msg();
        }
        elsif ($ARGV[$i] ne "-file" && $ARGV[$i] ne "-case_num" && 
               $ARGV[$i] ne "-help" && $ARGV[$i] ne "-h") {
            print "$ERROR $ARGV[$i] is not a valid option. Exiting...\n\n";
            exit;
        }
    }
}
print "\n";
print "The obtained values:\n";
print "  file_name = $file_name\n" if defined $file_name;
print "  case_num  = $case_num \n" if defined $case_num ;

sub help_msg() {
    print "\n";
    print "print out the help information\n\n";
    exit;
}
