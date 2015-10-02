#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;

print "\nUsage: build.pl run_count\n" if ! $ARGV[0];

my $num = $ARGV[0];

if ($^O eq 'MSWin32'){
    win_build($num);
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

    print "\nremoving previous installs...\n";

    for (@perls_installed){
        `berrybrew remove $_`;
    }

    print "\nremoval of existing perl installs complete...\n";

    my @new_installs;

    for (1..$num){
        push @new_installs, $perls_available[rand @perls_available];
    }

    for (@new_installs){
        print "\ninstalling $_...\n";
        `berrybrew install $_`;
    }

    print "\nexecuting commands...\n";

    my @fails;

    for (@perls_installed){
        system("berrybrew switch $_");
        my $result = system("cpanm --installdeps . && dmake && dmake test");
        if ($result){
            push @fails, $_;
        }
    }

    if (@fails){
        print "Failed on...\n\n";
        print "$_\n" for @fails;
    }
}

