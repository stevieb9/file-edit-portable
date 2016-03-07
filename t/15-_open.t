#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

use File::Edit::Portable;

my $rw = File::Edit::Portable->new;

{
    eval {
        my @file = $rw->_open('xxx');
    };

    like ($@, qr/_open\(\) can't/, "coverage for open bad file");

}

done_testing();
