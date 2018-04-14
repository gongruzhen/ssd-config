  #!/usr/bin/perl -w                                                                                                                                                                                                                       
 use warnings;
 use strict;
 use POSIX;
 use Encode;
 #use Spreadsheet::ParseExcel;
 #use Spreadsheet::WriteExcel;
 use Term::ANSIColor;
 my $tab = " "x4;
 sub ColorMessage{
 my($colors,$messages)=@_;
 print color"bold $colors";
 print "$messages\n";
 print color 'reset';
 }
 #ColorMessage('green','hello'); #test for color print//////
 # pre-compile ncsim lib ;just +simulation & +testcase_name
  
  
 my $log = "./testflash_vpp_on.log";
  
 system("echo start vpp_on_flash_test > $log");
  
 



system "./ztool --cps=cps/manual/Toshiba/ffsa/Toshiba_Bics2_ECC72_vpp_on readid 0 ";


for(my $loop=1 ; $loop<4; $loop++){
system"echo for the $loop times  >> $log";
system "./ztool --cps=cps/manual/Toshiba/ffsa/Toshiba_Bics2_ECC72_vpp_on super-erase 0 100 -T loglun:21,22,24,41,46,49,61 ";
system "./ztool --cps=cps/manual/Toshiba/ffsa/Toshiba_Bics2_ECC72_vpp_on super-write 0 100 -T loglun:21,22,24,41,46,49,61 ";
system "./ztool --cps=cps/manual/Toshiba/ffsa/Toshiba_Bics2_ECC72_vpp_on super-read  0 100 -T loglun:21,22,24,41,46,49,61 >> $log";
system"echo end for the $loop times  >> $log";


system("echo  >> $log");
system("echo  >> $log");
system("echo  >> $log");
}
