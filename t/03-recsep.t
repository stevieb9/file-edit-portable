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

{
    my $x = $rw->recsep($win, 'hex');
    my $y = $rw->recsep($win, 'os');
    is ($x, '\0d\0a', "hex recsep is correct for win");
    is ($y, 'win', "os recsep is correct for win");
}
{
    my $x = $rw->recsep($unix, 'hex');
    my $y = $rw->recsep($unix, 'os');
    is ($x, '\0a', "hex recsep is correct for unix");
    is ($y, 'nix', "os recsep is correct for unix");
}
{
    my $x = $rw->recsep( 'xxx', 'hex' );
    my $p = $rw->platform_recsep('hex');
    is ( $x, $p, "hex recsep is set to platform for bad file" );
}
{
    my $x = $rw->recsep( 'xxx', 'os' );
    my $p = $rw->platform_recsep('os');
    is ( $x, $p, "os recsep is set to platform for bad file" );
}
{
    my $x = $rw->recsep('xxx');
    my $p = $rw->platform_recsep;
    is ( $x, $p, "string recsep is set to platform for bad file" );
}
{
    my @os = qw(win mac nix);

    for ("\r\n", "\r", "\n"){

        my $fname = $rw->_temp_filename;
        $rw->write(file => $fname, contents => [qw(abc)], recsep => $_);

        my $os = $rw->recsep($fname, 'os');
        my @m = grep /^$os$/, @os;
        my $os_name = shift @os;

        is ($m[0], $os_name, "$m[0] recsep matches os");
    }
}

done_testing();
