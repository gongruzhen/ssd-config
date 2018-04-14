#!/usr/bin/perl -w

use strict;
use Data::Dumper;
# -------------------------------------------------------------
# This is a simple complete example for hash application
#
# Author:
# --------------------
#    peter.shi <peter_soc_vrf@163.com>
# -------------------------------------------------------------
# ext3.2.pl
my $tab = "    ";
my %scores = (
    "xiaoming" => 78,
    "xiaoli"   => 89,
    "xiaotang" => 89,
    "xiaosong" => 90,
    "xiaowang" => 96,
    "xiaoshi"  => 84,
    );
print "\nThe original socre hash table content:\n";
print "-"x40 . "\n";
print Data::Dumper->Dump([\%scores],['scores']);

my $summary = "";
$summary .= "\nThe following is the score summary information:\n";
$summary .= "-"x50 . "\n";
my $sum = 0;
while (my ($name, $score) = each %scores) {
    $summary .= "${tab}${tab} $name ${tab} -- $score \n";
    $sum += $score;    
}
$summary .= "\n\n";
my @names = keys %scores;
my @scores = values %scores;
print "\nThe obtained name list = @names \n";
print "The obtained score list = @scores \n";
my $num = @names;
my $average = $sum / $num;

print "\nThe average score is $average \n\n";
print $summary;

my $person = "xiaoming";
if (exists $scores{$person}) {
    print "We have obtained the score for $person\n";
}

delete $scores{$person};
print "\nThe following is the scores hash content after delete $person information from the hash:\n";
print "-"x50 . "\n";
print Data::Dumper->Dump([\%scores],['scores']);
print "\n";

$person = "xiaoli";
delete $scores{$person};
print "\nThe following is the scores hash content after delete $person information from the hash:\n";
print "-"x50 . "\n";
print Data::Dumper->Dump([\%scores],['scores']);
print "\n";
