#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 17;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

my $copy = 't/test.txt';

my $rw = File::Edit::Portable->new;

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
    
    unlink $copy or die $!;

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
