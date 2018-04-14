#!/usr/bin/perl -w


use warnings;
use strict;
use POSIX;
use Encode;
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::Format;
use Spreadsheet::WriteExcel;
use Term::ANSIColor;



my $parser   = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse( 'HELP.xls' );

if ( !defined $workbook ) {
    die "Parsing error: ", $parser->error(), ".\n";
}


my $excel_out = Spreadsheet::WriteExcel->new('merge.xls');
my $worksheet = $excel_out->add_worksheet();
my $format = $excel_out->add_format(); # Add a format 
$format->set_align('center'); 
my $data_format = $excel_out->add_format ( color => 'black',
                                           align => 'center',
                                           bold => 0,
                                         );
$worksheet->add_write_handler(qr[\w], \&store_string_widths);


my $first_half=$workbook->worksheet(0);
my $second_half=$workbook->worksheet(1);


my $sheet_id_col  = 2;
my $sheet1_id_row = 2;
my $sheet2_id_row = 2;
my $row_dst =2;


my $sheet1_cell_id=1;
my $sheet2_cell_id=1;
my $value_id_a=1;
my $value_id_b=1;



my $sheet1_last_row=6580;
my $sheet2_last_row=6337;
my $sheet1_last_id=18174;
my $sheet2_last_id=18177;


#while ($sheet1_cell_id && $sheet2_cell_id ) {
for(my $test_loop=0 ; $test_loop<100000;$test_loop++ ) {
    
   $sheet1_cell_id   = $first_half->get_cell( $sheet1_id_row, $sheet_id_col );
   $sheet2_cell_id   = $second_half->get_cell( $sheet2_id_row, $sheet_id_col );   
    
   if ($sheet1_id_row ==$sheet1_last_row)   {
       $sheet1_id_row =$sheet1_last_row;
       $value_id_a = $sheet1_last_id;
   }
   else {
     $value_id_a =  $sheet1_cell_id->value() ;

   }
   if ($sheet2_id_row == $sheet2_last_row+1)    {
       $sheet2_id_row =$sheet2_last_row+1;
       $value_id_b = $sheet2_last_id;  
   }
   else {
     $value_id_b =  $sheet2_cell_id->value() ;

   }
    my $sheet1_cell_a =0;
    my $sheet2_cell_b =0;
    my $value_a_copy  =0;
    my $value_b_copy  =0;
#          print "sheet1 id =$value_id_a\n";
#          print "sheet2 id =$value_id_b\n";
#          print "sheet1 row =$sheet1_id_row\n";
#          print "sheet2 row =$sheet2_id_row\n";


     if ($sheet2_id_row ==$sheet2_last_row && $value_id_a >= $value_id_b ){

#        print "go here 1\n";
         for(my $copy_col_a=0 ; $copy_col_a<18 ;$copy_col_a++ )  {
         $sheet1_cell_a   = $first_half->get_cell( $sheet1_id_row, $copy_col_a );
         $value_a_copy =   $sheet1_cell_a->value() ;
         $worksheet->write($row_dst, $copy_col_a, $value_a_copy, $data_format);
          }
          $sheet1_id_row++ ;
          $row_dst++;   
     }         
    elsif($sheet1_id_row ==$sheet1_last_row && $value_id_a <= $value_id_b){
#         print "go here 2\n";

              for(my $copy_col_b=0 ; $copy_col_b<18 ;$copy_col_b++ )  {
         $sheet2_cell_b   = $second_half->get_cell( $sheet2_id_row, $copy_col_b );
         $value_b_copy =   $sheet2_cell_b->value() ;
         $worksheet->write($row_dst, $copy_col_b+18, $value_b_copy, $data_format);
          }
          $sheet2_id_row++ ;
          $row_dst++; 
#print " now the last some row number is $sheet2_id_row\n" ;    
#print " now the last some dst_row number is $row_dst\n"   ;  

    }
     elsif ($value_id_a < $value_id_b ){
          for(my $copy_col_a=0 ; $copy_col_a<18 ;$copy_col_a++ )  {
         $sheet1_cell_a   = $first_half->get_cell( $sheet1_id_row, $copy_col_a );
         $value_a_copy =   $sheet1_cell_a->value() ;
         $worksheet->write($row_dst, $copy_col_a, $value_a_copy, $data_format);
          }
          $sheet1_id_row++ ;
          $row_dst++;   
     }

    elsif ($value_id_a > $value_id_b ) {

          for(my $copy_col_b=0 ; $copy_col_b<18 ;$copy_col_b++ )  {
         $sheet2_cell_b   = $second_half->get_cell( $sheet2_id_row, $copy_col_b );
         $value_b_copy =   $sheet2_cell_b->value() ;
         $worksheet->write($row_dst, $copy_col_b+18, $value_b_copy, $data_format);
          }
          $sheet2_id_row++ ;
          $row_dst++;   
     }
    else {
         for(my $copy_col_merge=0 ; $copy_col_merge<18 ;$copy_col_merge++ )  {
         $sheet1_cell_a   = $first_half->get_cell( $sheet1_id_row, $copy_col_merge );
         $value_a_copy =   $sheet1_cell_a->value() ;
         $worksheet->write($row_dst, $copy_col_merge, $value_a_copy, $data_format);
          }
         for(my $copy_col_merge=0 ; $copy_col_merge<18 ;$copy_col_merge++ )  {
         $sheet2_cell_b   = $second_half->get_cell( $sheet2_id_row, $copy_col_merge );
         $value_b_copy =   $sheet2_cell_b->value() ;
         $worksheet->write($row_dst, $copy_col_merge+18, $value_b_copy, $data_format);
          }
          $sheet1_id_row++ ;
          $sheet2_id_row++ ;
          $row_dst++;   
     }

   if ($sheet1_id_row ==$sheet1_last_row+1)   {
       $sheet1_id_row =$sheet1_last_row;
   }
   else {

   }
   if ($sheet2_id_row ==$sheet2_last_row+1)   {
       $sheet2_id_row =$sheet2_last_row+1;
   }
   else {

   }
   if ($sheet1_id_row ==$sheet1_last_row  && $sheet2_id_row == $sheet2_last_row+1) {
   last;
   }





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
__END__










