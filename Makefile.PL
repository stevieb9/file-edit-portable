use 5.012;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'File::Edit::Portable',
    AUTHOR           => q{Steve Bertrand <steveb@cpan.org>},
    VERSION_FROM     => 'lib/File/Edit/Portable.pm',
    MIN_PERL_VERSION => '5.012',
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
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'File-Edit-Portable-*' },
);

if ($^O eq 'MSWin32' || $^O eq 'MacOS'){

    print "\nSetting up environment for non-Unix...\n\n";
    
    { # win

        my $eor = qx(file t/win.txt);

        if ($eor !~ /CRLF/){

            open my $fh, '<', 't/win.txt' or die $!;
            my @f = <$fh>;
            close $fh or die $!;

            for (@f){
                s/\n/\r\n/g;
            }

            unlink 't/win.txt';

            open my $wfh, '<', 't/win.txt' or die $!;

            for (@f){
                print $wfh $_;
            }

            close $wfh or die $!;
        }
    }

    { # unix

        my $eor = qx(file t/unix.txt);

        if ($eor =~ /CRLF/){

            open my $fh, '<', 't/unix.txt' or die $!;
            my @f = <$fh>;
            close $fh or die $!;

            for (@f){
                s/\r\n/\n/g;
            }

            unlink 't/unix.txt';

            open my $wfh, '<', 't/unix.txt' or die $!;

            for (@f){
                print $wfh $_;
            }

            close $wfh or die $!;
        }
    }
}
