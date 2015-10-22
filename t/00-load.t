#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

if ($^O eq 'MSWin32' || $^O eq 'MacOS'){

    print "\nSetting up environment for non-Unix...\n\n";
    
    { # win

        my $file = 't/win.txt';

        open my $fh, '<', $file or die $!;
        binmode $fh, ':raw';

        my @f = <$fh>;
        close $fh or die $!;

        for (@f){
            s/[\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2}/\r\n/g;
        }

        close $fh;

        open my $wfh, '>', $file or die $!;
        binmode $wfh, ':raw';

        for (@f){
            print $wfh $_;
        }

        close $wfh or die $!;

    }

    { # unix

        my $file = 't/unix.txt';

        open my $fh, '<', $file or die $!;
        binmode $fh, ':raw';

        my @f = <$fh>;
        close $fh or die $!;

        for (@f){
            s/[\n\x{0B}\f\r\x{85}]{1,2}|[{utf8}2028-{utf8}2029]]{1,2}/\n/g;
        }

        close $fh;

        open my $wfh, '>', $file or die $!;
        binmode $wfh, ':raw';

        for (@f){
            print $wfh $_;
        }

        close $wfh or die $!;

    }
}

