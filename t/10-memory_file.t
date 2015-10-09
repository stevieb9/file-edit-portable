#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 2;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

use File::Edit::Portable qw(read);

{
    my $fh = read('t/unix.txt');
    is(fileno($fh), -1, "handle returned by read is a memory file");
}
