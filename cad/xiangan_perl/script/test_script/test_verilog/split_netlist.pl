#/usr/bin/perl -w

use strict;

#read in ori. netlist
open(FIN, "<sol_top_g5_ffsa_l.v");
my $file = "";
while(<FIN>){
    $file .= $_;
}
close(FIN);

#split by "module ... endmodule"
my @mod = ();
@mod = ($file =~ m/(module.*?endmodule)/gs);

#print into file
foreach my $m (@mod){
    if($m =~ m/module\s+(\w+)\s+/){
	open(FOUT, ">$1.v");
	print FOUT "$m\n";
	close(FOUT);
    }
}

