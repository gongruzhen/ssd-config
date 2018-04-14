#!/usr/bin/perl -w
use strict;
# --------------------------------------------
# Filename   : .\ext3.3.pl                     
#   
# Description:                                
#                                             
# Author:                                     
#     Peter.Shi <peter_soc_vrf@163.com>       
# --------------------------------------------
# .\ext3.3.pl 
my %movies;  
my $film;  
my %reverse_result;  
my $director;  
my @data;  

%movies =  
(  
  'The Shining'       => 'Kubrick',  
  'Ten Commandments'  => 'DeMille',  
  'Goonies'           => 'Spielberg',  
);  

# print out the hash's value
print $movies{'The Shining'};   # Kubrick 
print"\n";  

# print out the hash key and its corresponding value
foreach $film(keys %movies)  
{  
   print "$film was directed by $movies{$film}.\n";  
}  
print "\n";  

# reverse hash
%reverse_result=reverse %movies;  
foreach $director(keys %reverse_result)  
{  
   print "$director directe the $reverse_result{$director}.\n";   
} 

print "\n"; 

# transfer hash to common array
@data=%movies;  
 print "@data\n";  

print"\n";  

# transfer array to hash
%movies=@data;  
foreach $director(keys %reverse_result)  
{  
  print "$director directe the $reverse_result{$director}.\n";   
}      
print "The result is not change\n"; 
