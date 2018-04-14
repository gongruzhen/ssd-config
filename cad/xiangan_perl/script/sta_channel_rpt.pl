#!/usr/bin/perl -w
# --------------------------------------------
# Filename   : test                     
#   
# Description:                                
#     The example used to show how to use 
#     directory handle in Perl
#                                             
# Author:                                     
#    xiangan       
# --------------------------------------------
# ext6.3.pl 
use strict;
use POSIX;
use Encode;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use Term::ANSIColor;

my $log_dir = "./rpt";
my $tab = " "x4;
my $info  = "[INFO]  --";
my $error = "[ERROR] --";
my $row_num =0;
my $col_num =0;

my $excel_out = Spreadsheet::WriteExcel->new('sta_channel_rpt.xls');
my $worksheet = $excel_out->add_worksheet();
my $format = $excel_out->add_format(); # Add a format 
$format->set_align('center'); 
my $data_format = $excel_out->add_format ( color => 'gray',
                                           align => 'vcenter',
                                           bold => 1,
                                         );

my $data_format_green = $excel_out->add_format ( color => 'green',
                                           align => 'vcenter',
                                           bold => 1,
                                         );
my $data_format_red = $excel_out->add_format ( color => 'red',
                                           align => 'vcenter',
                                           bold => 1,
                                         );




my $merge_format = $excel_out->add_format ( color => 'red',
                                            align => 'center',
                                            bold => 1,
                                         );

my $item_format = $excel_out->add_format ( 
                                          bold => 1,
                                          color => 'black',
                                          align => 'vcenter',
                                         );
my $channel_format = $excel_out->add_format ( bold => 1,
                                              size => 12,
                                              color => 'blue',
                                              align => 'center',
                                            );

$worksheet->add_write_handler(qr[\w], \&store_string_widths);

&parse_sta_logs($log_dir);


sub parse_sta_logs {
    my $sta_rpt = shift;
    print "\n${info} Start to parse the sta rpt files in $sta_rpt dir\n\n";
    my @sta_files;
    # @sta_files = glob("$sta_rpt/*.log");
    opendir DH, $sta_rpt or die "Cannot open $sta_rpt dir for reading!\n";
    while (my $name = readdir DH) {
        $name = "${sta_rpt}/${name}";
        push (@sta_files, $name) if $name =~ /\.rpt$/;
    }
    closedir DH;

    if (!defined $sta_files[0] || $sta_files[0] =~ /^\s*$/) {
        print "${error} Do not obtain valid staulation rpt files. Exiting...\n\n";
        exit;
    }
   my  $all_rpt_cnt = @sta_files;
  print "${info}  $all_rpt_cnt rpt files to be parsed  \n\n";

    foreach my $sta_file (@sta_files) {
        my $pin_port = substr($sta_file ,6,100);
        #print "------------$sta_file ------------ \n\n";
                
#        $worksheet->write($row_num, $col_num, "Channel:  ".$pin_port, $channel_format);
         $worksheet->merge_range($row_num,$col_num,$row_num,$col_num+1,"Channel:  ".$pin_port,$channel_format ); 
        $row_num++;
        $worksheet->write($row_num, $col_num  , "Endpoint", $item_format);
        $worksheet->write($row_num, $col_num+1, "Slack"   , $item_format);
        $row_num++;

        open (STA, "<", $sta_file) or die "Can not open $sta_file for reading!\n";
        while (defined (my $line = <STA>)) {
            chomp $line;
            next if $line =~ /^\s*$/;
            $line =~ s/^\s*|\s*$//g;
            if ($line =~ /^C(\d+)_DQ(\d+)\s\(inout\)\s*/) {
                my @rpts_data=split/\s+/,$line;
                my $rprt_data_cnt=@rpts_data ;
                #print "${info}   $rprt_data_cnt \n\n";
                my $data_name  = $rpts_data[0];
                my $data_slack = $rpts_data[6];
                #print "${info}   @rpts_data   \n\n";
                #print "${info}   $data_name   \n\n";
                #print "${info}   $data_slack  \n\n";
               $worksheet->write($row_num, $col_num  , $data_name , $data_format);
               $worksheet->write($row_num, $col_num+1, $data_slack, $data_format_red) if ($data_slack<=0) ;
               $worksheet->write($row_num, $col_num+1, $data_slack, $data_format_green) if ($data_slack>0) ;
               $row_num++;
            } elsif ($line =~ /^No constrained paths.*/) {
                  #print "${info} No constrained paths.   \n\n";               
#               $worksheet->write($row_num, $col_num, "No constrained paths" , $data_format);
               $worksheet->merge_range($row_num,$col_num,$row_num,$col_num+1,"No constrained paths",$merge_format );           
               $row_num++;     
            }
             else{
             }

        }
        close(STA);
    }
    print "${info} Complete to generate sta rpts in excel  \n\n";
}


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

    return 1.2 * length $_[0];
}
__END__









