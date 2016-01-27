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
SKIP: {

    skip "win32 test, but not on windows", 1 unless $^O eq 'MSWin32';

    my $fh = $rw->read($unix);

    $rw->write(copy => $copy, contents => $fh, recsep => $rw->platform_recsep);

    my $eor = $rw->recsep($copy, 'hex');

    is ($eor, '\0d\0a', "platform_recsep() w/ no parameters can be used as custom recsep" );
};
SKIP: {

    skip "nix test but we're not on unix", 1 unless $^O ne 'MSWin32';

    my $fh = $rw->read($unix);

    $rw->write(copy => $copy, contents => $fh, recsep => $rw->platform_recsep);

    my $eor = $rw->recsep($copy, 'hex');

    is ($eor, '\0a', "platform_recsep() w/ no parameters can be used as custom recsep" );
};
{

    my @orig_contents = $rw->read($unix);

    my $fh = $rw->read($unix);
    $rw->write(copy => $copy, contents => $fh);
    close $fh;

    my @copy_contents = $rw->read($copy);

    is (
        @orig_contents,
        @copy_contents,
        "file length equal when rewriting with different recsep (unix)",
    );

    @orig_contents= $rw->read($win);

    $fh = $rw->read($win);
    $rw->write(copy => $copy, contents => $fh);
    close $fh;

    @copy_contents = $rw->read($copy);

    is (
        @orig_contents,
        @copy_contents,
        "file length equal when rewriting with different recsep (win)",
    );

    copy $copy, 't/bad.txt';
};
done_testing();

