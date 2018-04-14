#!/usr/bin/perl -w

use strict;

# -------------------------------------------------------------
# The example used to show the example Scalar and List Context
#
# Author:
# --------------------
#    peter.shi <peter_soc_vrf@163.com>
# -------------------------------------------------------------

my @arrays = qw(example for scalar and list context);
print "\narrays = @arrays \n\n";    # list context
my @sorted = sort @arrays;      # list context
print "after sorted and arrays = @sorted\n\n"; # list context
print "after sorted and scalar arrasys = " . scalar @sorted . "\n\n"; # scalar context
my $num = @arrays;                             # scalar context
print "num = $num \n\n";

my @reversed = reverse @arrays; # list context
print "reversed arrays = @reversed \n\n"; # list context
my $reverse_str = reverse @arrays;        # scalar context
print "reversed string = $reverse_str \n\n";
