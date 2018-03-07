#! /usr/bin/perl -w 

use strict;


my $delay_num=31;
my $zero="000";
my $pdiv="4";

my $fbdiv_start2 = ord("c");
#my $fbdiv_start = sprintf("%x", $b_cha);
my $fbdiv_limit2 = ord("f");
#my $fbdiv_limit = sprintf("%x", $f_cha);
my $channel_count=8;
my $channel_count_minus_1=7;
my $dly_channel_count=18;
my $lun_per_channel=16;
  open MyFile ,">quick_scan_frequency_ffsa_u2.txt";

#system('./set_padio_18ch0345182a.sh');

my $process1_enable=0;
if ($process1_enable) {
##precess 1
####################################
my $fbdiv_start = 6;
#my $fbdiv_start = sprintf("%x", $b_cha);
my $fbdiv_limit = 9;
#my $fbdiv_limit = sprintf("%x", $f_cha);
for (my $fbdiv=$fbdiv_start; $fbdiv<=$fbdiv_limit; $fbdiv++) {
    #my $pdll="$pdiv"0"$fbdiv";
#    my $fbdiv_cha = sprintf("%c", $fbdiv);
    my $pdll=$zero.$pdiv."0".$fbdiv."00";
    my $tdll=$zero.$pdiv."0".$fbdiv."01";
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

#open MyFile ,">n_dci_s_dqs_clk$pdll.csv";
    #print MyFile "$realfreq";
    print MyFile "dpclk frequence address $reg_addr_hex: $tdll";
    print MyFile "\n";

print MyFile "channel";
print "channel";
for (my $delay=0; $delay<=$delay_num; $delay++) {
    my $delay_hex = sprintf("%x",$delay*2);
    print "\td$delay-h$delay_hex";
    print MyFile "\td$delay-h$delay_hex";
}
for (my $delay=0; $delay<=$delay_num; $delay++) {
    my $delay_hex = sprintf("%x",$delay*2);
    print "\td$delay-h$delay_hex";
    print MyFile "\td$delay-h$delay_hex";
}

print "\n";
print MyFile "\n";
for (my $channel=17; $channel<$channel_count; $channel++) {
    print "ECC";
    print MyFile "ECC";
    for (my $delay=0; $delay<=$delay_num; $delay++) {
		for (my $dly_channel=0; $dly_channel<$dly_channel_count; $dly_channel++) {
			my $reg_addr = 136 + $dly_channel*2 + 1;
			my $reg_addr_hex = sprintf("%x", $reg_addr);
			my $value = $delay * 62 / $delay_num;
			my $value_hex = sprintf("%x", $value);
			#print $value_hex;
			system('./ztool','utils', 'poke-regs', $reg_addr_hex, $value_hex);
		}
	my $min_lun = $channel*$lun_per_channel;
	my $max_lun = $channel*$lun_per_channel + $lun_per_channel - 1;
	my $ecc_count;
        system('./ztool','utils', 'poke-regs', "f1", "0x00");
        system('./ztool','utils', 'poke-regs', "f1", "0x01");
        system('./ztool','utils', 'poke-regs', "f1", "0x00");
#open (my $fh, "-|", "./ztool ifmode 0 1 -fo -T phylun:$min_lun-$max_lun");
	open (my $fh, "-|", "./ztool ifmode 0 1 -fo -T phylun:0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126");
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
    for (my $delay=0; $delay<=$delay_num; $delay++) {
                for (my $dly_channel=0; $dly_channel<$dly_channel_count; $dly_channel++) {
                        my $reg_addr = 136 + $dly_channel*2 + 1;
                        my $reg_addr_hex = sprintf("%x", $reg_addr);
                        my $value = $delay * 62 / $delay_num;
                        my $value_hex = sprintf("%x", $value);
                        my $value_hex_second_delay="0000".$value_hex."3F";
                        #print $value_hex;
                        system('./ztool','utils', 'poke-regs', $reg_addr_hex, $value_hex_second_delay);
                }
        my $min_lun = $channel*$lun_per_channel;
        my $max_lun = $channel*$lun_per_channel + $lun_per_channel - 1;
        my $ecc_count;
        system('./ztool','utils', 'poke-regs', "f1", "0x00");
        system('./ztool','utils', 'poke-regs', "f1", "0x01");
        system('./ztool','utils', 'poke-regs', "f1", "0x00");
#open (my $fh, "-|", "./ztool ifmode 0 1 -fo -T phylun:$min_lun-$max_lun");
        open (my $fh, "-|", "./ztool ifmode 0 1 -fo -T phylun:0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126");
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
}

#precess 2
#####################################
#
#  open MyFile ,">quick_scan_frequency.txt";
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

#  open MyFile ,">n_dci_s_dqs_clk$pdll.csv";
    #print MyFile "$realfreq";
    print MyFile "dpclk frequence address $reg_addr_hex: $tdll";
    print MyFile "\n";

print MyFile "channel";
print "channel";
for (my $delay=0; $delay<=$delay_num; $delay++) {
    my $delay_hex = sprintf("%x",$delay*2);
    print "\td$delay-h$delay_hex";
    print MyFile "\td$delay-h$delay_hex";
}
for (my $delay=0; $delay<=$delay_num; $delay++) {
    my $delay_hex = sprintf("%x",$delay*2);
    print "\td$delay-h$delay_hex";
    print MyFile "\td$delay-h$delay_hex";
}

print "\n";
print MyFile "\n";
for (my $channel=$channel_count_minus_1; $channel<$channel_count; $channel++) {
#    print "$channel";
#    print MyFile "$channel";
    print "ECC sum";
    print MyFile "ECC sum";
    for (my $delay=0; $delay<=$delay_num; $delay++) {
		for (my $dly_channel=0; $dly_channel<$dly_channel_count; $dly_channel++) {
			my $reg_addr = 136 + $dly_channel*2 + 1;
			my $reg_addr_hex = sprintf("%x", $reg_addr);
			my $value = $delay * 62 / $delay_num;
			my $value_hex = sprintf("%x", $value);
			#print $value_hex;
			system('./ztool','utils', 'poke-regs', $reg_addr_hex, $value_hex);
		}
	my $min_lun = $channel*$lun_per_channel;
	my $max_lun = $channel*$lun_per_channel + $lun_per_channel - 1;
	my $ecc_count;
        system('./ztool','utils', 'poke-regs', "f1", "0x00");
        system('./ztool','utils', 'poke-regs', "f1", "0x01");
        system('./ztool','utils', 'poke-regs', "f1", "0x00");
#open (my $fh, "-|", "./ztool ifmode 0 1 -fo -T phylun:$min_lun-$max_lun");
	open (my $fh, "-|", "./ztool ifmode 0 1 -fo -T phylun:0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126");
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
    for (my $delay=0; $delay<=$delay_num; $delay++) {
                for (my $dly_channel=0; $dly_channel<$dly_channel_count; $dly_channel++) {
                        my $reg_addr = 136 + $dly_channel*2 + 1;
                        my $reg_addr_hex = sprintf("%x", $reg_addr);
                        my $value = $delay * 62 / $delay_num;
                        my $value_hex = sprintf("%x", $value);
                        my $value_hex_second_delay="0000".$value_hex."3F";
                        #print $value_hex;
                        system('./ztool','utils', 'poke-regs', $reg_addr_hex, $value_hex_second_delay);
                }
        my $min_lun = $channel*$lun_per_channel;
        my $max_lun = $channel*$lun_per_channel + $lun_per_channel - 1;
        my $ecc_count;
        system('./ztool','utils', 'poke-regs', "f1", "0x00");
        system('./ztool','utils', 'poke-regs', "f1", "0x01");
        system('./ztool','utils', 'poke-regs', "f1", "0x00");
#open (my $fh, "-|", "./ztool ifmode 0 1 -fo -T phylun:$min_lun-$max_lun");
        open (my $fh, "-|", "./ztool ifmode 0 1 -fo -T phylun:0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126");
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
