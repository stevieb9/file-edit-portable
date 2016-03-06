#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Spec::Functions;
use File::Tempdir;
use File::Copy;
use Test::More;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

my $rw = File::Edit::Portable->new;

my $tempdir = File::Tempdir->new;
my $tdir = $tempdir->name;
my $bdir = 't/base';

my $unix = catfile($bdir, 'unix.txt');
my $win = catfile($bdir, 'win.txt');

my $win_cp = catfile($tdir, 'win.bak');
my $unix_cp = catfile($tdir, 'unix.bak');

{
    my $rw = File::Edit::Portable->new;

    my @win = $rw->read($win);
    $rw->write(copy => $win_cp, contents => \@win);

    my $recsep = $rw->recsep($win_cp, 'hex');

    is ($recsep, '\0d\0a', "with only one read(), recsep is written properly");
}
{
    my $rw = File::Edit::Portable->new;

    my @win = $rw->read($win);
    my @nix = $rw->read($unix);

    $rw->write(copy => $unix_cp, contents => \@nix);

    my $recsep = $rw->recsep($unix_cp, 'hex');

    is ($recsep, '\0a', "with two read(), recsep is written properly");
}

done_testing();