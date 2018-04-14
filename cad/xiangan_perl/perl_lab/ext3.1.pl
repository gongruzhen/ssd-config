#!/usr/bin/perl -w

use strict;
use Data::Dumper;
# -------------------------------------------------------------
# The example used to show the example of hashes
#
# Author:
# --------------------
#    peter.shi <peter_soc_vrf@163.com>
# -------------------------------------------------------------

# ##################################
# the examples for hashes
use strict;
use Data::Dumper;
my %scores = ("xiaoming", 78, "xiaoli", 98, 
           "xiaotang", 89, "xiaosong", 90);
# keys  :"xiaoming", "xiaoli", "xiaotang", "xiaosong"
# values: 78       , 98      , 89        , 90
print Data::Dumper->Dump([\%scores],['scores']);

my %scores_2 = (
    "xiaoming" => 78,
    "xiaoli"   => 89,
    "xiaotang" => 89,
    "xiaosong" => 90,
    );
print Data::Dumper->Dump([\%scores_2],['scores_2']);


my @names = keys %scores;
print "obtained total names = @names \n";
my @_scores = values %scores;
print "obtained total scores = @_scores \n";
while (my ($name, $score)=each %scores) {
    print "The score for $name is $score \n";
}

my $person = "xiaoming";
if (exists $scores{$person}) {
    print "We have obtained the score for $person\n";
}

delete $scores{$person};
print Data::Dumper->Dump([\%scores],['scores']);
