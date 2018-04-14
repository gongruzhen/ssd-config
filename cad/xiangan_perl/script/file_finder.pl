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
use File::Find;
use POSIX;
use Encode;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use Term::ANSIColor;

my $tab = " "x4;
my $info  = "[INFO]  --";
my $error = "[ERROR] --";

my $dir_find = "./find_2";
my $dev;
my $ino; 
my $mode; 
my $nlink; 
my $uid; 
my $gid ;



my @directories= ("./find_2" );

sub wanted {
#           /^\.nfs.*\z/s &&
#           (($dev, $ino, $mode, $nlink, $uid, $gid) = lstat($_)) &&
#           int(-M _) > 7 &&
#           unlink($_)
#           ||
#           ($nlink || (($dev, $ino, $mode, $nlink, $uid, $gid) = lstat($_))) &&
#           $dev < 0 &&
#           ($File::Find::prune = 1);

print "$_ \n";
print "$File::Find::dir \n" ;
print "$File::Find::name \n";
 }





find(\&wanted,  $dir_find);
print "\n\n\n\n\n";

finddepth(\&wanted,  @directories);











__END__

my $excel_out = Spreadsheet::WriteExcel->new('syn_channel_rpt.xls');
my $worksheet = $excel_out->add_worksheet();
my $format = $excel_out->add_format(); # Add a format 
$format->set_align('center'); 
my $data_format = $excel_out->add_format ( color => 'black',
                                           align => 'center',
                                           bold => 1,
                                         );

my $data_format_green = $excel_out->add_format ( color => 'green',
                                           align => 'center',
                                           bold => 1,
                                         );
my $data_format_red = $excel_out->add_format ( color => 'red',
                                           align => 'center',
                                           bold => 1,
                                         );




my $merge_format = $excel_out->add_format ( color => 'red',
                                            align => 'center',
                                            bold => 1,
                                         );

my $item_format = $excel_out->add_format ( 
                                          bold => 1,
                                          color => 'gray',
                                          align => 'center',
                                         );
my $channel_format = $excel_out->add_format ( bold => 1,
                                              size => 12,
                                              color => 'blue',
                                              align => 'center',
                                            );

$worksheet->add_write_handler(qr[\w], \&store_string_widths);
  my %col;
    
    $col{"Module"}     =  0; 
    $col{"INPUTPATHS Critical Path Slack"}   =  1; 
    $col{"Sequential Cell Count"}     =  2; 
    $col{"Design Area"}        =  3; 



foreach my $key (keys %col) {
        my $col_num = $col{"$key"};
        $worksheet->write(0, $col_num, $key, $channel_format);
    }
    $row_num++;

&parse_syn_logs($log_dir);


sub parse_syn_logs {
    my $syn_rpt = shift;

    print "\n${info} Start to parse the syn rpt files in $syn_rpt dir\n\n";
    my @syn_files;
    # @syn_files = glob("$syn_rpt/*.log");
    opendir DH, $syn_rpt or die "Cannot open $syn_rpt dir for reading!\n";
    while (my $name = readdir DH) {
        $name = "${syn_rpt}/${name}";
        push (@syn_files, $name) if $name =~ /.*qor.rpt$/;
    }
    closedir DH;

    if (!defined $syn_files[0] || $syn_files[0] =~ /^\s*$/) {
        print "${error} Do not obtain valid syn rpt files. Exiting...\n\n";
        exit;
    }
   my  $all_rpt_cnt = @syn_files;
  print "${info}  $all_rpt_cnt rpt files to be parsed  \n\n";

    foreach my $syn_file (@syn_files) {
        my $module_name = substr($syn_file ,10,100);
        #print "------------$syn_file ------------ \n\n";
        $worksheet->write($row_num,  $col{"Module"}  , $module_name, $item_format);                
        open (SYN, "<", $syn_file) or die "Can not open $syn_file for reading!\n";
        my $valid_slack =0;
        while (defined (my $line = <SYN>)) {
            chomp $line;
            next if $line =~ /^\s*$/;
            $line =~ s/^\s*|\s*$//g;
            if ($line =~ /\s*'INPUTPATHS'\s*/) {
                 $valid_slack =1;
            }            
            if($line =~ /^\s*Critical Path Slack:\s*/){
                if($valid_slack==1){
                my @slack_data=split/\s+/,$line;
                my $data_slack = $slack_data[3];
               $worksheet->write($row_num, $col{"INPUTPATHS Critical Path Slack"} , $data_slack , $data_format_green)if ($data_slack>=0) ;
               $worksheet->write($row_num, $col{"INPUTPATHS Critical Path Slack"} , $data_slack , $data_format_red  )if ($data_slack<0) ;
               $valid_slack =0;
                }
                else{
                }
            }
            if ($line =~ /^\s*Sequential Cell Count:\s*/) {
                my @cell_count=split/\s+/,$line;
                my $data_count=$cell_count[3];
               $worksheet->write($row_num, $col{"Sequential Cell Count"} , $data_count , $data_format);
            }
            
            if ($line =~ /^\s*Design Area:\s*/) {
                my @area=split/\s+/,$line;
                my $data_area=$area[2];
               $worksheet->write($row_num, $col{"Design Area"} , $data_area , $data_format);
            }

        }
        $row_num++;
        close(SYN);
    }
    print "${info} Complete to generate syn rpts in excel  \n\n";
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

#                my $rprt_data_cnt=@rpts_data ;
#                #print "${info}   $rprt_data_cnt \n\n";
#                my $data_name  = $rpts_data[0];
#                my $data_slack = $rpts_data[6];
#                #print "${info}   @rpts_data   \n\n";
#                #print "${info}   $data_name   \n\n";
#                #print "${info}   $data_slack  \n\n";
#               $worksheet->write($row_num, $col_num  , $data_name , $data_format);
#               $worksheet->write($row_num, $col_num+1, $data_slack, $data_format_red) if ($data_slack<=0) ;
#               $worksheet->write($row_num, $col_num+1, $data_slack, $data_format_green) if ($data_slack>0) ;
#               $row_num++;

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









