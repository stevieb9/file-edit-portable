#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;
use Devel::Examine::Subs;

my $ver = $ARGV[0];

print "\nneed a version number as arg\n" if ! $ver;

#my $str = "our \$VERSION = '1.47'";
#$str =~ s/(our \$VERSION =).*/$1 '$ver';/;

my $des = Devel::Examine::Subs->new(
    file => 'lib/File/Edit',
    extensions => ['*.pm'],
);

my $cref = sub { $_[0] =~ s/(our \$VERSION =).*/$1 '$ver';/; };

my $ret = $des->replace(exec => $cref, limit => 1);

print Dumper $ret;
