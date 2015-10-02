#!/usr/bin/perl
use warnings;
use strict;

if ($^O ne 'MSWin32'){
    system("sudo cpanm --installdeps . && make && make test");
}
else {
    system("cpanm --installdeps . && dmake && dmake test");
}

