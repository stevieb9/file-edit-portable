#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 20;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

use File::Edit::Portable qw(pread pwrite);

my $rw = File::Edit::Portable->new;

{
    eval { pwrite(); };
    like ($@, qr/file/, "write() croaks if no file is found");

    eval { pwrite('t/xxx.txt'); };
    like ($@, qr/contents/, "write() croaks if no contents are passed in");
}
{
    my @file = pread('t/unix.txt');

    for (@file){
        /(\R)/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    pwrite('t/unix.txt', \@file, 't/unix.txt.new');

    my $eor = $rw->recsep('t/unix.txt.new');

    is ($eor, '\0a', "unix line endings were replaced properly" );
    
    eval {unlink 't/unix.txt.new' or die $!;};

    ok (! $@, "copied file unlinked successfully");

}
{
    my @file = pread('t/win.txt');

    for (@file){
        /(\R)/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    pwrite('t/win.txt', \@file, 't/win.txt.new');

    my $eor = $rw->recsep('t/win.txt.new');

    is ($eor, '\0d\0a', "win line endings were replaced properly" );

    eval {unlink 't/win.txt.new';};

    ok (! $@, "unlinked copy successfully");
}
