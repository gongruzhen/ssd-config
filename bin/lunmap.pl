#!/usr/bin/perl -w

# this script is used to check the luns that you config but absent or bad.
# NOTE: will not check the absent or bad luns that you are not config
# david 2013.08.06

use integer;

our ($lun_amount, $nchannel, $nthread, $nlun, $hw_nchannel, $hw_nthread, $hw_nlun);
our (@phylun_mask, @absent_luns, @present_luns);
our (@absent_phyluns, @present_phyluns, @absent_sort_phyluns, @present_sort_phyluns);

sub log2phy_lun{
	my $loglun = $_[0];

	# my $ln = ($loglun % ($nchannel * $nlun)) / $nchannel;
	# my $tr = $loglun / ($nchannel * $nlun);
	my $ln = $loglun / ($nchannel * $nthread);
	my $tr = ($loglun % ($nchannel * $nthread)) / $nchannel;
	my $ch = $loglun % $nchannel;

	($ch * $hw_nthread + $tr) * $hw_nlun + $ln;
}

if (-e "/dev/dfa") {
	open $mbr, "< /debug/dfa/mbr" or
		die "open /debug/dfa/mbr fail: $!\n";

	while(<$mbr>) {
		chomp;

		if(/^lun_amount/) { $lun_amount = (split /=/)[1]; next; }

		if(/^config_channels/) { $nchannel = (split /=/)[1]; next; }
		if (/^config_lunset_in_channel/) { $nthread = (split /=/)[1]; next; }
		if (/^config_lun_in_lunset/) { $nlun = (split /=/)[1]; next; }

		if (/^\*hw_max_channels/) { $hw_nchannel = (split /=/)[1]; next; }
		if (/^\*hw_max_lunsets_in_channel/) { $hw_nthread = (split /=/)[1]; next; }
		if (/^\*hw_max_luns_in_lunset/) { $hw_nlun = (split /=/)[1]; next;  }

		if (/^bad_phy_lun_map/) {
			foreach (split /_/, (split /=/)[1]) {
				push @phylun_mask, hex(substr($_, 8, 8));
				push @phylun_mask, hex(substr($_, 0, 8));
			}
		}
	}
} elsif (-e "/dev/shannon_cdev") {
	@config = `./ztool mpt -M`;
	die "./ztool mpt -M fail $!, maybe the card hasn't been formated\n" if (0 != $?);
	chomp(@config);
	foreach (@config) {
		last if (/^###/);

		if(/^lun_amount/) { $lun_amount = (split /=/)[1]; next; }

		if (/^cfg_nchannel/) { $nchannel = (split /=/)[1]; next; }
		if (/^cfg_nthread/) { $nthread = (split /=/)[1]; next; }
		if (/^cfg_nlun/) { $nlun = (split /=/)[1]; next; }

		if (/^bad_phy_lun_map/) {
			foreach (split /_/, (split /=/)[1]) {
				push @phylun_mask, hex(substr($_, 8, 8));
				push @phylun_mask, hex(substr($_, 0, 8));
			}
		}
	}

	@hwinfo = `./ztool hwinfo`;
	die "./ztool hwinfo fail $!\n" if (0 != $?);
	chomp(@hwinfo);
	foreach (@hwinfo) {
		if (/HW_nchannel/) { s/\D//g; $hw_nchannel=$_; next; }
		if (/HW_nthread/) { s/\D//g; $hw_nthread=$_; next; }
		if (/HW_nlun/) { s/\D//g; $hw_nlun=$_; next; }
	}

} else {
	print "Please install shannon or shannon_cdev first\n";
	exit 1;
}

# print "@phylun_mask\n";
printf("cfg=(%d %d %d)\n", $nchannel, $nthread, $nlun);
printf("hw=(%d %d %d)\n\n", $hw_nchannel, $hw_nthread, $hw_nlun);

for (my $lun = 0; $lun < $lun_amount; $lun++) {
	my $phylun = &log2phy_lun($lun);
	# printf("%d: %d\n", $lun, $phylun);
	if ($phylun_mask[$phylun/32] & (1 << ($phylun%32))) {
		push @absent_luns, $lun;
		push @absent_phyluns, $phylun;
	} else {
		push @present_luns, $lun;
		push @present_phyluns, $phylun;
	}

}

@absent_sort_phyluns = sort {$a <=> $b} @absent_phyluns;
@present_sort_phyluns = sort {$a <=> $b} @present_phyluns;

printf("absent_lun_amount=%d\n", scalar(@absent_luns));
print "absent_luns=(@absent_luns)\n";
print "absent_phyluns=(@absent_phyluns)\n";
print "absent_sort_phyluns=(@absent_sort_phyluns)\n";
print "\n";

printf("present_lun_amount=%d\n", scalar(@present_luns));
print "present_luns=(@present_luns)\n";
print "present_phyluns=(@present_phyluns)\n";
print "present_sort_phyluns=(@present_sort_phyluns)\n";
print "\n";
