#!/usr/bin/perl -w
# --------------------------------------------
# Filename   : move wire/reg signal decleration to top                 
#          
# Author:                                     
#    xiangan       
# --------------------------------------------
use strict;

my $tab = " "x4;
my $info  = "[INFO]  --";
my $error = "[ERROR] --";

my $rtl_dir = "./"; #rtl dir ,default is current directory
my @save_tmp_line;
my $line_position = 10;

opendir DIR, $rtl_dir or die "Cannot open $rtl_dir: $!";
foreach my $file_name (readdir DIR) {
    if ($file_name =~ m/.*\.v$/) { #if rtl verilog ,then get down to business
    print "$file_name\n"; #print for debug
    open (SUMMARY, "<", $file_name) or die "Can not open $file_name for reading!\n";
        while (defined (my $line = <SUMMARY>)) {
        chomp $line;
        next if $line =~ /^\s*$/;#skip blank
        $line =~ s/^\s*|\s*$//g;#delete head and tail space
        if ($line =~ /\s?wire\s.*;$/) {  # match for wire
            push @save_tmp_line , $line; # push in the array for saving 
        }
        elsif($line =~ /\s?reg\s.*;$/) { 
            push @save_tmp_line , $line;
        }
        else{
        }
        }
print "@save_tmp_line\n"; #print for debug
           system ("sed -i \'/^wire \\+/d\'   $file_name" ) ;    #delete wire 
           system ("sed -i \'/ \\+wire \\+/d\' $file_name" ) ;
           system ("sed -i \'/^reg \\+/d\'    $file_name" ) ;
           system ("sed -i \'/ \\+reg \\+/d\'  $file_name" ) ;
my $copy_loop = @save_tmp_line ; #see how many lines in the array ,then copy back to line_position 
#print "$copy_loop \n" ; #print for debug
my $target_line;
for (my $i=1 ; $i<=$copy_loop ; $i++){
  $target_line= pop @save_tmp_line ;
#  print " $target_line\n"; #print for debug
system "sed  \'$line_position i $target_line\' -i $file_name "; #10means line10,change to the common line for all the rtl file
        }
    }
    else{
#not rtl verilog ,do nothing
    }
}


print "You've moved the wire/reg signal declertaion to $line_position!\n "

__END__

