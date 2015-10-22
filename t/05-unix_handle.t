#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;
use Test::More;



if ($^O eq 'MSWin32' || $^O eq 'MacOS'){
    plan skip_all => "Unix test, but we're not on Unix";
}
else {

    plan tests => 3;
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
    my $rw = File::Edit::Portable->new;

    my $fh = $rw->read('t/win.txt');

    for (<$fh>){
        /([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/;

        my $rs = unpack "H*", $1;

        is ($rs, '0a', "handle properly rewrites to local platform (Unix) recsep");
        last;
    }

    eval { unlink "$$.txt" or die; };

    ok ($@, "temp file was removed ok");
}
