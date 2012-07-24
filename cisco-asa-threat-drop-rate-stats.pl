#!/usr/bin/perl

#
# Show a recommended upper limit for both
# * max configured current rate
# * max configured average rate
#
# In the Normal distribution 99.7% of the observations occur within three
# standard deviations of the mean. This will be the recommended upper limit
#

use strict;
use warnings;
use 5.010;
use Statistics::Descriptive;

my %stats;

my @threats = (
    'ACL drop',
    'Bad pkts',
    'Conn limit',
    'DoS attck',
    'Firewall',
    'ICMP attk',
    'Inspect',
    'Interface ',
    'Rate limit',
    'SYN attck',
    'Scanning'
);

my @configurable_values = qw/current average/;

my @drop_rates = qw/1 2/;

foreach my $threat (@threats) {

    foreach my $value (@configurable_values) {

        foreach my $drop_rate (@drop_rates) {

            $stats{$threat}{$value}{$drop_rate}
                = Statistics::Descriptive::Full->new;
            $stats{$threat}{$value}{$drop_rate}
                = Statistics::Descriptive::Full->new;

        }

    }

}

my $regex
    = qr/\[\s+(.+)\] drop rate-(\d).+\. Current burst rate is (\d+) per second, .+ Current average rate is (\d+) per second,/;

foreach my $log (@ARGV) {

    open my $FH, '<', $log;

    while (<$FH>) {

        chomp;

        next if not m/$regex/;

        my ( $threat, $drop_rate, @rates ) = $_ =~ $regex;

        foreach my $value (@configurable_values) {

            $stats{$threat}{$value}{$drop_rate}->add_data( shift @rates );

        }

    }

    close $FH;

}

foreach my $threat ( keys %stats ) {

    foreach my $value (@configurable_values) {

        foreach my $drop_rate (@drop_rates) {

            say sprintf "$threat $value drop-rate $drop_rate: %.0f",
                get_upper_limit( $stats{$threat}{$value}{$drop_rate}->mean,
                $stats{$threat}{$value}{$drop_rate}->standard_deviation );

        }

    }

}

sub get_upper_limit {

    my ( $mean, $std_dev ) = @_;

    return $mean + ( 3 * $std_dev );

}
