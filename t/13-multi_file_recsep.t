#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use File::Copy;
use Test::More;

use Test::More tests => 6;

BEGIN {
    use_ok( 'File::Edit::Portable' ) || print "Bail out!\n";
}

my $rw = File::Edit::Portable->new;

my $win = 't/win.txt';
my $nix = 't/unix.txt';

my $win_cp = 't/win.bak';
my $nix_cp = 't/unix.bak';

{
    my $rw = File::Edit::Portable->new;

    my @win = $rw->read($win);
    $rw->write(copy => $win_cp, contents => \@win);

    my $recsep = $rw->recsep($win_cp, 'hex');

    is ($recsep, '\0d\0a', "with only one read(), recsep is written properly");
}
{
    my $rw = File::Edit::Portable->new;

    my @win = $rw->read($win);
    my @nix = $rw->read($nix);

    $rw->write(copy => $nix_cp, contents => \@nix);

    my $nix_recsep = $rw->recsep($nix_cp, 'hex');
    my $nix_internal_recsep = unpack("H*", $rw->{recsep}{$nix});
    $nix_internal_recsep =~ s/0/\\0/g;

    is ($nix_recsep, $nix_internal_recsep, 
        "we keep track of different recseps with multiple open files (nix)"
    );
    
    my $win_recsep = $rw->recsep($win_cp, 'hex');
    my $win_internal_recsep = unpack("H*", $rw->{recsep}{$win});
    $win_internal_recsep =~ s/0/\\0/g;
   
    is ($win_recsep, $win_internal_recsep, 
        "we keep track of different recseps with multiple open files (win)"
    );
 
}

for ($win_cp, $nix_cp){
    eval { unlink $_ or die "can't unlink $_"; };
    is ($@, '', "temp files unlinked successfully");
}
