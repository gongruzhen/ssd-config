#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext4.18.pl                     
#   
# Description:                                
#     
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext4.18.pl 
my $log_dir;
my @log_files;
if (@ARGV > 0) {
    $log_dir = $ARGV[0];
}
else {
    &help_message();
}
$log_dir =~ s#\|/$##;           # remove "/" or "\" in the last position
@log_files = glob"$log_dir/*.log";
print "[INFO] -- obtain the log files done!\n\n";
print "log_files = @log_files \n\n";
if (defined $log_files[0] && $log_files[0] !~ /^\s*$/) {
    print "[INFO] -- Start to process the obtained log files \n\n";
    foreach my $file (@log_files) {
        # -------------------------------------------------
        # the following is the example code in the book
        # but can not obtain the expected result in the 
        # windows environment. Not clear for the reason.
        # And so use another way to reasize the function
        # -------------------------------------------------
        # chomp(my $date = `date`);
        # $^I = ".bak";
        # while (<$file>) {
        #     s/^Author:.*/Author: Randal L. Schwartz/;
        #     s/^Phone:.*\n//;
        #     s/^Date:.*/Date: $date/;
        #     print;
        # }

        # -------------------------------------------------
        # the following is another common way to reasize 
        # the function
        # -------------------------------------------------
        system("cp $file ${file}.bak");
        my $tmp_file = "${file}.tmp";
        my $str = "";
        chomp(my $date = `date`);
        open (IN_LINE, "<", $file) or die "Can not open $file for reading!\n";
        while (<IN_LINE>) {
            s/^Author\s*:.*/Author      : Randal L. Schwartz/;
            s/^Phone\s*:.*//;
            s/^Date\s*:.*/Date        : $date/;
            $str .= $_ if ($_ !~ /^\s*$/);
        }
        close(IN_LINE);
        open (LOG, ">", $tmp_file) or die "Can not open $tmp_file for writing!\n";
        print LOG $str;
        close (LOG);
        system("mv $tmp_file $file");
    }
    print "[INFO] -- Complete to process the obtained log files \n\n";
}

sub help_message() {
    print "Usage: perl $0 log_dir\n\n";
    exit;
}
