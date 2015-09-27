#!/usr/bin/perl
use warnings;
use strict;

open my $wfh, '>', 'in.txt' or die $!;

print $wfh "x\n";

close $wfh;

open my $fh, '<', 'in.txt' or die $!;

binmode $fh, ':raw';

for (<$fh>){
    if (/(\R)/){
        print (unpack "H*", $1);
    }
}

