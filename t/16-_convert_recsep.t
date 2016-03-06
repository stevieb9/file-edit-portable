#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use Test::More;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

my $rw = File::Edit::Portable->new;

my @seps = ("\n", "\r\n", "\r", "blah");
my ($hex, $os);

$hex = $rw->_convert_recsep("\n", 'hex');
is ($hex, '\0a', 'converts nix to hex ok');
$os = $rw->_convert_recsep("\n", 'os');
is ($os, 'nix', 'converts nix to os ok');

$hex = $rw->_convert_recsep("\r\n", 'hex');
is ($hex, '\0d\0a', 'converts win to hex ok');
$os = $rw->_convert_recsep("\r\n", 'os');
is ($os, 'win', 'converts win to os ok');

$hex = $rw->_convert_recsep("\r", 'hex');
is ($hex, '\0d', 'converts mac to hex ok');
$os = $rw->_convert_recsep("\r", 'os');
is ($os, 'mac', 'converts mac to os ok');

$hex = $rw->_convert_recsep("xxx", 'hex');
is ($hex, '787878', 'converts unknown to hex ok');
$os = $rw->_convert_recsep("xxx", 'os');
is ($os, 'unknown', 'converts unknown to os ok');

done_testing();
