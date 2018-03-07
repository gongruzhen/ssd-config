#! /usr/bin/perl -w 

use strict;

my $channel_count=8;
my $lun_per_channel=16;

my $zero="000";
my $pdiv="4";

my $fbdiv_start2 = ord("a");
my $fbdiv_limit2 = ord("e");


my $delay_start=10;
open MyFile ,">scan_all_channel_delay_frequency.txt";
for (my $fbdiv=$fbdiv_start2; $fbdiv<=$fbdiv_limit2; $fbdiv++) {
        #my $pdll="$pdiv"0"$fbdiv";
        my $fbdiv_cha = sprintf("%c", $fbdiv);
	my $pdll=$zero.$pdiv."0".$fbdiv_cha."00";
	my $tdll=$zero.$pdiv."0".$fbdiv_cha."01";
		#my $realfreq=($fbdiv+1)/($pdiv+1)*100;
		my $reg_addr = 243;
		my $reg_addr_hex = sprintf("%x", $reg_addr);
		system('./ztool','utils', 'poke-regs', $reg_addr_hex, $pdll);
		system('./ztool','utils', 'poke-regs', $reg_addr_hex, $tdll);
		system('./ztool','utils', 'poke-regs', $reg_addr_hex, $pdll);

		#print "$fbdiv";
		#print "\n";
		print "dpclk frequence at address $reg_addr_hex: $tdll";
		print "\n";
		#print "$realfreq";
		#print "\n";
		#open MyFile ,">n_dci_s_dqs_clk.txt";
		#open MyFile ,">n_dci_s_dqs_clk$pdll.csv";
		#print MyFile "$realfreq";
		print MyFile "dpclk frequence address $reg_addr_hex: $tdll";
		print MyFile "\n";


print MyFile "ch\\de";
print "ch\\de";
for (my $delay=$delay_start; $delay<32; $delay++) {
    my $delay_hex = sprintf("%x",$delay*2);
    print "\td$delay-h$delay_hex";
    print MyFile "\td$delay-h$delay_hex";
}
print "\n";
print MyFile "\n";
for (my $channel=0; $channel<$channel_count; $channel++) {
    print "c$channel";
    print MyFile "c$channel";
    for (my $delay=$delay_start; $delay<32; $delay++) {
	my $reg_addr = 136 + $channel*2 + 1;
	my $value = $delay * 2;
	my $reg_addr_hex = sprintf("%x", $reg_addr);
	my $value_hex = sprintf("%x", $value);
	my $min_lun = $channel*$lun_per_channel;
	my $max_lun = $channel*$lun_per_channel + $lun_per_channel - 1;
	my $ecc_count;
	system('./ztool','utils', 'poke-regs', $reg_addr_hex, $value_hex);
	open (my $fh, "-|", "./ztool ifmode 0 1 -fo -T phylun:$min_lun-$max_lun");
	while (<$fh>) {
	    /Sum of ECC bit is: (\d+)/ and do {
		$ecc_count = $1;
		print "\t$ecc_count";
                print MyFile "\t$ecc_count";
	    };
    }
	close ($fh);
	# last if (($ecc_count > 65535) && ($delay > 15));
    }
    print MyFile  "\n";
    print "\n";
}
}
