#!/usr/bin/perl -w

#######################################################
#
# File Name: make_regression.pl
#
# Description:
#     The script used to run regression test
#
# Author:
#     xiangan
#
#######################################################
use strict;
use Term::ANSIColor;
my $tab = " "x4;
#case list here
my @cases = ("testcaseBmcDebugBmcNVMeExample" ,
             "testcaseBmcDebugBmc"
            ) ;

my $case_num = @cases ; #loop counter

my @pass_cases;
my @fail_cases;
my @unknown_cases;

sub ColorMessage{
my($colors,$messages)=@_;
print color"bold $colors";
print "$messages\n";
print color 'reset';
}
#ColorMessage('green','hello'); #test for color print
#run every case
for (my $i=0 ; $i<$case_num ; $i++) {
system("make comp sim TEST=$cases[$i] VERDI=1 COV=1 ");# +compile +simulation +testcase_name +fsdb +coverage
}

#parse run.log pass or fail 
for (my $i=0 ; $i<$case_num ; $i++) {
my $log_dir = "obj/$cases[$i]/seed_0/"; #log dir
opendir DIR, $log_dir or die "Cannot open $log_dir: $!";
foreach my $file (readdir DIR) {
    if ($file eq "run.log") {
        $file = "$log_dir/run.log";
        my $case_name;
        my $status;
        open (RUNLOG, "<", $file) or die "Can not open $file for reading!\n";
        while (defined (my $line = <RUNLOG>)) {
            chomp $line;
            next if $line =~ /^\s*$/;#skip blank
            $line =~ s/^\s*|\s*$//g;#delete head and tail space
            $case_name =$cases[$i] ;
            if ($line =~ /^The\s*case\s*(\w+)/) {  #search case pass fail error key words
                $status = $1;
                $status =~ s/^\s*|\s*$//g;
                last;
            }
        }
        if (defined $case_name ) {
            if ($status =~ /^pass\s*/i) {        ##pass  ignore case
                push (@pass_cases, $case_name);
            } elsif ($status =~ /^fail\s*/i) {
                push (@fail_cases, $case_name);
            } else {
                push (@unknown_cases, $case_name); ##unknown pass or fail 
            }
        }
        close(RUNLOG);
    }
    else {
    }
}
closedir DIR;
}
    print color"bold white";
    print "Complete to parse the simulation all run.log files \n";
    print "-"x40 . "\n";
    print color 'reset';

my $fail_num=@fail_cases;
my $pass_num=@pass_cases;
my $unknow_num=@unknown_cases;


#print final cases summary
if ($fail_num > 0) {
    print color"bold red";
    print "$fail_num cases fail     : @fail_cases\n\n";
    print "$pass_num cases passed   : @pass_cases\n\n";
    print "$unknow_num cases unknown  : @unknown_cases\n\n";
    print color 'reset';

}
elsif($unknow_num >0) {
    print color"bold yellow";
    print "$unknow_num cases unknown: @unknown_cases\n\n";
    print "$pass_num cases passed : @pass_cases\n\n";
    print color 'reset';
   }
else {
    print color"bold green";
    print "all $pass_num cases passed : @pass_cases\n\n";
    print color 'reset';
}

