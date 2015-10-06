#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 33;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

use File::Edit::Portable qw(read write);

my $copy = 't/test.txt';

my $rw = File::Edit::Portable->new;

{
    my @file = $rw->read(testing => 1, file => 't/unix.txt');

    for (@file){
        if (/(\R)/){
            ok ($1 =~ /(?<!\r)\n/, "unix line endings have remained in test");
        }
    }
}
{
    my @file = $rw->read(testing => 1, file => 't/win.txt');

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

    my @file = $rw->read(file => $file);

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

    my @file = $rw->read(file => $file);

    for (@file){
        /(\R)/;
        is ($1, undef, "out of testing, EOR is removed");
    }

    my $eor = $rw->recsep($file);;

    is ($eor, '\0d\0a', "win EOR was saved from the orig file");

    eval { unlink $copy or die $!; };
    ok (! $@, "unlinked test file" );

}
{
    my $file = 't/unix.txt';

    my $fh = read($file);

    is (ref($fh), 'GLOB', "read() function returns a handle in scalar context");

    my @contents = read($file);

    is (ref(\@contents), 'ARRAY', "read() function returns an array in list context");
}
