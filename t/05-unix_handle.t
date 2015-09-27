#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;
use Test::More;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

my $rw = File::Edit::Portable->new;

{ 
    if ($^O eq 'MSWin32' || $^O eq 'MacOS'){
        plan skip_all => "We're on Unix";
    }
    else {
        plan tests => 3;
    }

    my $fh = $rw->read(file => 't/win.txt');

    for (<$fh>){
        /(\R)/;

        my $rs = unpack "H*", $1;

        is ($rs, '0a', "handle properly rewrites to local platform recsep");
        last;
    }

    eval { unlink "$$.txt" or die; };

    ok ($@, "temp file was removed ok");
}
