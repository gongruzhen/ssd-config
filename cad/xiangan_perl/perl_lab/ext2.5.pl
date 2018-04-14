#!/usr/bin/perl -w

use strict;

# -------------------------------------------------------------
# The example used to descrip the use of operators for
# list and arrays in Perl
#
# Author:
# --------------------
#    peter.shi <peter_soc_vrf@163.com>
# -------------------------------------------------------------

# ---------------------------------
# examples for pop operator
print "\nExample for pop operator:\n";
print "-"x40 . "\n";
my @arrs_1 = (1, 3, 5, 9, 10, 4);
print "original arrays = @arrs_1 \n";
my $val = pop(@arrs_1);
print "after one pop operation: arrs_1 = @arrs_1 and obtained value = $val \n";
pop(@arrs_1);
print "after two pop oprations and arrs_1 = @arrs_1 \n";

# ---------------------------------
# example for push operation
print "\n\nExample for push operation:\n";
print "-"x40 . "\n";
push (@arrs_1, 100);
print "after one push 100 opration and arrs_1 = @arrs_1 \n";
my @tests = qw(101 104 109);
push (@arrs_1, @tests);
print "after two push array operations, tests = @tests and arrs_1 = @arrs_1\n";


# ---------------------------------
# example for shift and unshift
my @arrs = (1, 2);
print "\n\nExample for shift and unshift:\n";
print "-"x40 . "\n";
print "original arrs = @arrs \n";
$val = shift(@arrs);
print "after one shift operation, arrs = @arrs and obtained value = $val \n";
$val = shift(@arrs);
print "after two shift operations, arrs = @arrs and obtained value = $val \n";
$val = shift(@arrs);
print "after three shift operations: ";
if (defined $arrs[0]) {
    print "arrs = @arrs ";
}
else {
    print "arrs = undef ";
}
if (defined $val) {
    print "and obtained value = $val \n";
}
else {
    print "and obtained value = undef\n";
}

unshift(@arrs, 7);
print "after one unshift operation and arrs = @arrs \n";
@tests = 10 .. 20;
unshift(@arrs, @tests);
print "after two unshift operations: tests = @tests and arrs = @arrs \n";

# ---------------------------------
# example for foreach
print "\n\nThe example for foreach operator:\n";
print "-"x40 . "\n";
$val = 1000;
print "before foreach: val = $val \n";
print "test foreach operator: arrs = ";
my $num = 0;
foreach my $val (@arrs) {
    print " " if ($num > 0);
    print "$val";
    $num++;
}
print "\n";
print "after foreach: val = $val \n";


# ---------------------------------
# example for reverse
print "Example for reverse operator:\n";
print "-"x40 . "\n";
@arrs = reverse @arrs;
print "after reverse and arrs = @arrs \n";

# ---------------------------------
# example for sort
print "\n\nExample for sort operator:\n";
print "-"x40 . "\n";
@arrs = sort @arrs;
print "after the default sort operation and arrs = @arrs \n";
@arrs = sort {$a <=> $b} @arrs;
print "after the sort operation use \"<=>\" and arrs = @arrs \n";
