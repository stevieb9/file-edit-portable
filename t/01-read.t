#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 32;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

use File::Edit::Portable;

my $copy = 't/test.txt';

my $rw = File::Edit::Portable->new;

{
    my @file = $rw->read('t/unix.txt', 1);

    for (@file){
        if (/([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/){
            ok ($1 =~ /(?<!\r)\n/, "unix line endings have remained in test");
        }
    }
}
{
    my @file = $rw->read('t/win.txt', 1);

    for (@file){
        if (/([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/){
            ok ($1 =~ /\r\n/, "win line endings have remained in test");
        }
    }
}
{
    my $file = 't/unix.txt';

    copy $file, $copy;
    $file = $copy;

    my @file = $rw->read($file);

    for (@file){
        /([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/;
        is ($1, undef, "out of testing, EOR is removed");
    }

    my $eor = $rw->recsep($file, 'hex');

    is ($eor, '\0a', "nix EOR was saved from the orig file");

    eval { unlink $copy or die $!; };
    ok (! $@, "unlinked test file" );

}
{
    my $file = 't/win.txt';

    copy $file, $copy;
    $file = $copy;

    my @file = $rw->read($file);

    for (@file){
        /([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/;
        is ($1, undef, "out of testing, EOR is removed");
    }

    my $eor = $rw->recsep($file, 'hex');

    is ($eor, '\0d\0a', "win EOR was saved from the orig file");

    eval { unlink $copy or die $!; };
    ok (! $@, "unlinked test file" );
}
{
    my $file = 't/unix.txt';

    my @file = $rw->read(file => $file);

    is (scalar @file, 5, "file hash param still works");
}
