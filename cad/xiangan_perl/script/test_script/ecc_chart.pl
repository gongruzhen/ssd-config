#!/usr/bin/perl -w

#######################################################
#
# File Name: ecc_line_chart.pl
#
# Description:
#     The script used to sample ecc data and generate excel report with line chart
#
# Author:
#     xiangan
#
#######################################################
use warnings;
use strict;
use POSIX;
use Encode;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use Spreadsheet::WriteExcel::Utility qw(xl_range_formula) ;
use Term::ANSIColor;

my $tab = " "x4;
my $year_month_day = strftime("%y%m%d" , localtime());
#print "$year_month_day\n ";
sub ColorMessage{
my($colors,$messages)=@_;
print color"bold $colors";
print "$messages\n";
print color 'reset';
}
#ColorMessage('green','hello'); #test for color print


my @ecc_src_data_array_full; #every ecc global set has 2 data , ecc[number] = data1  data2 % ,so the array size is capabality*2*ecc_data_scr_cnt

my $ecc_new_data_src=0;#for different line chart data source
my $ecc_capability=72; #ecc max error correction capability
my $ecc_x_dot =0; # data sequence ecc[1]-->ecc[2]-->ecc[3]....>ecc[$ecc_capability]

my $excel_out = Spreadsheet::WriteExcel->new('ecc_line_chart_report.xls');#new execl 
my $worksheet = $excel_out->add_worksheet();#add worksheet ,default Sheet1
my $format = $excel_out->add_format(); # Add a format 
$format->set_align('center'); 
my $head_format = $excel_out->add_format (    bold => 1,
                                              size => 12,
                                              color => 'blue',
                                              align => 'center',
                                         );
my $red_format = $excel_out->add_format ( color => 'red',
                                          align => 'center',
                                        );
my $gre_format = $excel_out->add_format ( color => 'green',
                                          align => 'center',
                                        );
$worksheet->add_write_handler(qr[\w], \&store_string_widths);#for column format adjust



######################  sample all the ecc data in the log  ############################
my $log = "./testflash_vpp_off.log"; #search for log
open (SUMMARY, "<", $log) or die "Can not open $log for reading!\n";
        while (defined (my $line = <SUMMARY>)) {
            chomp $line;
            next if $line =~ /^\s*$/;#skip blank
            $line =~ s/^\s*|\s*$//g;#delete head and tail space
            if ($line =~ /.*ECC result:$/) {  # search new ecc result and ready to start sample log ecc data
                if($ecc_x_dot< $ecc_capability && $ecc_x_dot>1 )  { 
                 for(my $ecc_fillblank_end=$ecc_x_dot ;  $ecc_fillblank_end<=$ecc_capability ; $ecc_fillblank_end++){
                        #print " ecc[$ecc_fillblank_end] = 0          0\.0\% \n ";  # fill ecc[number] to the ecc max capability with 0
                        push @ecc_src_data_array_full , 0; #data 1 number 
                        push @ecc_src_data_array_full , 0.0;  #data 2 percent                          
                    }
                  #print "end for one ecc data loop \n "; #print for debug
                 } 
              $ecc_x_dot =1; #restart one ecc data for ecc tag 1 beginning
              $ecc_new_data_src++; #it is equal to the ecc_data_scr_cnt when last loop is over
              #print " new ecc data set : $ecc_new_data_src\n";   #print for debug 
              next;
            }         
            if ($line =~ /^ecc\[253\].*/) { #search ecc[FD]  means the last data in one ecc data set
                if($ecc_x_dot< $ecc_capability)  { 
                 for(my $ecc_fillblank_end=$ecc_x_dot ;  $ecc_fillblank_end<=$ecc_capability ; $ecc_fillblank_end++){
                        #print " ecc[$ecc_fillblank_end] = 0          0\.0\% \n ";  # fill ecc[number] to the ecc max capability with 0
                        push @ecc_src_data_array_full , 0;
                        push @ecc_src_data_array_full , 0.0;
                            
                 }
                  #print "end for one ecc data loop \n "; #print for debug
                 } 
             $ecc_x_dot =1; #restart one ecc data for ecc tag 1 beginning                
             next;   # skip ecc[FD] value not to draw on the line chart
            }
            if ($line =~ /^ecc\[\s?$ecc_x_dot\]\s\=\s(\d+)\s+\%(\d+)\.(\d+)/) {  # ecc[number] is in the log 
                        #print " ecc[$ecc_x_dot] = $1          $2\.$3\%  \n ";
                        push @ecc_src_data_array_full , $1;
                        push @ecc_src_data_array_full , $2.$3;

                       $ecc_x_dot= $ecc_x_dot +1 ;
            }
            else { 
                 if($line =~ /^ecc\[\s?(\d+)\]\s\=\s(\d+)\s+\%(\d+)\.(\d+)/){ # ecc[number] is not in the log and need to be filled with 0
                   for(my $ecc_fillblank=$ecc_x_dot ;  $ecc_fillblank<$1 ;  $ecc_fillblank++){
                        #print " ecc[$ecc_fillblank] = 0          0\.0\% \n ";
                        push @ecc_src_data_array_full , 0;
                        push @ecc_src_data_array_full , 0.0;

                   }
                        #print " ecc[$1] = $2          $3\.$4\% \n ";
                        push @ecc_src_data_array_full , $2;
                        push @ecc_src_data_array_full , $3.$4;

                        $ecc_x_dot= $1+1;
                        #print "$ecc_x_dot \n "; #print for debug                         
                 }
            }
}

print "Done for array setup , there are all $ecc_new_data_src set(s) of ecc data !\n" ;
#print array and array size for debug
#print "@ecc_src_data_array_full\n" ;
#my $array_cnt =@ecc_src_data_array_full;
#print "$array_cnt\n" ;


################    generate execl with the data sampled in the @ecc_src_data_array_full   ###################
$worksheet->write(0, 0, "ecc[error_number]", $head_format);#write common head of ecc_error_number in first column
for(my $excel_first_col_loop=1 ;$excel_first_col_loop<=$ecc_capability ;$excel_first_col_loop++  ){  
    $worksheet->write($excel_first_col_loop , 0 , "ecc[$excel_first_col_loop]" , $format); 
}
for(my $excel_first_row_loop=1 ;$excel_first_row_loop<=$ecc_new_data_src*2 ;$excel_first_row_loop=$excel_first_row_loop+2  ){  # write all the ecc data sets head of err cnt in first row
        my $cnt_tag = ($excel_first_row_loop+1)/2 ;
        $worksheet->write(0, $excel_first_row_loop, "error_cnt_$cnt_tag", $head_format);
}
for(my $excel_first_row_loop=2 ;$excel_first_row_loop<=$ecc_new_data_src*2 ;$excel_first_row_loop=$excel_first_row_loop+2  ){  # write all the ecc data sets head of err percent in first row
        my $percent_tag = ($excel_first_row_loop)/2 ;
        $worksheet->write(0, $excel_first_row_loop, "error_payload_percent_$percent_tag", $head_format);
}

my $ecc_data_cnt_col_fill=1;
for(my $excel_col_loop=1 ;$excel_col_loop<=$ecc_new_data_src ;$excel_col_loop++  ){  #every ecc_capability one set here is 72 * 2 data 
    for ( my $excel_row_loop=1 ;$excel_row_loop<=$ecc_capability ;$excel_row_loop++ ) {
    my $ecc_data_1 = shift @ecc_src_data_array_full;
    my $ecc_data_2 = (shift @ecc_src_data_array_full)/10;
   #print "$ecc_data_1\n";
   #print "$ecc_data_2\n";
    $worksheet->write($excel_row_loop,$ecc_data_cnt_col_fill       , "$ecc_data_1"); #col n   data_1
    $worksheet->write($excel_row_loop,$ecc_data_cnt_col_fill+1     , "$ecc_data_2"); #col n+1 data_2
    }
    $ecc_data_cnt_col_fill=$ecc_data_cnt_col_fill+2; #every set has 2 data src 
} 

print "Done for excel data fill !\n" ;

################    draw line chart with the data above generated in excel  ###################
my $ecc_chart_by_number = $excel_out->add_chart( name => 'Results Chart by Number', type => 'line' );
# Add some labels.
$ecc_chart_by_number->set_title( name => 'Results of sample analysis' );
$ecc_chart_by_number->set_x_axis( name => 'ECC Sample number' );
$ecc_chart_by_number->set_y_axis( name => 'ECC Sample count ' );

for (my $chart_line_number=1 ; $chart_line_number<=$ecc_new_data_src ; $chart_line_number++) {
$ecc_chart_by_number->add_series(
    categories => xl_range_formula('Sheet1',1,72,0,0 ), #x is always the first column 
    values     => xl_range_formula('Sheet1',1,72,2*$chart_line_number-1,2*$chart_line_number-1),# y is the ecc data
    name       => 'ECC Test data series_'.$chart_line_number ,
    );
}

my $ecc_chart_by_percent = $excel_out->add_chart( name => 'Results Chart by percent', type => 'line' );
# Add some labels.
$ecc_chart_by_percent->set_title( name => 'Results of sample analysis' );
$ecc_chart_by_percent->set_x_axis( name => 'ECC Sample number' );
$ecc_chart_by_percent->set_y_axis( name => 'ECC Sample percent ' );

for (my $chart_line_number=1 ; $chart_line_number<=$ecc_new_data_src ; $chart_line_number++) {
$ecc_chart_by_percent->add_series(
    categories => xl_range_formula('Sheet1',1,72,0,0 ),
    values     => xl_range_formula('Sheet1',1,72,2*$chart_line_number,2*$chart_line_number),
    name       => 'ECC Test data series_'.$chart_line_number ,
    );
}
print "Done for excel line chart out ! \n" ;


################    auto fit for columns gap    ######################
autofit_columns($worksheet);
###############################################################################
#
# Functions used for Autofit.
#
###############################################################################

###############################################################################
#
# Adjust the column widths to fit the longest string in the column.
#
sub autofit_columns {

    my $worksheet = shift;
    my $col       = 0;

    for my $width (@{$worksheet->{__col_widths}}) {

        $worksheet->set_column($col, $col, $width) if $width;
        $col++;
    }
}
###############################################################################
#
# The following function is a callback that was added via add_write_handler()
# above. It modifies the write() function so that it stores the maximum
# unwrapped width of a string in a column.
#
sub store_string_widths {

    my $worksheet = shift;
    my $col       = $_[1];
    my $token     = $_[2];

    # Ignore some tokens that we aren't interested in.
    return if not defined $token;       # Ignore undefs.
    return if $token eq '';             # Ignore blank cells.
    return if ref $token eq 'ARRAY';    # Ignore array refs.
    return if $token =~ /^=/;           # Ignore formula

    # Ignore numbers
    return if $token =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;

    # Ignore various internal and external hyperlinks. In a real scenario
    # you may wish to track the length of the optional strings used with
    # urls.
    return if $token =~ m{^[fh]tt?ps?://};
    return if $token =~ m{^mailto:};
    return if $token =~ m{^(?:in|ex)ternal:};


    # We store the string width as data in the Worksheet object. We use
    # a double underscore key name to avoid conflicts with future names.
    #
    my $old_width    = $worksheet->{__col_widths}->[$col];
    my $string_width = string_width($token);

    if (not defined $old_width or $string_width > $old_width) {
        # You may wish to set a minimum column width as follows.
        #return undef if $string_width < 10;

        $worksheet->{__col_widths}->[$col] = $string_width;
    }


    # Return control to write();
    return undef;
}
###############################################################################
#
# Very simple conversion between string length and string width for Arial 10.
# See below for a more sophisticated method.
#
sub string_width {

    return 1.4 * length $_[0];
}



__END__

