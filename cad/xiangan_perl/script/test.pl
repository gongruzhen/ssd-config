#!/usr/bin/perl -w
# --------------------------------------------
# Filename   : test                     
#   
# Description:                                
#     The example used to show how to use 
#     directory handle in Perl
#                                             
# Author:                                     
#    xiangan       
# --------------------------------------------
# ext6.3.pl 
use strict;
use File::Find;
use POSIX;
use Encode;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use Term::ANSIColor;

my $tab = " "x4;
my $info  = "[INFO]  --";
my $error = "[ERROR] --";

my $dir_find = "./find_2";
my $dev;
my $ino; 
my $mode; 
my $nlink; 
my $uid; 
my $gid ;



my @directories= ("./find_2" );

sub wanted {
#           /^\.nfs.*\z/s &&
#           (($dev, $ino, $mode, $nlink, $uid, $gid) = lstat($_)) &&
#           int(-M _) > 7 &&
#           unlink($_)
#           ||
#           ($nlink || (($dev, $ino, $mode, $nlink, $uid, $gid) = lstat($_))) &&
#           $dev < 0 &&
#           ($File::Find::prune = 1);

print "$_ \n";
print "$File::Find::dir \n" ;
print "$File::Find::name \n";
 }





#find(\&wanted,  $dir_find);
#print "\n\n\n\n\n";

#finddepth(\&wanted,  @directories);

 my @testcase = `ls`;
 my $testcase = @testcase;
#print  "@testcase \n";
#print  "$testcase \n";


my $log_dir = "./"; #log dir
opendir DIR, $log_dir or die "Cannot open $log_dir: $!";
foreach my $file (readdir DIR) {
    if ($file =~ m/.*\.log$/) {
#       print "$file \n";
        if(`grep -P "fail|error" -i $file`){
             print "$file FAIL\n";
          }
          else {
          print "$file OK\n";
          }
    
    }
    else {
    }
}
closedir DIR;




__END__

