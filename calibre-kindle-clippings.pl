#!perl

#
# Sample script for Calibre::Kindle::Clippings
#

use feature qw(say);
use Calibre::Kindle::Clippings qw(parse_clippings_file);

parse_clippings_file(
    $ARGV[0],
    sub {
        $c = shift;
        say join( "|",
            $c->{title}, $c->{author}, $c->{date}, $c->{type}, $c->{page},
            $c->{loc}, "@{ $c->{text} }" );
    }
);
