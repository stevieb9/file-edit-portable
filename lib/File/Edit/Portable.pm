package File::Edit::Portable;
use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

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

    open my $fh, '<', $file or croak $!;

    binmode $fh;
    my @contents = <$fh>;

    close $fh or croak $!;

    my $eor;

    if ($contents[0]){
        for (@contents){
            if (/(\R)/){
                $eor = unpack "H*", $1;
            }
        }
    }

    return $eor;
}
sub _vim_placeholder {}; # for folding

1;
__END__

=head1 NAME

File::Edit::Portable - Read and write files while keeping the original line-endings intact

=cut

=head1 SYNOPSIS

    use File::Edit::Portable;

    my $fep = File::Edit::Portable->
    my @contents = File::Edit::Portable->new->
=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

}

=head2 function2

=cut

}

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

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/File-Edit-Portable>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/File-Edit-Portable>

=item * Search CPAN

L<http://search.cpan.org/dist/File-Edit-Portable/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of File::Edit::Portable
