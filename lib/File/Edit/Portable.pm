package File::Edit::Portable;
use 5.006;
use strict;
use warnings;

our $VERSION = '0.02';

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

    $self->_check($file);

    open my $fh, '<', $file
      or croak "pread() can't open the file $file!: $!";

    binmode $fh;
    my @contents = <$fh>;

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

    open my $wfh, '>', $file or croak $!;

    for (@$contents){
        s/\R//;
        print $wfh $_ . $self->{eor};
    }

    close $wfh or croak $!;

    return 1;
}
sub _check {

    my $self = shift;
    my $file = shift;

    my $info = qx(file $file);

    if ($info =~ /CRLF/){
        $self->{eor} = "\r\n";
    }
    elsif ($info =~ /CR/) {
        $self->{eor} = "\r";
    }
    else {
        $self->{eor} = "\n";
    }

}
sub _config {

    my $self = shift;
    my %p = @_;

    delete $self->{testing} if ! $p{testing};

    for (keys %p){
        $self->{$_} = $p{$_};
    }
}
sub _extract {
    
    my $self = shift;
    my $file = shift;

    my $check = qx(file $file);

    my $eor;

    if ($check =~ /CRLF/){
        $eor = "0d0a";
    }
    elsif ($check =~ /CR/){
        $eor = "0d";
    }
    else {
        $eor = "0a";
    }

    return $eor;
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

=head1 DESCRIPTION

This module will read in a file, and keep track of the file's current line endings.
 
When you want to write the file back out after editing its contents, it'll write the file back out with the original line endings, bypassing perl's default behaviour of re-writing the file with the default record separator for the Operating System it's running on.


=head1 METHODS

=head2 new

Returns a new C<File::Edit::Portable> object.

=head2 pread

Opens a file and extracts its contents, returning an array of the files contents where each line of the file is a separate element in the array.

Parameters: <file =E<gt> 'filename'>


=head2 pwrite

Writes the data back to the original file, or alternately a copy of the file. Returns 1 on success.

Parameters: 

C<file =E<gt> 'file'>: Not needed if you've used C<pread()> to open the file. 

C<copy =E<gt> 'file2'>: Set this if you want to write to an alternate file, rather than the original.

C<contents =E<gt> \@contents>: Mandatory, should contain a reference to the array that was returned by C<pread()>.


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


