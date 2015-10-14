#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 25;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

use File::Edit::Portable;

# set up the test bed

mkdir 't/a';
mkdir 't/a/b';
mkdir 't/a/b/c';
mkdir 't/a/b/c/d';

my $rw = File::Edit::Portable->new;

{
    _reset();

    my @files = $rw->dir(dir => 't/a', maxdepth => 1, list => 1);
    is (scalar @files, 2, "dir() returns the correct number of files maxdepth() as only param");

    @files = $rw->dir(dir => 't/a', types => [qw(*.txt)], maxdepth => 1, list => 1);
    is (scalar @files, 1, "dir() with types() and maxdepth() returns correct number of files");

    @files = $rw->dir(dir => 't/a', maxdepth => 2, list => 1);
    is (scalar @files, 3, "dir() returns the correct number of files maxdepth() as only param");

    @files = $rw->dir(dir => 't/a', maxdepth => 3, list => 1);
    is (scalar @files, 4, "dir() returns the correct number of files maxdepth() as only param");

    @files = $rw->dir(dir => 't/a', maxdepth => 4, list => 1);
    is (scalar @files, 5, "dir() returns the correct number of files maxdepth() as only param");

}
{
    _reset();

    my @files = $rw->dir(dir => 't/a', types => ['*.txt'], recsep => "\r");

    is (scalar @files, 4, "dir() processes correct files with types param and no maxdepth");

    for (@files){

        my @contents = $rw->read(file => $_);

        if ($contents[0] =~ /(\R)/){
            is($rw->recsep($_), '\0d', 
               "dir() replaces with custom recsep on just specified files"
            );

        }
    }

    @files = $rw->dir(dir => 't/a', types => ['*.none']);

    is (scalar @files, 1, "dir() with types param collects proper files");

}
{
    _reset();

    my @files = $rw->dir(dir => 't/a', types => ['*.txt'], recsep => "\r", maxdepth => 2);

    is (scalar @files, 2, "dir() processes correct files with types and maxdepth set");

    for (@files){

        my @contents = $rw->read(file => $_);

        if ($contents[0] =~ /(\R)/){
            is($rw->recsep($_), '\0d', 
               "dir() replaces with custom recsep on just specified files"
            );

        }
    }

    @files = $rw->dir(dir => 't/a', types => ['*.none']);

    is (scalar @files, 1, "dir() with types param collects proper files");

}

{ # unlink
    my @files = $rw->dir(dir => 't/a', list => 1);
    for (@files){
        next if $_ =~ /^\./;
        eval { unlink $_ or die "can't unlink file $_!: $!"; };
        is ($@, '', "unlinked file $_ ok");
    }

    for ('t/a/b/c/d', 't/a/b/c', 't/a/b', 't/a'){
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


    open my $cfh, '>', 't/a/b/c/c.txt' or die $!;
    print $cfh "one\ntwo\nthree\n";
    close $cfh;

    open my $dfh, '>', 't/a/b/c/d/d.txt' or die $!;
    print $dfh "one\ntwo\nthree\n";
    close $dfh;

    open my $nfh, '>', 't/a/a.none' or die $!;
    print $nfh "one\ntwo\nthree\n";
    close $nfh;
}
