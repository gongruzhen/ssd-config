#!/usr/bin/perl -w
#use strict 
my $file_name;
my $tab = " "x4;
if (@ARGV == 1) {
    $file_name = $ARGV[0];
}    
else {
     print " usage : perl gen_rtl_perl.pl a.v"
}
open (LOG, ">",$file_name) or die "can't not open $file_name for write!\n";



for (my $i=4 ;$i <18 ; $i=$i+1) {

# printf LOG "      .C%d_CE0_              ( nand_if.CEB[%d][0]    ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_CE1_              ( nand_if.CEB[%d][1]    ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_CLE               ( nand_if.CLE[%d]       ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_ALE               ( nand_if.ALE[%d]       ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_RE_               ( nand_if.REB[%d]       ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_WE_               ( nand_if.WEB[%d]       ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQS0              ( nand_if.DQS[%d][0]    ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQS1              ( nand_if.DQS[%d][1]    ) ,\n",$i,$i,$i;
# printf LOG "      \n",$i,$i,$i;
# printf LOG "      .C%d_DQ0               ( nand_if.IO[%d][0]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ1               ( nand_if.IO[%d][1]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ2               ( nand_if.IO[%d][2]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ3               ( nand_if.IO[%d][3]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ4               ( nand_if.IO[%d][4]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ5               ( nand_if.IO[%d][5]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ6               ( nand_if.IO[%d][6]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ7               ( nand_if.IO[%d][7]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ8               ( nand_if.IO[%d][8]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ9               ( nand_if.IO[%d][9]     ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ10              ( nand_if.IO[%d][10]    ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ11              ( nand_if.IO[%d][11]    ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ12              ( nand_if.IO[%d][12]    ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ13              ( nand_if.IO[%d][13]    ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ14              ( nand_if.IO[%d][14]    ) ,\n",$i,$i,$i;
# printf LOG "      .C%d_DQ15              ( nand_if.IO[%d][15]    ) ,\n",$i,$i,$i;
#
# printf LOG "      \n",$i,$i,$i;
  printf LOG "`MODULE #(0) `INST%d (\n",$i,$i,$i;
  printf LOG "	  .DQ0x          ( nand_if.IO[%d][7:0]  ) ,      \n",$i,$i,$i;
  printf LOG "	  .DQ1x          ( nand_if.IO[%d][15:8] ) ,      \n",$i,$i,$i;
  printf LOG "	  .CE0nx         ( nand_if.CEB[%d][0]   ) ,      \n",$i,$i,$i;
  printf LOG "	  .CE1nx         ( nand_if.CEB[%d][0]   ) ,      \n",$i,$i,$i;
  printf LOG "	  .CE2nx         ( nand_if.CEB[%d][1]   ) ,      \n",$i,$i,$i;
  printf LOG "	  .CE3nx         ( nand_if.CEB[%d][1]   ) ,      \n",$i,$i,$i;
  printf LOG "	  .WE0nx         ( nand_if.WEB[%d]      ) ,      \n",$i,$i,$i;
  printf LOG "	  .WE1nx         ( nand_if.WEB[%d]      ) ,      \n",$i,$i,$i;
  printf LOG "	  .RE0nx         ( nand_if.REB[%d]      ) ,      \n",$i,$i,$i;
  printf LOG "	  .RE1nx         ( nand_if.REB[%d]      ) ,      \n",$i,$i,$i;
  printf LOG "	  .RE0x          (                      ) ,      \n",$i,$i,$i;
  printf LOG "	  .RE1x          (                      ) ,      \n",$i,$i,$i;
  printf LOG "	  .CLE0x         ( nand_if.CLE[%d]      ) ,      \n",$i,$i,$i;
  printf LOG "	  .CLE1x         ( nand_if.CLE[%d]      ) ,      \n",$i,$i,$i;
  printf LOG "	  .ALE0x         ( nand_if.ALE[%d]      ) ,      \n",$i,$i,$i;
  printf LOG "	  .ALE1x         ( nand_if.ALE[%d]      ) ,      \n",$i,$i,$i;
  printf LOG "	  .WP0nx         ( 1'b1                 ) ,      \n",$i,$i,$i;
  printf LOG "	  .WP1nx         ( 1'b1                 ) ,      \n",$i,$i,$i;
  printf LOG "	  .RB0x          (                      ) ,      \n",$i,$i,$i;
  printf LOG "	  .RB1x          (                      ) ,      \n",$i,$i,$i;
  printf LOG "	  .RB2x          (                      ) ,      \n",$i,$i,$i;
  printf LOG "	  .RB3x          (                      ) ,      \n",$i,$i,$i;
  printf LOG "	  .DQS0x         ( nand_if.DQS[%d][0]   ) ,      \n",$i,$i,$i;
  printf LOG "	  .DQS1x         ( nand_if.DQS[%d][1]   ) ,      \n",$i,$i,$i;
  printf LOG "	  .DQS0nx        (                      ) ,      \n",$i,$i,$i;
  printf LOG "	  .DQS1nx        (                      ) ,      \n",$i,$i,$i;
  printf LOG "	  .VREF0x_pseudo ( 1'b1                 ) ,      \n",$i,$i,$i;
  printf LOG "	  .VREF1x_pseudo ( 1'b1                 )        \n",$i,$i,$i;
  printf LOG "\n",$i,$i,$i;
  printf LOG "   );\n",$i,$i,$i;
  printf LOG "\n",$i,$i,$i;
  
}

close (LOG);
print "\n the rtl has been generated in the file $file_name \n\n";


