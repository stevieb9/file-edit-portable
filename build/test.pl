#!/usr/bin/perl
use warnings;
use strict;

system("sudo cpanm --installdeps . && make && make test");

