#!perl
use 5.006;
use strict;
use warnings;

use Test::More tests => 6;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}


my $rw = File::Edit::Portable->new;

my $one = $rw->recsep('t/win.txt', 'hex');
is ($one, '\0d\0a', "recsep is correct for win");

my $two = $rw->recsep('t/unix.txt', 'hex');
is ($two, '\0a', "recsep is correct for nix");

my $three = $rw->recsep('xxx', 'hex');
my $pr = $rw->platform_recsep('hex');

is ($three, $pr, "coverage for bad file");

my $four = $rw->recsep('xxx');

is ($four, $rw->platform_recsep, "coverage for no hex param");

my $five = $rw->recsep('xxx');

is ($five, $rw->platform_recsep, "coverage for empty file");
