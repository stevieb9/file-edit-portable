#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 31;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

use File::Edit::Portable qw(pread);

my $rw = File::Edit::Portable->new;

my $copy = 't/test.txt';

{
    my @file = pread('t/unix.txt', 1);

    for (@file){
        if (/(\R)/){
            ok ($1 =~ /(?<!\r)\n/, "unix line endings have remained in test");
        }
    }
}
{
    my @file = pread('t/win.txt', 1);

    for (@file){
        if (/(\R)/){
            ok ($1 =~ /\r\n/, "win line endings have remained in test");
        }
    }
}
{
    my $file = 't/unix.txt';

    copy $file, $copy;
    $file = $copy;

    my @file = pread($file);

    for (@file){
        /(\R)/;
        is ($1, undef, "out of testing, EOR is removed");
    }

    my $eor = $rw->recsep($file);

    is ($eor, '\0a', "nix EOR was saved from the orig file");

    eval { unlink $copy or die $!; };
    ok (! $@, "unlinked test file" );

}
{
    my $file = 't/win.txt';

    copy $file, $copy;
    $file = $copy;

    my @file = pread($file);

    for (@file){
        /(\R)/;
        is ($1, undef, "out of testing, EOR is removed");
    }

    my $eor = $rw->recsep($file);;

    is ($eor, '\0d\0a', "win EOR was saved from the orig file");

    eval { unlink $copy or die $!; };
    ok (! $@, "unlinked test file" );

}
