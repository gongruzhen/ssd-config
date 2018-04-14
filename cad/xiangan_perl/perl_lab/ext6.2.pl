#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext6.2.pl                     
#   
# Description:                                
#     the example used to show how to obtain
#     the time information 
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext6.2.pl 
# my $localtime = localtime();
# my $gtime = gmtime();
# my $time = time();
# print "localtime = $localtime\n\n";
# print "gtime = $gtime\n\n";
# print "time = $time \n\n";
my $local_time = localtime();  # the output is current time, the same as "date" command
my $time       = time()     ;  # the second number from 1970 until now
my $gm_time    = gmtime()   ;  # the standard gelinweizhi time
print "local_time = $local_time \n";
print "time       = $time       \n";
print "gm_time    = $gm_time    \n";

my($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime();
#my($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=gmtime();  
# the above return value that same as "localtime"
print "\nsec  = $sec\n";
print "min  = $min \n";
print "hour = $hour \n";
print "day  = $day \n";
print "mon  = $mon \n";
print "year = $year \n";
print "wday = $wday \n";
print "yday = $yday \n";
print "isdst= $isdst \n";

# obtain 9 output result whose order is fixed:
#     $sec,$min,$hour,$day
#     $mon  -- 0~11
#     $year -- the years number from 1900, for example the value 
#              is 111 if current year is 2011 (2011 - 1900 = 111)
#     $wday -- a day within a week, 0=Sun, 1=Mon, ..., 6=Sat
#     $yday -- the time within a year, 0~364 or 0~365
#     $isdst-- the value is zero
#     
# we can obtain the formatted value by sprintf
$year += 1900;
$mon  += 1;
my $btime = sprintf("%d/%02d/%02d/%02d:%02d:%02d",$year,$mon,$day,$hour,$min,$sec);
print "\n\nyear = $year \n";
print "mon = $mon \n";
print "btime = $btime \n\n";
