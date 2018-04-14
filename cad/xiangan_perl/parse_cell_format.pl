#!/usr/bin/perl

###############################################################################
#
# A simple Spreadsheet::ParseExcel Excel parser.
#
# reverse('??'), January 2010, John McNamara, jmcnamara@cpan.org
#

use warnings;
use strict;
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::Format;

my $filename = $ARGV[0] or die "Must specify filename to parse.\n";
my $parser   = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse( $filename );

if ( !defined $workbook ) {
    die "Parsing error: ", $parser->error(), ".\n";
}

for my $worksheet ( $workbook->worksheets() ) {

    print "Worksheet name: ", $worksheet->get_name(), "\n\n";

    my ( $row_min, $row_max ) = $worksheet->row_range();
    my ( $col_min, $col_max ) = $worksheet->col_range();
           print "    Rowmin, Rowmax    = ($row_min, $row_max)\n";
           print "    Colmin, Colmax    = ($col_min, $col_max)\n";
    for my $row ( $row_min .. 3 ) {
        for my $col ( $col_min .. $col_max ) {

            my $cell   = $worksheet->get_cell( $row, $col );
            next unless $cell;
            my $format = $cell->get_format(); 

            print "    Row, Col    = ($row, $col)\n";
            print "    Value       = ", $cell->value(),       "\n";
            print "    Unformatted = ", $cell->unformatted(), "\n";
#           print "    format      = ",$cell->get_format(),         "\n";
            print "    type        = ",$cell->type(),         "\n";
            print "    encoding    = ",$cell->encoding(),         "\n";
#print "    font        = ",$format->{Font},         "\n";
            print "    AlignH      = ",$format->{AlignH},         "\n";
            print "    AlignV      = ",$format->{AlignV},         "\n";
            print "    font_name   = ",$format->{Font}->{Name},         "\n";
            print "    font_bold   = ",$format->{Font}->{Bold},         "\n";
            print "    font_italic = ",$format->{Font}->{Italic},         "\n";
            print "    font_height = ",$format->{Font}->{Height},         "\n";
            print "    font_xiahua = ",$format->{Font}->{Underline},         "\n";
            print "    font_huastyl= ",$format->{Font}->{UnderlineStyle},         "\n";
            print "    font_color  = ",$format->{Font}->{Color},         "\n";
            print "    font_super  = ",$format->{Font}->{Super},         "\n";
            print "    font_strike = ",$format->{Font}->{Strikeout},         "\n";
            print "\n";
        }
    }
}

__END__
