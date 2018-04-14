#!/usr/bin/perl -w

use strict;
# -------------------------------------------------------------
# The example used to show the example of subroutines
#
# Author:
# --------------------
#    peter.shi <peter_soc_vrf@163.com>
# -------------------------------------------------------------
my $val1 = 10;
my $val2 = 19;
my $max = &get_max_val($val1, $val2);
print "\nval1 = $val1, val2 = $val2 and max value = $max \n\n";
$max = &get_max_val(my $m, my $n);
sub get_max_val {
    my ($val1, $val2) = @_;
    if (!defined $val1 || !defined $val2) {
        print "the given data is uninitialized. Exiting...\n";
        exit;
    }
    return $val1 if ($val1 >= $val2);
    return $val2 if ($val2 > $val1);
}


