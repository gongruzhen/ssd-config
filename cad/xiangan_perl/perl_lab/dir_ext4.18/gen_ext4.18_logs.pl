#!/usr/bin/perl -w
use strict;
use POSIX;
use Getopt::Long;
# --------------------------------------------
# Filename   : gen_ext4.18_logs.pl                     
#   
# Description:                                
#      The file used to genenrate the log files
#      for example ext4.18.pl 
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# gen_ext4.18_logs.pl 
my $file_num = 10; # how many log files will be generated 
my $help = 0;
my $debug = 0;
my @companys = qw(vimicro verisilicon amd marvell amlogic mtk qualcomm spreadtrum CSR Parade);
my @names    = qw(peter david tony allen kurt sam mark brance steven);
my @departs  = qw(analog digital SoCI SoCII SoCIII video Audio Bluetooth WIFI PR GPU CPU PCIE);
my $name_num = @names + 0;
my $company_num = @companys + 0;
my $depart_num  = @departs + 0;

my $tab = " "x4;
GetOptions(
    'file_num=s' => \$file_num,
    'help!'      => \$help,
    'debug!'     => \$debug,
    );

&help_message() if $help;

if (defined $file_num && $file_num > 0) {
    if (! -e "./log") {
        system("mkdir log");
    }
    # use the for loop to generate the specified number of log files
    for (my $i = 0; $i < $file_num; $i++) {
        my $cur_file = "./log/info_${i}.log";
        my $str = "";
        open (LOG, ">", $cur_file) or die "Can not open $cur_file file for writing!\n";
        my $name_index = int(rand($name_num));
        my $company_index = int(rand($company_num));
        my $depart_index  = int(rand($depart_num));
        my $num = int(rand(86400));
        my $date = getTime(time() - 86400*$i - $num); 
        my $month = $date->{month};
        my $day = $date->{day};
        my $year = $date->{year};
        # my $date = $date->{date};
        my $time = "${month}/${day}/${year}";
        $str .= "program name: program_${i}\n";
        $str .= "Author      : $names[$name_index]\n";
        $str .= "Company     : $companys[$company_index]\n";
        $str .= "Department  : $departs[$depart_index]\n";
        $str .= "Phone       : +86 21 8888 486${i}\n";
        $str .= "Date        : $time \n";
        $str .= "Version     : ${i}.1 \n";
        $str .= "Size        : ${i}k \n";
        $str .= "Status      : Final beta_${i} \n";
        print LOG $str;
        print "[INFO] -- the $cur_file has been generated \n\n" if $debug;
        close (LOG);
    }
    print "\n-- All the requested log files have been generated and saved into ./log dir! -- \n\n";
}

sub getTime
{
    my $time = shift || time();
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);

    $year += 1900;
    $mon ++;

    $min  = '0'.$min  if length($min)  < 2;
    $sec  = '0'.$sec  if length($sec)  < 2;
    $mon  = '0'.$mon  if length($mon)  < 2;
    $mday = '0'.$mday if length($mday) < 2;
    $hour = '0'.$hour if length($hour) < 2;
    
    my $weekday = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat')[$wday];

    return { 'second' => $sec,
             'minute' => $min,
             'hour'   => $hour,
             'day'    => $mday,
             'month'  => $mon,
             'year'   => $year,
             'weekNo' => $wday,
             'wday'   => $weekday,
             'yday'   => $yday,
             'date'   => "$year-$mon-$mday"
          };
}

sub help_message {
    print "\n$0 used to generate the log files for a example to deal with\n\n";
    print "Usage: perl $0 -file_num file_num [-debug]\n";
    print "   or  perl $0 -help/-h\n\n";
    exit;
}
