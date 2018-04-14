#!/usr/bin/perl -w
use strict;
# -------------------------------------------------------
# the example used to show the usage of Option Modifiers
# to do the expressions matching
# Author: peter.shi <peter_soc_vrf@163.com>
# -------------------------------------------------------

print "\nWould you like to play a game?\n\n";
chomp($_ = <STDIN>);
if (/yes/i) { # use "/i" to do case-insensitive match
    print "In that case, I recommend that you go bowling.\n\n";
}

$_ = "I saw Tom\ndown at the bowling alley\nwith Fred\nlast night.\n";
if (/Tom.*Fred/s) {
    print "Matched successfully when use \"\\s\" option\n\n";
}

if (/tom.*fred/si) {
    print "That string mentions Fred after Barney!\n\n";
}
