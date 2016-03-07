#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use Test::More;
use File::Edit::Portable qw(recsep platform_recsep);

is (exists &recsep, 1, "recsep() is exported ok");
is (exists &platform_recsep, 1, "platform_recsep() is exported ok");

my @files;
{
    @files = File::Edit::Portable->new->dir(dir => 't/base', list => 1);
}

my %map;

for my $f (@files){
    $map{$f} = recsep($f, 'type');
}

print Dumper \%map;

done_testing();

