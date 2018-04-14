#!/usr/bin/perl -w
# --------------------------------------------
# Filename   : move wire/reg signal decleration to top                 
#          
# Author:                                     
#    xiangan       
# --------------------------------------------
use strict;
use File::Find;

my $tab = " "x4;
my $info  = "[INFO]  --";
my $error = "[ERROR] --";

my $dir_find = "./";
my @directories= "./";
my @save_tmp_line;
my $file_name;
my $line_position = 10;


sub wanted {
if ($File::Find::name =~ /\.v$/) {
    #$file_name = $File::Find::name ; 
     $file_name = $_ ;# sub function will automatically enter into the sub_dir ,so here use the file name is enough,thus the following open function is ok ,or will die cannot open
    #print "$file_name\n";
    print "$File::Find::dir \n";
    open (SUMMARY, "<", $file_name) or die "Can not open $file_name for reading!\n";
        while (defined (my $line = <SUMMARY>)) {
        chomp $line;
        next if $line =~ /^\s*$/;#skip blank
        $line =~ s/^\s*|\s*$//g;#delete head and tail space
        if ($line =~ /\s?wire\s.*;$/) { # match for wire
            push @save_tmp_line , $line; # push in the array for saving
        }
        elsif($line =~ /\s?reg\s.*;$/) {
            push @save_tmp_line , $line;
        }
        else{
        }
    }
    #print "$file_name\n";
    #print "@save_tmp_line\n"; #print for debug
    system ("sed -i \'/^wire \\+/d\'    $file_name" ) ;#delete wire
    system ("sed -i \'/ \\+wire \\+/d\' $file_name" ) ;
    system ("sed -i \'/^reg \\+/d\'     $file_name" ) ;
    system ("sed -i \'/ \\+reg \\+/d\'  $file_name" ) ;

    my $copy_loop = @save_tmp_line ; #see how many lines in the array ,then copy back to line_position
    print "there are $copy_loop reg/wire declerations in all to be moved in the $file_name\n" ; #print for debug
    my $target_line;
    for (my $i=1 ; $i<=$copy_loop ; $i++){
    $target_line= shift @save_tmp_line ;
   #print " $target_line\n"; #print for debug
    system "sed  \'$line_position i $target_line\' -i $file_name "; #10means line10,change to the common line for all the rtl file
    }
    print "You've moved the wire/reg signal declertaion to $line_position in the $file_name !\n\n\n "      
    
}
else {
#not rtl verilog ,do nothing
}

}

find(\&wanted,  $dir_find);
#finddepth(\&wanted,  @directories);








__END__

