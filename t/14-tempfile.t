#!perl
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use Test::More;

use Test::More tests => 7;

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

    my $win_fh = $rw->read($win);
    my $temp_wfh = $rw->tempfile;

    while (<$win_fh>){
        s/asd/xxx/g;
        print $temp_wfh $_;
    }

    $rw->write(copy => $win_cp, contents => $temp_wfh);
    
    my $recsep = $rw->recsep($win_cp, 'hex');
    is ($recsep, '\0d\0a', "write() a tempfile() has proper line endings for win32");

    my $fh = $rw->read($win_cp);

    {
        local $/;
        my $matches = () = <$fh> =~ /xxx/g;
        is ($matches, 4, "write() with tempfile() handle does the right thing for win32");
    }
}
{
    my $rw = File::Edit::Portable->new;

    my $nix_fh = $rw->read($nix);
    my $temp_wfh = $rw->tempfile;

    while (<$nix_fh>){
        s/asd/xxx/g;
        print $temp_wfh $_;
    }

    $rw->write(copy => $nix_cp, contents => $temp_wfh);
    
    my $recsep = $rw->recsep($nix_cp, 'hex');
    is ($recsep, '\0a', "write() a tempfile() has proper line endings with nix");

    my $fh = $rw->read($nix_cp);

    {
        local $/;
        my $matches = () = <$fh> =~ /xxx/g;
        is ($matches, 7, "write() with tempfile() handle does the right thing with nix");
    }
}

for ($win_cp, $nix_cp){
    eval { unlink $_ or die "can't unlink $_"; };
    is ($@, '', "temp files unlinked successfully");
}
