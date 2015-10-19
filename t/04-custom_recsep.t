#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;
use Test::More;

use Test::More tests => 18;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

my $copy = 't/test.txt';

my $rw = File::Edit::Portable->new;

{
    my @file = $rw->read('t/unix.txt');

    for (@file){
        /(\R)/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    $rw->write(recsep => "\r\n", copy => $copy, contents => \@file);

    # print "*** " . unpack("H*", $rw->{eor}) . "\n";
    
    my $recsep = $rw->recsep($copy);

    is ($recsep, '\0d\0a', "custom recsep takes precedence" );
    
    eval {unlink $copy or die $!;};

    ok (! $@, "unlinked copied file successfully");

}
{
    my @file = $rw->read('t/win.txt');

    for (@file){
        /(\R)/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    $rw->write(recsep => "\n", copy => $copy, contents => \@file);

    # print "*** " . unpack("H*", $rw->{eor}) . "\n";

    my $recsep = $rw->recsep($copy);

    is ($recsep, '\0a', "on windows file, custom recsep took precedence" );

    eval {unlink $copy or die $!;};

    ok (! $@, "unlinked copy successfully");
}
