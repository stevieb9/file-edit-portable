#!/usr/bin/perl
use warnings;
use strict;

# set $debug to true to print out running info

my $debug = 0;

print "\nUsage: build.pl run_count [reload]\n" if ! $ARGV[0];

my $num = $ARGV[0];
my $reload = $ARGV[1];

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

    $num = scalar @perls_available if $num =~ /all/;

    $brew_info = `perlbrew list`;

    my @perls_installed
      = $brew_info =~ /perl-(\d\.\d+\.\d+)/g;

    if ($debug){
        print "$_\n" for @perls_installed;
    }

    my %perl_vers;

    print "\nremoving previous installs...\n" if $debug;

    for (@perls_installed){
        `perlbrew uninstall $_` if $reload;
    }

    print "\nremoval of existing perl installs complete...\n" if $debug;

    my @new_installs;

    for (1..$num){
        push @new_installs, $perls_available[rand @perls_available];
    }

    for (@new_installs){
        print "\ninstalling $_...\n" if $debug;
        `perlbrew install --notest -j 4 $_` if $reload;
    }

    my $result = `perlbrew exec build/test.pl 2>/dev/null`;
    my @ver_results = split /\n\n\n/, $result;

    my $i = 0;
    my $ver;

    print "\n\n";

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

    $num = scalar @perls_available if $num =~ /all/;

    my @perls_installed
      = $brew_info =~ /(\d\.\d{2}\.\d(?:_\d{2}))(?!=_)\s+\[installed\]/ig;

    my %perl_vers;

    print "\nremoving previous installs...\n" if $debug;

    for (@perls_installed){
        `berrybrew remove $_` if $reload;
    }

    print "\nremoval of existing perl installs complete...\n" if $debug;

    my @new_installs;

    for (1..$num){
        push @new_installs, $perls_available[rand @perls_available];
    }

    for (@new_installs){
        print "\ninstalling $_...\n" if $debug;
        `berrybrew install $_` if $reload;
    }

    print "\nexecuting commands...\n" if $debug;

    my $result = `berrybrew exec perl build\\test.pl`;

    my @ver_results = split /\n\n\n/, $result;

    my $ver;

    print "\n\n";

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
