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
use Time::HiRes qw(usleep time);

use POSIX;
use Encode;
use Term::ANSIColor;
my $tab = " "x4;


my$i=0;
while(1){
usleep(100000);
print("$i++\n");
$i++;
}


#------------parse summary report pass or fail & print on results on terminal-----------
        my $file = "./a.txt";
        my $target_line;
        my $i=0;
        my $status;
        open (SUMMARY, "<", $file) or die "Can not open $file for reading!\n";
        while (defined (my $line = <SUMMARY>)) {
            chomp $line;
            next if $line =~ /^\s*$/;#skip blank
            $line =~ s/^\s*|\s*$//g;#delete head and tail space

            if ($line =~ /EOF/) {  #search end of file exit while
                last;
            }
            if($line =~ /(\w+)\sLD_LIBRARY_PATH\s*/) {
            $target_line =$line ;
            system("sed -i '/.*LD_LIBRARY_PATH.*/d' ./a.txt ");
            $i=$i+1; 
            }
            elsif ($i) {
                   $i=0;
                    system("sed -i -e '/.*LM_LICENSE_FILE.*/a\ $target_line' ./a.txt");
            }
            else{
            }
        }
        close(SUMMARY);
    print color"bold white";
    print "Complete \n";
    print "-"x40 . "\n";
    print color 'reset';


sub ColorMessage{
my($colors,$messages)=@_;
print color"bold $colors";
print "$messages\n";
print color 'reset';
}
#ColorMessage('green','hello'); #test for color print//////






