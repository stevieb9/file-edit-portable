#!/usr/bin/perl
use warnings;
use strict;
use feature 'say';

my $file = 't/unix.txt';

open my $fh, '<', $file or die $!;

binmode $fh, ':raw';

my $printed = 0;

for (<$fh>){
    if (! $printed){
        /(\R)/;
        say (unpack "H*", $1);
    }
    $printed++;
    s/\R/xxx/;

    print $_;
}

