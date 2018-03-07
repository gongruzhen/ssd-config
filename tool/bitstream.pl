#!/usr/bin/perl -w

use strict;
use integer;

my $cwbytes = $ARGV[0];
my $infile = "DISECCDATA";

open my $fh, "<", $infile
	or die "Open file $infile fail: $!\n";

my @meta = ();
my ($nmeta, $expsi, $si) = (0, 0, 0);
my $bstream = "";
my @barray = ();

sub long2stream {
	my ($instr) = @_;
	my $bs = "";

	for (my $i = 7; $i >= 0; $i--) {
		$bs .= substr($instr, 2 * $i, 2);
		$bs .= " ";
	}

	$bs;
}

while (<$fh>) {
	s/^\s+//;
	s/\s+$//;

	next if (/^$/);
	next if (/^#ECC/);

	if (/^#meta/) {
		s/.*:\s+//;

		@meta = split;
		$nmeta = scalar(@meta);

		next;
	}

	if (my ($si) = /^#sector.*:\s+(\d+)/) {
		die "No sector $expsi\n" if ($expsi != $si);
		$expsi++;

		next if (!$si);

		$bstream .= &long2stream($meta[$si - 1]);
		# $bstream .= "\n";
		next;
	}
	$bstream .= "$_ ";
}
$bstream .= &long2stream($meta[-1]);
$bstream =~ s/^\s+|\s+$//g;
$bstream =~ s/\s+/ /g;
# print "$bstream\n";

@barray = split(/ /, $bstream);

my $cws = scalar(@barray) / $cwbytes;

for (my $cw = 0; $cw < $cws; $cw++) {
	my $fname = sprintf("codew-%02d", $cw);

	open my $cwfh, ">", $fname
		or die "Create file $fname fail: $!\n";

	for (my $i = $cw * $cwbytes; $i < ($cw + 1) * $cwbytes; $i+=2) {
		my $num_lo = hex($barray[$i]);
		my $num_hi = hex($barray[$i + 1]);

		my $bits_lo = "";
		my $bits_hi = "";

		for my $j (0..7) {
			$bits_lo .= ($num_lo & (1 << (7 - $j))) ? "1" : "0";
			$bits_hi .= ($num_hi & (1 << (7 - $j))) ? "1" : "0";
		}

		printf($cwfh "%s%s\n", $bits_hi, $bits_lo);
		# printf($cwfh "%02X %s %02X %s\n", $num_hi, $bits_hi, $num_lo, $bits_lo);
	}

	close($cwfh);
}

close($fh);
