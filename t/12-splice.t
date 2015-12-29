#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 97;

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
    is(@ret, 13, "splice() retains the correct number of lines with line param");

    my @new = $rw->read($copy);

    is($new[0], 'testing', "splice() at line 0 writes the file correctly");
    is(@new, @ret, "splice() writes the correct number of lines in the file");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
} 
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        line => 4,
        insert => \@insert,
    );

    is($ret[4], 'testing', "splice() at line 4 does the right thing");
    is(@ret, 13, "splice() retains the correct number of lines with line param");

    my @new = $rw->read($copy);

    is($new[4], 'testing', "splice() at line 4 writes the file correctly");
    is(@new, @ret, "splice() writes the correct number of lines in the file");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
} 
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'one',
        insert => \@insert,
    );

    is($ret[1], 'testing', "splice() with find works");
    is(@ret, 13, "splice() retains the correct number of lines with line param");

    my @new = $rw->read($copy);

    is($new[1], 'testing', "splice() with find writes the file correctly");
    is(@new, @ret, "splice() with find writes the file properly");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
} 
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'four',
        insert => \@insert,
    );

    is($ret[4], 'testing', "splice() with find works");
    is(@ret, 13, "splice() retains the correct number of lines with line param");

    my @new = $rw->read($copy);

    is($new[4], 'testing', "splice() with find writes the file correctly");
    is(@new, @ret, "splice() with find writes the file properly");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
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

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
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
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'one',
        insert => \@insert,
        limit => 2,
    );

    is($ret[1], 'testing', "splice() with find and limit works");
    is($ret[8], 'testing', "splice() with find and limit works");
    is(@ret, 14, "splice() retains the correct number of lines w/ limit param");

    my @new = $rw->read($copy);

    is($new[1], 'testing', "splice() with find writes the file correctly");
    is($new[8], 'testing', "splice() with limit = 2 works");
    is(@new, @ret, "splice() with find writes the file properly");

    my $count = grep {$_ eq 'testing'} @ret;

    is($count, 2, "limit set to 2 does the right thing");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
} 
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'one',
        insert => \@insert,
        limit => 4,
    );

    is($ret[1], 'testing', "splice() with find works");
    is($ret[8], 'testing', "splice() with find works");
    is($ret[11], 'testing', "splice() with find works");
    is($ret[14], 'testing', "splice() with find works");
    is(@ret, 16, "splice() retains the correct number of lines w/ limit param");

    my @new = $rw->read($copy);

    is($new[1], 'testing', "splice() with find writes the file correctly");
    is($new[8], 'testing', "splice() with limit = 4 works");
    is($new[11], 'testing', "splice() with limit = 4 works");
    is($new[14], 'testing', "splice() with limit = 4 works");
    is(@new, @ret, "splice() with find writes the file properly");

    my $count = grep {$_ eq 'testing'} @ret;

    is($count, 4, "limit set to 4 does the right thing");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
} 
{
    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'one',
        insert => \@insert,
        limit => 0,
    );

    is($ret[1], 'testing', "splice() with find works");
    is($ret[8], 'testing', "splice() with find works");
    is($ret[11], 'testing', "splice() with find works");
    is($ret[14], 'testing', "splice() with find works");
    is(@ret, 16, "splice() retains the correct number of lines w/ limit param");

    my @new = $rw->read($copy);

    is($new[1], 'testing', "splice() with find writes the file correctly");
    is($new[8], 'testing', "splice() with limit = 4 works");
    is($new[11], 'testing', "splice() with limit = 4 works");
    is($new[14], 'testing', "splice() with limit = 4 works");
    is(@new, @ret, "splice() with find writes the file properly");

    my $count = grep {$_ eq 'testing'} @ret;

    is($count, 4, "limit set to 4 does the right thing");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
} 
{
    my @code = ('testing', 'more testing');

    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'one',
        insert => \@code,
    );

    is($ret[1], 'testing', "splice() with find works");
    is(@ret, 14, "splice() retains the correct number of lines with find param");

    my @new = $rw->read($copy);

    is($new[1], 'testing', "splice() with find writes the file correctly");
    is($new[2], 'more testing', "splice() with find writes the file correctly");
    is(@new, @ret, "splice() with find writes the file properly");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
} 
{
    my @code = ('testing', 'more testing');

    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'one',
        limit => 2,
        insert => \@code,
    );

    is($ret[1], 'testing', "splice() with find works");
    is($ret[2], 'more testing', "splice() multi-line with limit = 2 works");
    is($ret[9], 'testing', "splice() multi-line with limit = 2 works");
    is($ret[10], 'more testing', "splice() multi-line with limit = 2 works");
    is(@ret, 16, "splice() retains the correct number of lines with find param");

    my @new = $rw->read($copy);

    is($new[1], 'testing', "splice() with find writes the file correctly");
    is($new[2], 'more testing', "splice() with find writes the file correctly");
    is($new[9], 'testing', "splice() with find writes the file correctly");
    is($new[10], 'more testing', "splice() with find writes the file correctly");
    is(@new, @ret, "splice() with find writes the file properly");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
} 
{
    my @code = ('testing', 'more testing');

    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'one',
        limit => 4,
        insert => \@code,
    );

    is($ret[1], 'testing', "splice() with find works");
    is($ret[2], 'more testing', "splice() multi-line with limit = 2 works");
    is($ret[9], 'testing', "splice() multi-line with limit = 2 works");
    is($ret[10], 'more testing', "splice() multi-line with limit = 2 works");
    is($ret[13], 'testing', "splice() with find works");
    is($ret[14], 'more testing', "splice() multi-line with limit = 2 works");
    is($ret[17], 'testing', "splice() multi-line with limit = 2 works");
    is($ret[18], 'more testing', "splice() multi-line with limit = 2 works");

    is(@ret, 20, "splice() retains the correct number of lines with find param");

    my @new = $rw->read($copy);

    is($new[1], 'testing', "splice() with find writes the file correctly");
    is($new[2], 'more testing', "splice() with find writes the file correctly");
    is($new[9], 'testing', "splice() with find writes the file correctly");
    is($new[10], 'more testing', "splice() with find writes the file correctly");
    is($new[13], 'testing', "splice() with find writes the file correctly");
    is($new[14], 'more testing', "splice() with find writes the file correctly");
    is($new[17], 'testing', "splice() with find writes the file correctly");
    is($new[18], 'more testing', "splice() with find writes the file correctly");

    is(@new, @ret, "splice() with find writes the file properly");

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
} 
{
    my @warnings;

    local $SIG{__WARN__} = sub {
        push @warnings, @_;
    };

    my @code = ('testing', 'more testing');

    my @ret = $rw->splice(
        file => $file,
        copy => $copy,
        find => 'one',
        line => 5,
        insert => \@code,
    );

    is(@warnings, 1, "splice() with find and line params warns");
    is($ret[5], 'testing', "splice() with both line and find params does line");
    is($ret[6], 'more testing', "splice() with both line and find params does line");

    my @new = $rw->read($copy);

    eval { unlink $copy or die $!; };
    is ($@, '', "copy file $copy unlinked successfully");
}
__DATA__
testing
