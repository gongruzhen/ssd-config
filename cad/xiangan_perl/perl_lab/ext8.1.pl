#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext7.1.pl                     
#   
# Description:                                
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext7.1.pl 
use strict;  
my $opt = 0;
my $localtime;
if (@ARGV > 0) {
    $opt = $ARGV[0];
}
else {
    print "Usage: perl $0 opt \n";
    print "    Where opt = 0 or 1 \n";
    exit;
}

if ($opt == 1) {
    defined(my $pid=fork()) or die "Fork process failured:$!\n";  
    unless($pid) {  
        print "\n[DEBUG1] This is the child process.\n\n";
        $localtime = localtime();
        print "[DEBUG1] -- child: current time is $localtime\n\n";
        sleep(3);  
        print ("[DEBUG1] Exit child after 3 seconds wait!\n");  
        exit();  
    }  
    print"[DEBUG1] This is the parent process.\n\n";
    waitpid($pid,0);  
    $localtime = localtime();
    print "[DEBUG1] -- parent: current time is $localtime\n\n";
    print ("[DEBUG1] exit parent!\n\n");  
}
else {
    defined(my $pid1=fork()) or die "Fork process failured:$!\n";  
    unless($pid1) {  
        print "\n[DEBUG2] This is the child process.\n\n";
        $localtime = localtime();
        print "[DEBUG2] -- child: current time is $localtime\n\n";
        sleep(3);  
        print ("[DEBUG2] Exit child after 3 seconds wait!\n");  
        exit();  
    }  
    print"[DEBUG2] This is the parent process.\n\n";
    $localtime = localtime();
    print "[DEBUG2] -- parent: current time is $localtime\n\n";
    print ("[DEBUG2] exit parent!\n\n");  
}

