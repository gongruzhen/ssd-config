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



for (my $i=260 ;$i <832 ; $i=$i+8) {

#
# printf LOG "      \n",$i,$i,$i;
printf LOG "	     %d to: %d do: [:i | read_reg :=dut lbiRead: i.\n",$i,$i+3;
printf LOG "	     Transcript nextPutAll: 'Address is \%1,default value is \%2.' % {i. read_reg};nl].\n";
}

close (LOG);
print "\n the rtl has been generated in the file $file_name \n\n";


