#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 26;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

use File::Edit::Portable;

my $copy = 't/test.txt';

my $rw = File::Edit::Portable->new;

{
    eval { $rw->write; };
    like ($@, qr/file/, "write() croaks if no file is found");

    my @file = $rw->read('t/unix.txt');

    eval { $rw->write; };
    like ($@, qr/contents/, "write() croaks if no contents are passed in");
}
{
    my @file = $rw->read('t/unix.txt');

    for (@file){
        /([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    $rw->write(copy => $copy, contents => \@file);

    # print "*** " . unpack("H*", $rw->{eor}) . "\n";
    
    my $eor = $rw->recsep($copy, 'hex');

    is ($eor, '\0a', "unix line endings were replaced properly" );
    
    eval {unlink $copy or die $!;};

    ok (! $@, "copied file unlinked successfully");

}
{
    my @file = $rw->read('t/win.txt');

    for (@file){
        /([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    $rw->write(copy => $copy, contents => \@file);

    # print "*** " . unpack("H*", $rw->{eor}) . "\n";

    my $eor = $rw->recsep($copy, 'hex');

    is ($eor, '\0d\0a', "win line endings were replaced properly" );

    eval {unlink $copy;};

    ok (! $@, "unlinked copy successfully");
}
{

    my $file = 't/unix.txt';
    my $copy = 't/write_fh.txt';

    my $fh = $rw->read($file);
    my @read_contents = $rw->read($file);

    $rw->write(copy => $copy, contents => $fh);

    my @write_contents = $rw->read($copy);

    my $i = 0;
    for (@read_contents){
        chomp;
        is($write_contents[$i], $_, "written line is ok when write() takes a file handle as contents");
        $i++;
    }

    eval { unlink $copy or die "can't unlink copy $copy"; };
    is ($@, '', "unlinked $copy ok");
} 
