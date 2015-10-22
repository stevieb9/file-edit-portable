#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;
use Test::More;



if ($^O ne 'MSWin32'){
    plan skip_all => "Windows test but we're not on Windows";
}
else {

    plan tests => 3;
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
    my $rw = File::Edit::Portable->new;

    my $fh = $rw->read('t/unix.txt');

    for (<$fh>){
        /([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/;

        my $rs = unpack "H*", $1;

        is ($rs, '0d0a', "handle properly rewrites to local (Windows) platform recsep");
        last;
    }

    eval { unlink "$$.txt" or die; };

    ok ($@, "temp file was removed ok");
}
