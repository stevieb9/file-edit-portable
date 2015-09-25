use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'File::Edit::Portable',
    AUTHOR           => q{Steve Bertrand <steveb@cpan.org>},
    VERSION_FROM     => 'lib/File/Edit/Portable.pm',
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

if ($^O eq 'MSWin32'){

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
