#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : gen_logs.pl                     
#   
# Description:                                
#     the script used to generate the log file
#     that used to test the rename operation
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# gen_logs.pl 
if (-e "./logs") {
    unlink glob "./logs/*";
}
else {
    system("mkdir ./logs");
}


for my $num (1..10) {
    system("touch ./logs/${num}.old");
    system("echo 'just for test' > ./logs/${num}.old");
}

