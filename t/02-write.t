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

{
    my $rw = File::Edit::Portable->new;

    eval { $rw->write; };
    like ($@, qr/file/, "write() croaks if no file is found");

    my @file = $rw->read($unix);

    eval { $rw->write; };
    like ($@, qr/contents/, "write() croaks if no contents are passed in");
}
{
    my $rw = File::Edit::Portable->new;

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
    my $rw = File::Edit::Portable->new;

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
    my $rw = File::Edit::Portable->new;

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
    my $rw = File::Edit::Portable->new;

    my $mock = Mock::Sub->new;
    my $recsep_sub = $mock->mock('File::Edit::Portable::recsep', return_value => 1);

    my $file = $unix;
    my $copy = catfile($tdir, 'write_fh.txt');

    my $fh = $rw->read($file);
    
    $rw->{is_read} = 0;

    # we need to set this manually because of the mock, or else warnings will
    # be emitted for uninit

    $rw->{recsep} = 'blah';
    $rw->write(copy => $copy, contents => $fh);
 
    is($recsep_sub->called_count, 3, "recsep() is called if ! is_read");
}
SKIP: {

    skip "win32 test, but not on windows", 1 unless $^O eq 'MSWin32';

    my $rw = File::Edit::Portable->new;

    my $fh = $rw->read($unix);

    $rw->write(copy => $copy, contents => $fh, recsep => $rw->platform_recsep);

    my $eor = $rw->recsep($copy, 'hex');

    is ($eor, '\0d\0a', "platform_recsep() w/ no parameters can be used as custom recsep" );
};
SKIP: {

    skip "nix test but we're not on unix", 1 unless $^O ne 'MSWin32';

    my $rw = File::Edit::Portable->new;

    my $fh = $rw->read($unix);

    $rw->write(copy => $copy, contents => $fh, recsep => $rw->platform_recsep);

    my $eor = $rw->recsep($copy, 'hex');

    is ($eor, '\0a', "platform_recsep() w/ no parameters can be used as custom recsep" );
};
{
    my $rw = File::Edit::Portable->new;

    my @orig_contents = $rw->read($unix);
    {

        my $fh = $rw->read($unix);
        $rw->write(copy => $copy, contents => $fh);
        close $fh;

        my @copy_contents = $rw->read($copy);

        is (
            @orig_contents,
            @copy_contents,
            "file length equal when rewriting with different recsep (unix)",
        );

        my $orig_eof = $rw->recsep($unix, 'hex');
        my $copy_eof = $rw->recsep($copy, 'hex');

        is ($orig_eof, $copy_eof, "orig and copy have same eof (unix)");
    }
}
{
    my $rw = File::Edit::Portable->new;
    my @orig_contents = $rw->read($win);

    my $fh = $rw->read($win);
    $rw->write(copy => $copy, contents => $fh);
    close $fh;

    my @copy_contents = $rw->read($copy);

    is (
        @orig_contents,
        @copy_contents,
        "file length equal when rewriting with different recsep (win)",
    );

    my $orig_eof = $rw->recsep($win, 'hex');
    my $copy_eof = $rw->recsep($copy, 'hex');

    is ($orig_eof, $copy_eof, "orig and copy have same eof (win)");
};
{
    my $rw = File::Edit::Portable->new;
    my $fh = $rw->read($unix);
    $rw->write(copy => $copy, contents => $fh, recsep => "\r\n");
    close $fh;

    my $orig_eof = $rw->recsep($unix, 'hex');
    my $copy_eof = $rw->recsep($copy, 'hex');

    ok ($orig_eof ne $copy_eof, "orig and copy differ w/ recsep (unix)");

    my @orig = $rw->read($unix);
    my @copy = $rw->read($copy);

    is (@orig, @copy,
        "files contain the same num of lines with recsep (unix)");
}
{
    my $rw = File::Edit::Portable->new;
    my $fh = $rw->read($win);
    $rw->write(copy => $copy, contents => $fh, recsep => "\n");
    close $fh;

    my $orig_eof = $rw->recsep($win, 'hex');
    my $copy_eof = $rw->recsep($copy, 'hex');

    ok ($orig_eof ne $copy_eof, "orig and copy differ w/ recsep (win)");

    my @orig = $rw->read($win);
    my @copy = $rw->read($copy);

    is (@orig, @copy,
        "files contain the same num of lines with recsep (win)");
}
{
    my $rw = File::Edit::Portable->new;
    my $file = $unix;
    my $copy = catfile($tdir, 'write_bug_19.txt');

    my $fh = $rw->read($file);
    delete $rw->{file};
    eval { $rw->write(copy => $copy, contents => $fh); };

    like ($@, qr/\Qwrite() requires a file\E/, "write() croaks if not handed a file");

    $rw->{file} = $file;
    $rw->write(copy => $copy, contents => $fh, recsep => "\r");

    $fh = $rw->read($file);
    $rw->{is_read} = 0;
    $rw->write(copy => $copy, contents => $fh);

    is ($rw->recsep($copy, 'hex'), '\0a', "write() without is_read has the right recsep");

}
{
    my $rw = File::Edit::Portable->new;

    my $fh = $rw->read($win);
    my $fh2 = $rw->read($unix);

    eval { $rw->write(copy => $copy, contents => $fh); };

    like (
        $@,
        qr/\Qif calling write() with more than one read()/,
        "write() barfs if called without a file and multiple read()s open"
    );

    eval { $rw->write(file => $unix, copy => $copy, contents => $fh); };
    is ($@, '', "...but works if a file is sent in");

}
{
    my $warn;
    local $SIG{__WARN__} = sub { $warn = shift; };

    my $rw = File::Edit::Portable->new;

    my $fh = $rw->read($win);
    $rw->write(copy => $copy, contents => $fh);

    <$fh>;
    like ($warn, qr/\Qreadline() on closed\E/, "write() closes a contents \$fh");
}
done_testing();

