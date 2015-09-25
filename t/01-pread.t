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

my $copy = 't/test.txt';

my $rw = File::Edit::Portable->new;

{
    my @file = $rw->pread(testing => 1, file => 't/unix.txt');

    for (@file){
        if (/(\R)/){
            ok ($1 =~ /(?<!\r)\n/, "unix line endings have remained in test");
        }
    }
}
{
    my @file = $rw->pread(testing => 1, file => 't/win.txt');

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

    my @file = $rw->pread(file => $file);

    for (@file){
        /(\R)/;
        is ($1, undef, "out of testing, EOR is removed");
    }

    eval { unlink $copy or die $!; };
    ok (! $@, "unlinked test file" );

    my $eor = unpack "H*", $rw->{eor};

    is ($eor, '0a', "nix EOR was saved from the orig file");
}
{
    my $file = 't/win.txt';

    copy $file, $copy;
    $file = $copy;

    my @file = $rw->pread(file => $file);

    for (@file){
        /(\R)/;
        is ($1, undef, "out of testing, EOR is removed");
    }

    eval { unlink $copy or die $!; };
    ok (! $@, "unlinked test file" );

    my $eor = unpack "H*", $rw->{eor};

    is ($eor, '0d0a', "win EOR was saved from the orig file");
}
