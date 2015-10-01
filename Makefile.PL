use 5.010;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'File::Edit::Portable',
    AUTHOR           => q{Steve Bertrand <steveb@cpan.org>},
    VERSION_FROM     => 'lib/File/Edit/Portable.pm',
    MIN_PERL_VERSION => '5.010',
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url => 'https://github.com/stevieb9/file-edit-portable.git',
                web => 'https://github.com/stevieb9/file-edit-portable',
            },
        },
    },
    ABSTRACT_FROM    => 'lib/File/Edit/Portable.pm',
    LICENSE          => 'perl_5',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        Carp => 0,
        Exporter => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'File-Edit-Portable-*' },
);

if ($^O eq 'MSWin32' || $^O eq 'MacOS'){

    print "\nSetting up environment for non-Unix...\n\n";
    
    { # win

        my $file = 't/win.txt';

        open my $fh, '<', $file or die $!;
        binmode $fh, ':raw';

        my @f = <$fh>;
        close $fh or die $!;

        for (@f){
            s/\R/\r\n/g;
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
            s/\R/\n/g;
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
