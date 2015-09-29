#!perl
use 5.006;
use strict;
use warnings;

use Test::More;

plan tests => 2;

use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";

my @data = File::Edit::Portable->new->read(file => 't/unix.txt');

is (ref \@data, 'ARRAY', "chained calls through new return array");


