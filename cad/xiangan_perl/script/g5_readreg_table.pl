#!/usr/bin/perl -w

#######################################################
#
# File Name: make_regression.pl
#
# Description:
#     The script used to run regression test and generate excel report 
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
use Term::ANSIColor;
my $tab = " "x4;
#case list here
my $year_month_day = strftime("%y%m%d" , localtime());
#print "$year_month_day\n ";
#print "@nandtype\n ";
#print "@cases\n ";

sub ColorMessage{
my($colors,$messages)=@_;
print color"bold $colors";
print "$messages\n";
print color 'reset';
}
#ColorMessage('green','hello'); #test for color print//////


#----------gen_excel_report----------
print "[INFO]  -- Start to generate the excel report\n\n";
my $excel_out = Spreadsheet::WriteExcel->new('g5_readreg_table.xls');
my $worksheet = $excel_out->add_worksheet();
my $format = $excel_out->add_format(); # Add a format 
$format->set_align('center'); 
my %col;
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
$worksheet->add_write_handler(qr[\w], \&store_string_widths);

    ## write the header: case_id, description, note and teststatus

    $col{"Address Decimal"}         =  0; 
    $col{"Address Hexadecimal"}     =  1; 
    $col{"ReadValue Decimal"}       =  2; 
    $col{"ReadValue Hexadecimal"}   =  3; 
    $col{"G5 Spec Value"}           =  4; 


    foreach my $key (keys %col) {
        my $col_num = $col{"$key"};
        $worksheet->write(0, $col_num, $key, $head_format);
    }
    my $row_num = 1;


#------------parse summary report  print on results on terminal-----------
        my $file = "./g5_readreg_table.log";
        my $case_name;
        my $addr_decimal=0;
        my $addr_hex=0;
        my $value_decimal=0;
        my $value_hex=0;

        open (SUMMARY, "<", $file) or die "Can not open $file for reading!\n";
        while (defined (my $line = <SUMMARY>)) {
            chomp $line;
            next if $line =~ /^\s*$/;#skip blank
            $line =~ s/^\s*|\s*$//g;#delete head and tail space
            if ($line =~ /^Address\sis\s(\d+)\((\w+)\),default\svalue\sis\s(\d+)\((\w+)\)\s*/) {  #search pattern
                $addr_decimal  = $1;
                $addr_hex      = $2;
                $value_decimal = $3;
                $value_hex     = $4;
                print "$1---$2---$3---$4 \n";#print for patter search debug 
            $worksheet->write($row_num, $col{"Address Decimal"}, $addr_decimal);
            $worksheet->write($row_num, $col{"Address Hexadecimal"}, $addr_hex,$format);
            $worksheet->write($row_num, $col{"ReadValue Decimal"}, $value_decimal,$format);  
            $worksheet->write($row_num, $col{"ReadValue Hexadecimal"}, $value_hex,$format);
            $worksheet->write($row_num, $col{"G5 Spec Value"}, "",$format);
            $row_num++;
            }
            else {
                }
        }
        
        close(SUMMARY);

    print "[INFO]  -- The excel report has been written into g5_readreg_table.xls\n\n";





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

    return 1.5 * length $_[0];
}








