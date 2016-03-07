#!perl
use 5.006;
use strict;
use warnings;

use File::Temp;
use Test::More;
use File::Edit::Portable qw(recsep platform_recsep);

is (exists &recsep, 1, "recsep() is exported ok");
is (exists &platform_recsep, 1, "platform_recsep() is exported ok");

my @files;
{
    @files = File::Edit::Portable->new->dir(dir => 't/base', list => 1);
}

my %h;

for my $f (@files){
    $h{$f} = recsep($f, 'type');
}

is ($h{'t/base/splice.txt'}, platform_recsep('type'), "splice.txt is ok");
is ($h{'t/base/empty.txt'}, platform_recsep('type'), "empty.txt is ok");
is ($h{'t/base/unix.txt'}, 'nix', "unix.txt is ok");
is ($h{'t/base/win.txt'}, 'win', "win.txt is ok");

done_testing();

