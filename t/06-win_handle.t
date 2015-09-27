#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;
use Test::More;

#use Test::More tests => 3;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

my $rw = File::Edit::Portable->new;

{ 
    eval "$^O eq 'MSWin32' || die;";
    if ($@){
        plan skip_all => "We're not on Windows";
    }
    else {
        plan tests => 3;
    }

    my $fh = $rw->read(file => 't/unix.txt');

    for (<$fh>){
        /(\R)/;

        my $rs = unpack "H*", $1;

        is ($rs, '0d0a', "handle properly rewrites to local platform recsep");
        last;
    }

    eval { unlink "$$.txt" or die; };

    ok ($@, "temp file was removed ok");
}
