#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;

print "\nUsage: build.pl run_count [debug]\n" if ! $ARGV[0];

my $num = $ARGV[0];
my $debug = $ARGV[1];

if ($^O eq 'MSWin32'){
    win_build($num);
}
else {
    unix_build($num);
}
sub unix_build {

    my $num = shift;

    my $brew_info = `perlbrew available`;

    my @perls_available 
      = $brew_info =~ /(perl-\d\.\d+\.\d+)/g;

    $num = scalar @perls_available if $num eq 'all';

    $brew_info = `perlbrew list`;

    my @perls_installed
      = $brew_info =~ /(perl-\d\.\d+\.\d+)/g;

    if ($debug){
        print "$_\n" for @perls_installed;
    }

    my %perl_vers;

    print "\nremoving previous installs...\n" if $debug;

    for (@perls_installed){
#        `perlbrew uninstall $_`;
    }

    print "\nremoval of existing perl installs complete...\n" if $debug;

    my @new_installs;

    for (1..$num){
        push @new_installs, $perls_available[rand @perls_available];
    }

    for (@new_installs){
        print "\ninstalling $_...\n" if $debug;
#        `perlbrew install --notest -j 4 $_`;
    }

    my $result = `perlbrew exec build/test.pl 2>/dev/null`;
    my @ver_results = split /\n\n\n/, $result;

    my $i = 0;
    my $ver;

    for (@ver_results){
        if (/^(perl-\d\.\d+\.\d+)/){
            $ver = $1;
        }
        my $res;
        if (/Result:\s+(PASS)/){
           $res = $1; 
        }
        else {
            $res = 'FAIL';
        }
        print "$ver :: $res\n";
    }
}

sub win_build {

    my $num = shift;

    if ($ENV{PATH} !~ /berrybrew/){
        warn "\nberrybrew not found on Windows system\n";
        return;
    }

    my $brew_info = `berrybrew available`;

    my @perls_available 
      = $brew_info =~ /(\d\.\d{2}\.\d(?:_\d{2}))(?!=_)/g;

    my @perls_installed
      = $brew_info =~ /(\d\.\d{2}\.\d(?:_\d{2}))(?!=_)\s+\[installed\]/ig;

    my %perl_vers;

    print "\nremoving previous installs...\n" if $debug;

    for (@perls_installed){
#        `berrybrew remove $_`;
    }

    print "\nremoval of existing perl installs complete...\n" if $debug;

    my @new_installs;

    for (1..$num){
        push @new_installs, $perls_available[rand @perls_available];
    }

    for (@new_installs){
        print "\ninstalling $_...\n" if $debug;
#        `berrybrew install $_`;
    }

    print "\nexecuting commands...\n" if $debug;

    my $result = `berrybrew exec perl build\\test.pl`;

    my @ver_results = split /\n\n\n/, $result;

    my $ver;

    for (@ver_results){
        if (/^Perl-(\d\.\d+\.\d+.*)/){
            $ver = $1;
        }
        my $res;
        if (/Result:\s+(PASS)/){
           $res = $1; 
        }
        else {
            $res = 'FAIL';
        }
        print "$ver :: $res\n";
    }
}

