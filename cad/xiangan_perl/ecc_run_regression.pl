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
#case list here
my $random_number=1000;
my $year_month_day = strftime("%y%m%d" , localtime());
#print "$year_month_day\n ";

#print "@nandtype\n ";
#print "@cases\n ";

my @pass_cases;
my @fail_cases;
my @unknown_cases;

sub ColorMessage{
my($colors,$messages)=@_;
print color"bold $colors";
print "$messages\n";
print color 'reset';
}
#ColorMessage('green','hello'); #test for color print//////
# pre-compile ncsim lib ;just +simulation & +testcase_name


#############run regression of all ecc cases for random $random_number times ############

#################flow control 2cases (extreme condition testbubblecnt_random  ) ##############

system("cd Extrem_condition/                  && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd Extrem_condition/                  && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd Extrem_condition_bubblecnt_random/ && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd Extrem_condition_bubblecnt_random/ && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd


#################Error reporting 4cases (t15,l06b,m16,bics2) ##############
system("cd error_report_T15/   && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd error_report_T15/   && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd error_report_BiCS2/ && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd error_report_BiCS2/ && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd error_report_L06B/  && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd error_report_L06B/  && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd error_report_M16/   && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd error_report_M16/   && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd


#################FPGA SKIM tests 4cases for (error_report ,random error ,random bubble ,extreme flow control) ##############
system("cd random_fpga_skim_Fixed_Error/        && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_fpga_skim_Fixed_Error/        && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_fpga_skim_Random_Error/       && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_fpga_skim_Random_Error/       && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_fpga_skim_Random_Bubble/      && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_fpga_skim_Random_Bubble/      && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_fpga_skim_ExtremeFlowcontrol/ && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_fpga_skim_ExtremeFlowcontrol/ && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd

#################Error injecting tests  12 cases for (mini,medium,high ) x (t15,l06b,m16,bics2) ##############
system("cd random_T15_mini/     && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_T15_mini/     && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_T15_medium/   && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_T15_medium/   && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_T15_high/     && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_T15_high/     && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_M16_mini/     && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_M16_mini/     && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_M16_medium/   && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_M16_medium/   && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_M16_high/     && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_M16_high/     && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_L06B_mini/    && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_L06B_mini/    && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_L06B_medium/  && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_L06B_medium/  && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_L06B_high/    && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_L06B_high/    && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_BiCS2_mini/   && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_BiCS2_mini/   && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_BiCS2_medium/ && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_BiCS2_medium/ && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd
system("cd random_BiCS2_high/   && perl ../../../tools/perl/gen_randoms.pl $random_number template"); #enter into every directory and gen random seed test0-99
system("cd random_BiCS2_high/   && ls -d test_* | parallel -j4 make single -C {}");#parallel run 4 case use make single cmd



######################calculate all cases codewords count############################
my $log = "./regression_summary.log";
open (LOG, ">", $log) or die "can't not open $log for write!\n";
my $onetest_cnt=0;
my $onecase_cnt=0; 
my @cases = (
             "Extrem_condition"  ,
             "Extrem_condition_bubblecnt_random",
             "error_report_T15",
             "error_report_BiCS2",
             "error_report_L06B",
             "error_report_M16",
             "random_fpga_skim_Fixed_Error",
             "random_fpga_skim_Random_Error",
             "random_fpga_skim_Random_Bubble",
             "random_fpga_skim_ExtremeFlowcontrol",
             "random_T15_mini",
             "random_T15_medium",
             "random_T15_high",
             "random_M16_mini",
             "random_M16_medium",
             "random_M16_high",
             "random_L06B_mini",
             "random_L06B_medium",
             "random_L06B_high",
             "random_BiCS2_mini",
             "random_BiCS2_medium",
             "random_BiCS2_high"
            ) ;
my $case_num = @cases ; #loop counter


printf LOG "-------------------codeword calculation sum-result of every case in every random test---------- \n";
printf LOG " \n";
print color"bold green";
print "-------------------codeword calculation sum-result of every case in every random test---------- \n";
print color 'reset';

for (my $loop_times=0;$loop_times<$case_num;$loop_times++){
for (my $test_number =0;$test_number<$random_number;$test_number++  ){
        my $file = "$cases[$loop_times]/test_$test_number/log";
        my $case_name;
        my $status;
        open (SUMMARY, "<", $file) or die "Can not open $file for reading!\n";
        while (defined (my $line = <SUMMARY>)) {
            chomp $line;
            next if $line =~ /^\s*$/;#skip blank
            $line =~ s/^\s*|\s*$//g;#delete head and tail space

            if ($line =~ /This is a wrong command.*/) {  #search end of file exit while
                $onecase_cnt=$onecase_cnt+$onetest_cnt;
                last;
            }
            elsif ($line =~ /Have\s+decoded\s+(\d+)\s+codewords\s*/) {  #search case pass fail error key words
                $onetest_cnt = $1;
            } 
            else {
                }
        }
        close(SUMMARY);
}
    print color"bold white";
    print "$cases[$loop_times] has decoded $onecase_cnt codewords in all ! \n";
# printf LOG "$cases[$loop_times] has decoded $onecase_cnt codewords in all ! \n";
    printf LOG "%s has decoded %dK codewords in all ! \n", $cases[$loop_times] ,$onecase_cnt/1000;
    
    print color 'reset';
    $onetest_cnt=0;
    $onecase_cnt=0; 
}

printf LOG "\n";
printf LOG "-------------------codeword calculation sum-result end---------- \n";

close (LOG);
print color"bold green";
print "DONE! The codeword count has been calculated  in the file regression_summary.log\n\n";
print color 'reset';





###########################analyze regression report use tools/perl/check_results.pl###################################
system("echo  >> regression_summary.log");
system("echo  >> regression_summary.log");
system("echo  --------------PASS/FAIL result of every case in every random test---------- >> regression_summary.log");#sign of one case begin
system("echo  >> regression_summary.log");
system("echo  >> regression_summary.log");
system("echo ------------------------flow control 2cases extreme condition , testbubblecnt_random --------------------->> regression_summary.log");#sign of one case begin
system("echo Extrem_condition case : >> regression_summary.log ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd Extrem_condition/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo Extrem_condition_bubblecnt_random case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd Extrem_condition_bubblecnt_random/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end


system("echo --------------------------------Error reporting 4 cases t15,l06b,m16,bics2-------------------------------->> regression_summary.log   ");#sign of one case begin
system("echo error_report_T15 case : >> regression_summary.log ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd error_report_T15/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo error_report_BiCS2 case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd error_report_BiCS2/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo error_report_L06B case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd error_report_L06B/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo error_report_M16 case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd error_report_M16/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end


system("echo ----------FPGA SKIM tests 4cases for error_report ,random error ,random bubble ,extreme flow control------>> regression_summary.log   ");#sign of one case begin
system("echo random_fpga_skim_Fixed_Error case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_fpga_skim_Fixed_Error/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_fpga_skim_Random_Error case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_fpga_skim_Random_Error/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_fpga_skim_Random_Bubble case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_fpga_skim_Random_Bubble/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_fpga_skim_ExtremeFlowcontrol case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_fpga_skim_ExtremeFlowcontrol/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end



system("echo -------------------Error injecting tests 12cases for mini,medium,high  x t15,l06b,m16,bics2--------------->> regression_summary.log   ");#sign of one case begin
system("echo random_T15_mini case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_T15_mini/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_T15_medium case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_T15_medium/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_T15_high case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_T15_high/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_M16_mini case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_M16_mini/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_M16_medium case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_M16_medium/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_M16_high case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_M16_high/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_L06B_mini case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_L06B_mini/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_L06B_medium case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_L06B_medium/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_L06B_high case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_L06B_high/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_BiCS2_mini case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_BiCS2_mini/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_BiCS2_medium case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_BiCS2_medium/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end
system("echo random_BiCS2_high case : >> regression_summary.log   ");# print case name 
for (my $i=0 ; $i<$random_number ; $i++) {system("cd random_BiCS2_high/test_$i/ && head -200 log | perl ../../../../tools/perl/check_results.pl >> ../../regression_summary.log   ");}
system("echo ---------------------------------- >> regression_summary.log   ");#sign of one case end



system("echo EOF >> regression_summary.log   ");#sign of EOF 

#------------parse summary report pass or fail & print on results on terminal-----------
        my $file = "./regression_summary.log";
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
            if($line =~ /(\w+)\scase\s*/) {
            $case_name =$1 ;
           #print"$case_name\n\n\n\n";
            }
            elsif ($line =~ /(\d+)\stest\sfailed:*/) {  #search case pass fail error key words
                $status = $1;
                push (@fail_cases, $case_name) if $status==1 ;
            } 
            elsif ($line =~ /(\d+)\stest\sis\sunknown:*/) {  #search case pass fail error key words
                $status = $1;
                push (@unknown_cases , $case_name) if $status==1;
            }
            elsif ($line =~ /(\d+)\stest\spassed:*/) {  #search case pass fail error key words
                $status = $1;
                push (@pass_cases , $case_name) if $status==1;
            }
            else {
                }
        }
        close(SUMMARY);
    print color"bold white";
    print "Parse the regression_summary.log file to check case pass or fail \n";
    print "-"x40 . "\n";
    print color 'reset';

my $fail_num=@fail_cases;
my $pass_num=@pass_cases;
my $unknow_num=@unknown_cases;

#print final cases regression_summary
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
    print "all $pass_num cases passed \n\n";
    print color 'reset';
}

__END__


#----------gen_excel_report----------
  print "[INFO]  -- Start to generate the excel report\n\n";
  my $excel_out = Spreadsheet::WriteExcel->new('ecc_regression_report.xls');
  my $worksheet = $excel_out->add_worksheet();
  my $format = $excel_out->add_format(); # Add a format 
  $format->set_align('center'); 
  my %col;

my $T15_mini = "test 0-30  errors correction process on 100k codewords for mode 2 (120,2038) ";
my $T15_medi = "test 31-55 errors correction process on 100k codewords for mode 2 (120,2038) ";
my $T15_high = "test 56-72 errors correction process on 100k codewords for mode 2 (120,2038) ";
my $bisc2_mini = "test 0-30  errors correction process on 100k codewords for mode 2 (120,2038) ";
my $bisc2_medi = "test 31-55 errors correction process on 100k codewords for mode 2 (120,2038) ";
my $bisc2_high = "test 56-120 errors correction process on 100k codewords for mode 2 (120,2038) ";
my $l06b_mini  = "test 0-30  errors correction process on 100k codewords for mode 2 (96,1538)  ";
my $l06b_medi  = "test 31-55 errors correction process on 100k codewords for mode 2 (96,1538)  ";
my $l06b_high  = "test 56-96 errors correction process on 100k codewords for mode 2 (96,1538)  ";
my $m16_mini   = "test 0-30  errors correction process on 100k codewords for mode 2 (72,1496)  ";
my $m16_medi   = "test 31-55 errors correction process on 100k codewords for mode 2 (72,1496)  ";
my $m16_high   = "test 56-72 errors correction process on 100k codewords for mode 2 (72,1496)  ";
my $fixed_error  = "inject a fixed number of errors and check if the corrected error count correspond to the injected error count, test on 200k codewords   ";#testFixed_Error_Report

my $head_format = $excel_out->add_format (    bold => 1,
                                              size => 12,
                                              color => 'blue',
                                              align => 'center',
                                         );
my $red_format = $excel_out->add_format ( color => 'red',
                                          align => 'center',
                                        );
my $gre_format = $excel_out->add_format ( color => 'green',
                                          align => 'center',
                                        );
$worksheet->add_write_handler(qr[\w], \&store_string_widths);

    ## write the header: case_id, description, note and teststatus

    $col{"test name"}     =  0; 
    $col{"test author"}   =  1; 
    $col{"objective"}     =  2; 
    $col{"result"}        =  3; 
    $col{"update"}        =  4; 
    $col{"tested by"}     =  5; 


    foreach my $key (keys %col) {
        my $col_num = $col{"$key"};
        $worksheet->write(0, $col_num, $key, $head_format);
    }
    my $row_num = 1;

    # fill the passed test patterns result into excel
    if (@pass_cases > 0) {
        foreach my $case (@pass_cases) {
            $worksheet->write($row_num, $col{"test name"}, $case);
            $worksheet->write($row_num, $col{"test author"}, "fanqi",$format);
            if($case lt "random") {#testFixed_Error_Report
            $worksheet->write($row_num, $col{"objective"}, $fixed_error,$format);}   
            elsif($case eq "random_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $T15_mini,$format);}
            elsif($case eq "random_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $T15_medi,$format);}
            elsif($case eq "random_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $T15_high,$format);}
            elsif($case eq "random_BiCS2_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $bisc2_mini,$format);}
            elsif($case eq "random_BiCS2_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $bisc2_medi,$format);}
            elsif($case eq "random_BiCS2_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $bisc2_high,$format);}
            elsif($case eq "random_L06B_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $l06b_mini,$format);}
            elsif($case eq "random_L06B_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $l06b_medi,$format);}
            elsif($case eq "random_L06B_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $l06b_high,$format);}
            elsif($case eq "random_M16_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $m16_mini,$format);}
            elsif($case eq "random_M16_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $m16_medi,$format);}
            elsif($case eq "random_M16_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $m16_high,$format);}           
            else {}
            $worksheet->write($row_num, $col{"result"}, "PASS(20".$year_month_day.")", $gre_format);
            $worksheet->write($row_num, $col{"update"}, "",$format);
            $worksheet->write($row_num, $col{"tested by"}, "fanqi",$format);
            $row_num++;
        }
    }

    # fill the failed test patterns result into excel
    if (@fail_cases > 0) {
        foreach my $case (@fail_cases) {
            $worksheet->write($row_num, $col{"test name"}, $case);
            $worksheet->write($row_num, $col{"test author"}, "fanqi",$format);
            if($case lt "random") {#testFixed_Error_Report
            $worksheet->write($row_num, $col{"objective"}, $fixed_error,$format);}
            elsif($case eq "random_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $T15_mini,$format);}
            elsif($case eq "random_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $T15_medi,$format);}
            elsif($case eq "random_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $T15_high,$format);}
            elsif($case eq "random_BiCS2_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $bisc2_mini,$format);}
            elsif($case eq "random_BiCS2_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $bisc2_medi,$format);}
            elsif($case eq "random_BiCS2_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $bisc2_high,$format);}
            elsif($case eq "random_L06B_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $l06b_mini,$format);}
            elsif($case eq "random_L06B_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $l06b_medi,$format);}
            elsif($case eq "random_L06B_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $l06b_high,$format);}
            elsif($case eq "random_M16_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $m16_mini,$format);}
            elsif($case eq "random_M16_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $m16_medi,$format);}
            elsif($case eq "random_M16_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $m16_high,$format);}           
            else {}
            $worksheet->write($row_num, $col{"result"}, "FAIL(20".$year_month_day.")", $red_format);
            $worksheet->write($row_num, $col{"update"}, "",$format);
            $worksheet->write($row_num, $col{"tested by"}, "fanqi",$format);
            $row_num++;
        }
    }



    # fill the unknown test patterns' status into excel 
    if (@unknown_cases > 0) {
        foreach my $case (@unknown_cases) {
            $worksheet->write($row_num, $col{"test name"}, $case);
            $worksheet->write($row_num, $col{"test author"}, "fanqi",$format);
            if($case lt "random") {#testFixed_Error_Report
            $worksheet->write($row_num, $col{"objective"}, $fixed_error,$format);}
            elsif($case eq "random_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $T15_mini,$format);}
            elsif($case eq "random_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $T15_medi,$format);}
            elsif($case eq "random_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $T15_high,$format);}
            elsif($case eq "random_BiCS2_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $bisc2_mini,$format);}
            elsif($case eq "random_BiCS2_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $bisc2_medi,$format);}
            elsif($case eq "random_BiCS2_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $bisc2_high,$format);}
            elsif($case eq "random_L06B_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $l06b_mini,$format);}
            elsif($case eq "random_L06B_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $l06b_medi,$format);}
            elsif($case eq "random_L06B_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $l06b_high,$format);}
            elsif($case eq "random_M16_testMini"){
            $worksheet->write($row_num, $col{"objective"}, $m16_mini,$format);}
            elsif($case eq "random_M16_testMedium"){
            $worksheet->write($row_num, $col{"objective"}, $m16_medi,$format);}
            elsif($case eq "random_M16_testHigh"){
            $worksheet->write($row_num, $col{"objective"}, $m16_high,$format);}           
            else {}
            $worksheet->write($row_num, $col{"result"}, "UNKNOWN(20".$year_month_day.")", $red_format);
            $worksheet->write($row_num, $col{"update"}, "",$format);
            $worksheet->write($row_num, $col{"tested by"}, "fanqi",$format);
            $row_num++;
        }
    }

    print "[INFO]  -- The excel report has been written into ecc_regression_report.xls\n\n";





autofit_columns($worksheet);
###############################################################################
#
# Functions used for Autofit.
#
###############################################################################

###############################################################################
#
# Adjust the column widths to fit the longest string in the column.
#
sub autofit_columns {

    my $worksheet = shift;
    my $col       = 0;

    for my $width (@{$worksheet->{__col_widths}}) {

        $worksheet->set_column($col, $col, $width) if $width;
        $col++;
    }
}



###############################################################################
#
# The following function is a callback that was added via add_write_handler()
# above. It modifies the write() function so that it stores the maximum
# unwrapped width of a string in a column.
#
sub store_string_widths {

    my $worksheet = shift;
    my $col       = $_[1];
    my $token     = $_[2];

    # Ignore some tokens that we aren't interested in.
    return if not defined $token;       # Ignore undefs.
    return if $token eq '';             # Ignore blank cells.
    return if ref $token eq 'ARRAY';    # Ignore array refs.
    return if $token =~ /^=/;           # Ignore formula

    # Ignore numbers
    return if $token =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;

    # Ignore various internal and external hyperlinks. In a real scenario
    # you may wish to track the length of the optional strings used with
    # urls.
    return if $token =~ m{^[fh]tt?ps?://};
    return if $token =~ m{^mailto:};
    return if $token =~ m{^(?:in|ex)ternal:};


    # We store the string width as data in the Worksheet object. We use
    # a double underscore key name to avoid conflicts with future names.
    #
    my $old_width    = $worksheet->{__col_widths}->[$col];
    my $string_width = string_width($token);

    if (not defined $old_width or $string_width > $old_width) {
        # You may wish to set a minimum column width as follows.
        #return undef if $string_width < 10;

        $worksheet->{__col_widths}->[$col] = $string_width;
    }


    # Return control to write();
    return undef;
}
###############################################################################
#
# Very simple conversion between string length and string width for Arial 10.
# See below for a more sophisticated method.
#
sub string_width {

    return 1.2 * length $_[0];
}








