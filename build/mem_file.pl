#!/usr/bin/perl
use warnings;
use strict;

my $memfile;
my $fh;

$fh = _open(\$memfile);
close $fh;

$fh = _open('lib/File/Edit/Portable.pm');
close $fh;

sub _open {
    my $file = shift;
    my $mode = shift;

    my $fh;

    if ($mode && $mode =~ /^w/){
        open $fh, '>', $file or die $!;
    }
    else { 
        open $fh, '<', $file or die $!;
    }

    if (fileno($fh) == -1){
        print "is memory file\n";
    }
    else {
        print "is real file\n";
    }
    return $fh;
}
