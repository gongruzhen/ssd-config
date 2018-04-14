#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : ext6.5.pl                     
#   
# Description:                                
#     
#     
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# ext6.5.pl 
my $user = 1004;
my $group = 100;
chown $user, $group, glob "*.o";

defined(my $user = getpwnam "merlyn") or die "bad user";
defined(my $group = getgrnam "users") or die "bad group";
chown $user, $group, glob "/home/merlyn/*";
