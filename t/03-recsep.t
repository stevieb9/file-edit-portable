#!perl
use 5.006;
use strict;
use warnings;

use File::Spec::Functions;
use Test::More;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

my $bdir = 't/base';
my $unix = catfile($bdir, 'unix.txt');
my $win = catfile($bdir, 'win.txt');

my $rw = File::Edit::Portable->new;

my $one = $rw->recsep($win, 'hex');
is ($one, '\0d\0a', "recsep is correct for win");

my $two = $rw->recsep($unix, 'hex');
is ($two, '\0a', "recsep is correct for nix");

my $three = $rw->recsep('xxx', 'hex');
my $pr = $rw->platform_recsep('hex');

is ($three, $pr, "coverage for bad file");

my $four = $rw->recsep('xxx');

is ($four, $rw->platform_recsep, "coverage for no hex param");

my $five = $rw->recsep('xxx');

is ($five, $rw->platform_recsep, "coverage for empty file");

done_testing();
