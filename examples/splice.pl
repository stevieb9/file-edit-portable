#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;
use File::Edit::Portable;

my $rw = File::Edit::Portable->new;

my @c = $rw->read(file => 'in.txt');

my $find = 'thre{2}';
my @insert = <DATA>;
chomp for @insert;

$find = qr{$find};

while (my ($i, $e) = each @c){
    if ($e =~ /$find/){
        splice @c, ++$i, 0, @insert;
        last;
    }
}

print Dumper \@c;

__DATA__
testing
    one
    two
    three
