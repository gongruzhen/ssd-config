 

#!/usr/bin/perl -w

#######################################################
#
# File Name: make_regression.pl
#
# Description:
#     The script used to run regression test and generate excel report 
#
# Author:
#     xiangan
#
#######################################################
use warnings;
use strict;
use POSIX;
use Encode;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use Term::ANSIColor;
my $tab = " "x4;



my $file = "./test.log";
        my $case_name;
        my $status;
        open (SUMMARY, "<", $file) or die "Can not open $file for reading!\n";
        while (defined (my $line = <SUMMARY>)) {
            chomp $line;
            next if $line =~ /^\s*$/;#skip blank
            $line =~ s/^\s*|\s*$//g;#delete head and tail space

            if ($line =~ /EOF/) {  #search end of file exit while
                last;
            }
            if($line =~ /(\w)(\w)(\w)(\w)\s(\w)(\w)(\w)(\w)\s(\w)(\w)(\w)(\w)\s(\w)(\w)(\w)(\w)/) {

             print"$1\n";
             print"$2\n";
             print"$3\n";
             print"$4\n";
             print"$5\n";
             print"$6\n";
             print"$7\n";
             print"$8\n";
             print"$9\n";
             print"$10\n";
             print"$11\n";
             print"$12\n";
             print"$13\n";
             print"$14\n";
             print"$15\n";
             print"$16\n";
            }
            else {
                }
        }

