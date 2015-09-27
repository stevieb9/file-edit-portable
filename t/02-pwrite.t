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

my $copy = 't/test.txt';

my $rw = File::Edit::Portable->new;

{
    eval { $rw->write; };
    like ($@, qr/file/, "write() croaks if no file is found");

    my @file = $rw->read(file => 't/unix.txt');

    eval { $rw->write; };
    like ($@, qr/contents/, "write() croaks if no contents are passed in");
}
{
    my @file = $rw->read(file => 't/unix.txt');

    for (@file){
        /(\R)/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    $rw->write(copy => $copy, contents => \@file);

    # print "*** " . unpack("H*", $rw->{eor}) . "\n";
    
    my $eor = $rw->recsep($copy);

    is ($eor, '\0a', "unix line endings were replaced properly" );
    
    eval {unlink $copy or die $!;};

    ok (! $@, "copied file unlinked successfully");

}
{
    my @file = $rw->read(file => 't/win.txt');

    for (@file){
        /(\R)/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    $rw->write(copy => $copy, contents => \@file);

    # print "*** " . unpack("H*", $rw->{eor}) . "\n";

    my $eor = $rw->recsep($copy);

    is ($eor, '\0d\0a', "win line endings were replaced properly" );

    eval {unlink $copy;};

    ok (! $@, "unlinked copy successfully");
}
