package Calibre::Kindle::Clippings;

use utf8;
use strict;
no warnings;
use Exporter qw(import);
use Carp;
use vars qw($VERSION);

our $VERSION = '0.0.1';
our @EXPORT_OK = qw(parse_clippings_file);

parse_clippings_file() unless caller();

=encoding utf8

=head1 NAME

Calibre::Kindle::Clippings - Parse Kindle clippings file created by Calibre (the open source e-book library manager)

=head1 SYNOPSIS

use Calibre::Kindle::Clippings qw(parse_clippings_file);

parse_clippings_file($path_to_file, \&callback);

sub callback {

    my ($clip) = @_;

    say $clip->{title};     # book title
    say $clip->{author};    # book author(s)
    say $clip->{type};      # clip type: bookmark, highlight or note
    say $clip->{page};      # book page, not always available
    say $clip->{loc};       # location
    say $clip->{date};      # clip creation date
    say @{ $clip->{text} }; # clip text (arrayref)

}

=head1 DESCRIPTION

=over 4

=item parse_clippings_file( $clippings_file_path, $coderef )

parse_clippings_file() processes the Kindle Clippings file created by Calibre
and located at $clipping_file_path. For each clipping it calls the callback
function passed as the second argument.

The callback subroutine is evaluated passing a hash reference as the only
parameter. The hash reference contains all the information available for a 
clipping: book title, book author(s), page, location, date of creation and
the actual text of the note/highlight.

By default Calibre saves Kindle annotations to a file named 
"My Clippings - Kindle.txt" located under /path/to/your/calibre/library/Kindle/My\ Clippings\ \(<number>\)/

=cut

sub parse_clippings_file {

    my ( $clippings_file, $coderef ) = @_;

    if ( not -r $clippings_file ) {

        croak
            "Clippings file $clippings_file doesn't exist or isn't readable";

    }

    # Even in Mac OS X the clippings file has DOS format
    # so end-of-line is CRLF not just \n

    open my $FH, '<:crlf', $clippings_file or croak $!;

    do {

        my ( $book,      $title,     $author );
        my ( $clip_type, $clip_info, @clip_text );
        my ( $page,      $loc,       $date );
        my $clip_text_line;

        $book = <$FH>;

        ( $title, $author ) = ( $book =~ m/(.+)\s+\((.+)\)/ );

        $clip_info = <$FH>;

        ( $clip_type, $page, $loc, $date )
            = ( $clip_info
                =~ m/^\- ([^\s]+) (?:on Page (\d+)\s+\|\s+)?(?:Loc\.\s([^\s]+)\s+\|\s+)?Added on (.+)/
            );

        # this will allways be a blank line

        $clip_text_line = <$FH>;

        do {

            chomp $clip_text_line;
            push @clip_text, $clip_text_line;
            $clip_text_line = <$FH>;

        } while ( $clip_text_line !~ m/^==========/ );

        my $clip = {
            title  => $title,
            author => $author,
            page   => $page,
            type   => $clip_type,
            loc    => $loc,
            date   => $date,
            text   => \@clip_text,
        };

        &{$coderef}($clip);

    } while not eof;

    close $FH;

    return 1;

}

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

http://github.com/alexanderBendo/Util/

=head1 AUTHOR

Alexander Bendo, C<< <alexander.bendo@directorioc.net> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2013, Alexander Bendo, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

;
