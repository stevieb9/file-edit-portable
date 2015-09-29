#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;
use File::Edit::Portable;

my $hash;

$hash->{rw} = File::Edit::Portable->new;

$hash->{rw}->read(file => 'TODO');
