#!perl
use 5.006;
use strict;
use warnings;

use Test::More;

use Test::More tests => 3;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

my $rw = File::Edit::Portable->new;

my $one = $rw->recsep('t/win.txt', 'hex');
is ($one, '\0d\0a', "recsep is correct for win");

my $two = $rw->recsep('t/unix.txt', 'hex');
is ($two, '\0a', "recsep is correct for nix");
