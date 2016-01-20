#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use Fcntl qw(:flock);
use File::Copy;
use File::Edit::Portable;
use File::Spec::Functions;
use File::Tempdir;
use Mock::Sub;
use Test::More;

my $tempdir = File::Tempdir->new;
my $tdir = $tempdir->name;
my $bdir = 't/base';

my $unix = catfile($bdir, 'unix.txt');
my $win = catfile($bdir, 'win.txt');
my $copy = catfile($tdir, 'test.txt');

my $rw = File::Edit::Portable->new;
{
    eval { $rw->write; };
    like ($@, qr/file/, "write() croaks if no file is found");

    my @file = $rw->read($unix);

    eval { $rw->write; };
    like ($@, qr/contents/, "write() croaks if no contents are passed in");
}
{
    my @file = $rw->read($unix);

    for (@file){
        /([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    $rw->write(copy => $copy, contents => \@file);

    my $eor = $rw->recsep($copy, 'hex');

    is ($eor, '\0a', "unix line endings were replaced properly" );
}
{
    my @file = $rw->read($win);

    for (@file){
        /([\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2})/;
        is ($1, undef, "no EOLs present after read");
    }

    for (qw(a b c d e)){
        push @file, $_;
    }

    $rw->write(copy => $copy, contents => \@file);

    my $eor = $rw->recsep($copy, 'hex');

    is ($eor, '\0d\0a', "win line endings were replaced properly" );
}
{

    my $file = $unix;
    my $copy = catfile($tdir, 'write_fh.txt');

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
}
{

    my $mock = Mock::Sub->new;
    my $recsep_sub = $mock->mock('File::Edit::Portable::recsep', return_value => 1);

    my $file = $unix;
    my $copy = catfile($tdir, 'write_fh.txt');

    my $fh = $rw->read($file);
    
    $rw->{is_read} = 0;
    $rw->write(copy => $copy, contents => $fh);
 
    is($recsep_sub->called_count, 3, "recsep() is called if ! is_read");
}
{
    $ENV{TEST_WRITE_LOCK} = 1;

    my @file = $rw->read($unix);

    writing($rw, \@file);

    sleep 1;

    open my $fh, '<', $copy or die $!;

    eval { flock($fh, LOCK_EX|LOCK_NB) or die "can't lock write file"; 1; };

    like ($@, qr/can't lock write file/, "when writing, file is locked ok");

}

sleep 1; # because we need to wait for the fork() to finish

done_testing();

sub writing {
    my ($rw, $contents) = @_;
    my $pid = fork;

    return if $pid;

    $rw->write(copy => $copy, contents => $contents);

    exit 0;
}
