#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext9.3.pl                     
#   
# Description:                                
#     The example used to show how to parse the
#     command line options use Getopt::Long package
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext9.3.pl 
use Getopt::Long;

my $DEBUG = "[DEBUG] --";
my $ERROR = "[ERROR] --";
my $help = 0;
my $file_name;
my $case_num;

if (@ARGV > 0) {
    GetOptions(
        'file_name=s' => \$file_name,
        'case_num=s'  => \$case_num,
        'help!'       => \$help,
        );
}
&help_msg() if $help;

print "\n";
print "The obtained values:\n";
print "  file_name = $file_name\n" if defined $file_name;
print "  case_num  = $case_num \n" if defined $case_num ;

sub help_msg() {
    print "\n";
    print "print out the help information\n\n";
    exit;
}
