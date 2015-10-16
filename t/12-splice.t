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

my $rw = File::Edit::Portable->new;

my $file = 't/splice.txt';
my $copy = 't/splice.bak';
my @insert = <DATA>;

{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        line => 0,
        insert => \@insert,
    );

    is($ret[0], 'testing', "splice() at line 0 does the right thing");
    is(@ret, 7, "splice() retains the correct number of lines with line param");

    my @new = $rw->read(file => $copy);

    is($new[0], 'testing', "splice() at line 0 writes the file correctly");
    is(@new, @ret, "splice() writes the correct number of lines in the file");

} 
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        line => 4,
        insert => \@insert,
    );

    is($ret[4], 'testing', "splice() at line 4 does the right thing");
    is(@ret, 7, "splice() retains the correct number of lines with line param");

    my @new = $rw->read(file => $copy);

    is($new[4], 'testing', "splice() at line 4 writes the file correctly");
    is(@new, @ret, "splice() writes the correct number of lines in the file");

} 
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'one',
        insert => \@insert,
    );

    is($ret[1], 'testing', "splice() with find works");
    is(@ret, 7, "splice() retains the correct number of lines with line param");

    my @new = $rw->read(file => $copy);

    is($new[1], 'testing', "splice() with find writes the file correctly");
    is(@new, @ret, "splice() with find writes the file properly");
} 
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'four',
        insert => \@insert,
    );

    is($ret[4], 'testing', "splice() with find works");
    is(@ret, 7, "splice() retains the correct number of lines with line param");

    my @new = $rw->read(file => $copy);

    is($new[4], 'testing', "splice() with find writes the file correctly");
    is(@new, @ret, "splice() with find writes the file properly");
} 
{
    eval {
        my @ret = $rw->splice(
            file => $file,
            copy => $copy,
            #find => 'four',
            #insert => \@insert,
        );
    };

    like($@, qr/splice()/, "splice() croaks if find or insert params aren't sent in");
} 
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'four',
        insert => \@insert,
    );
    
    is(ref(\@ret), 'ARRAY', "splice() returns an array");
} 
{
    eval {
        my @ret = $rw->splice(
            file => '',
            copy => $copy,
            find => 'four',
            insert => \@insert,
        );
    };

    like($@, qr/read()/, "splice() croaks if a file isn't sent in");
} 

__DATA__
testing
