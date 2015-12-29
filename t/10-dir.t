#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 24;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

use File::Edit::Portable;

# set up the test bed

mkdir 't/a';
mkdir 't/a/b';


my $rw = File::Edit::Portable->new;

{
    _reset();

    my @files = $rw->dir(dir => 't/a', list => 1);
    is (scalar @files, 3, "dir() returns the correct number of files w/no params");

    @files = $rw->dir(dir => 't/a', types => [qw(*.txt)], list => 1);
    is (scalar @files, 2, "dir() with types() returns correct number of files");
}
{
    _reset();

    my @files = $rw->dir(dir => 't/a', types => ['*.txt'], recsep => "\r");

    is (scalar @files, 2, "dir() processes correct files with types param");

    for (@files){

        my @contents = $rw->read($_);

        if ($contents[0] =~ /([\n\x{0B}\f\r\x{85}]{1,2})/){
            is($rw->recsep($_, 'hex'), '\0d', 
               "dir() replaces with custom recsep on just specified files"
            );

        }
    }

    @files = $rw->dir(dir => 't/a', types => ['*.none']);

    is (scalar @files, 1, "dir() with types param collects proper files");

}
{
    _reset();

    my @files = $rw->dir(dir => 't/a', recsep => "\r");


    for (@files){
        is($rw->recsep($_, 'hex'), '\0d', 
           "dir() - files modified to macos recsep");
    }
    @files = $rw->dir(dir => 't/a');

    for (@files){
        my $rec = $rw->recsep($_, 'hex');
        my $prec = unpack("H*", $rw->platform_recsep);
        $prec =~ s/0/\\0/g;       

        ok ($rec eq $prec, "dir() properly sets all files to platform recsep");
    }
}
{
    _reset();

    my @files = $rw->dir(dir => 't/a', recsep => "\r\n");

    for (@files){
        is($rw->recsep($_, 'hex'), '\0d\0a',
           "dir() - test files were modified to win32 recsep");
    }

    @files = $rw->dir(dir => 't/a');

    for (@files){
        my $rec = $rw->recsep($_, 'hex');
        my $prec = unpack("H*", $rw->platform_recsep);
        $prec =~ s/0/\\0/g;       

        ok ($rec eq $prec, "dir() properly sets all files back to platform recsep");
    }
}

{ # unlink
    my @files = $rw->dir(dir => 't/a', list => 1);
    for (@files){
        next if $_ =~ /^\./;
        eval { unlink $_ or die "can't unlink file $_!: $!"; };
        is ($@, '', "unlinked file $_ ok");
    }

    for ('t/a/b', 't/a'){
        eval { rmdir $_ or die "can't remove dir()'s test dir $_"; };
        is ($@, '', "removed dir()'s temp directories");
    }
}
sub _reset {

    open my $afh, '>', 't/a/a.txt' or die $!;
    print $afh "one\ntwo\nthree\n";
    close $afh;

    open my $bfh, '>', 't/a/b/b.txt' or die $!;
    print $bfh "one\ntwo\nthree\n";
    close $bfh;

    open my $cfh, '>', 't/a/a.none' or die $!;
    print $cfh "one\ntwo\nthree\n";
    close $cfh;
}
