package File::Edit::Portable;
use 5.006;
use strict;
use warnings;

our $VERSION = '0.04';

use Carp;

sub new {
    return bless {}, shift;
}
sub pread {

    my $self = shift;

    $self->_config(@_);

    my $file = $self->{file};
    my $testing = $self->{testing};

    if (! $file){ 
        croak "pread() requires a file name sent in!";
    }

    $self->recsep($file);

    open my $fh, '<', $file
      or croak "pread() can't open the file $file!: $!";

    binmode $fh, ':raw';
    my @contents = <$fh>;

    close $fh or croak $!;

    if (! $testing){
        for (@contents){
            s/\R//;
        }
    }

    return @contents;
}
sub pwrite {

    my $self = shift;
    my $p = $self->_config(@_);

    my $file = $self->{file};
    my $copy = $self->{copy};
    my $contents = $self->{contents};

    return if ! $file;

    $file = $copy if $copy;

    open my $wfh, '>', $file or die $!;

    binmode $wfh, ':raw';

    for (@$contents){
        s/\R//;
        print $wfh $_ . $self->{recsep};
    }

    close $wfh or croak $!;

    return 1;
}
sub recsep {

    my $self = shift;
    my $file = shift;

    open my $fh, '<', $file or croak $!;

    binmode $fh, ':raw';

    my @contents = <$fh>;

    close $fh or croak $!;

    return if ! $contents[0];

    if ($contents[0] =~ /(\R)/){
        $self->{recsep} = $1;;
    }

    my $recsep = unpack "H*", $self->{recsep};

    $recsep =~ s/0/\\0/g;

    return $recsep;
}
sub _config {

    my $self = shift;
    my %p = @_;

    delete $self->{testing} if ! $p{testing};
    delete $self->{copy};

    for (keys %p){
        $self->{$_} = $p{$_};
    }
}
sub _vim_placeholder {}; # for folding

1;
__END__

=head1 NAME

File::Edit::Portable - Read and write files while keeping the original line-endings intact, no matter the platform.

=cut

=head1 SYNOPSIS

    use File::Edit::Portable;

    my $rw = File::Edit::Portable->new;

    my @contents = $rw->pread(file => 'file.txt');

    push @contents, 'line 1', 'line 2';

    $rw->pwrite(file => 'file.txt', contents => \@contents);

    $hex_record_separator = $rw->recsep('file');

=head1 DESCRIPTION

This module will read in a file, and keep track of the file's current line endings, and write the file back out using those same original line endings.

Uses are for dynamically reading/writing files while on one Operating System, but you don't know that the record separator (line endings) are platform-standard.

You're returned an array with all of the lines of the file on read. You can them manipulate it, and then pass it back for re-writing the file (or a copy).

=head1 METHODS

=head2 C<new>

Returns a new C<File::Edit::Portable> object.

=head2 C<pread>

Opens a file and extracts its contents, returning an array of the files contents where each line of the file is a separate element in the array.

Parameters: C<file =E<gt> 'filename'>


=head2 C<pwrite>

Writes the data back to the original file, or alternately a copy of the file. Returns 1 on success.

Parameters: 

C<file =E<gt> 'file'>: Not needed if you've used C<pread()> to open the file. 

C<copy =E<gt> 'file2'>: Set this if you want to write to an alternate file, rather than the original.

C<contents =E<gt> \@contents>: Mandatory, should contain a reference to the array that was returned by C<pread()>.

=head2 C<recsep('file')>

Returns a string of the hex representation of the line endings (record separators) in 'file'. For example, "\0d\0a" will be returned for Windows line endings (CRLF).

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-file-rw-portable at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Edit-Portable>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc File::Edit::Portable


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-Edit-Portable>

=item * Search CPAN

L<http://search.cpan.org/dist/File-Edit-Portable/>

=back



=head1 LICENSE AND COPYRIGHT

Copyright 2015 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


