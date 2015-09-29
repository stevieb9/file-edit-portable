package File::Edit::Portable;
use 5.010;
use strict;
use warnings;

our $VERSION = '0.08';

use Carp;

sub new {
    return bless {}, shift;
}
sub read {

    my $self = shift;

    $self->_config(@_);

    $self->{is_read} = 1;

    my $file = $self->{file};
    my $testing = $self->{testing};

    if (! $file){ 
        croak "read() requires a file name sent in!";
    }

    $self->recsep($file);

    my $fh = $self->_open($file);

    if (! wantarray){
        my $handle = $self->_handle($file);
        return $handle;
    }
    else {

        my @contents = <$fh>;
        close $fh or croak "read() can't close file $file!: $!";

        if (! $testing){
            for (@contents){
                s/\R//;
            }
        }
        return @contents;
    }
}
sub write {

    my $self = shift;
    my $p = $self->_config(@_);

    my $file = $self->{file};
    my $copy = $self->{copy};
    my $contents = $self->{contents};
    my $recsep = $self->{custom_recsep};

    if (! $file){
        croak "write() requires a file to be passed in!";
    }

    if (! $contents){
        croak "write() requires 'contents' param sent in";
    }

    $file = $copy if $copy;

    if (! $self->{is_read}){
        $self->recsep($file);
    }

    my $wfh = $self->_open($file, 'w');

    for (@$contents){
        s/\R//;

        if ($recsep){
            print $wfh $_ . $recsep;
        }
        else {
            print $wfh $_ . $self->{recsep};
        }
    }

    close $wfh or croak "write() can't close file $file: $!";
    $self->{is_read} = 0;

    return 1;
}
sub recsep {

    my $self = shift;
    my $file = shift;

    open my $fh, '<', $file 
      or croak "recsep() can't open file $file!: $!";

    binmode $fh, ':raw';

    my @contents = <$fh>;

    close $fh or croak "recsep() can't close file $file!: $!";

    return if ! $contents[0];

    if ($contents[0] =~ /(\R)/){
        $self->{recsep} = $1;;
    }

    my $recsep = unpack "H*", $self->{recsep};

    $recsep =~ s/0/\\0/g;

    return $recsep;
}
sub platform_recsep {

    my $self = shift;
    my $file = 'local.tmp';

    open my $wfh, '>', $file 
      or die "platform_recsep() can't open temp file $!";

    print $wfh "x\n";

    close $wfh or die "platform_recsep() can't close temp file $!";

    open my $fh, '<', $file 
      or die "platform_recsep() can't open temp file $!";

    binmode $fh, ':raw';

    for (<$fh>){
        if (/(\R)/){
            $self->{platform_recsep} = $1;
        }
    }

    close $fh or die "platform_recsep() can't close temp file $!";

    unlink $file or die "platform_recsep() can't unlink the 'local.txt' temp file";

    return $self->{platform_recsep};
}
sub _config {

    my $self = shift;
    my %p = @_;

    $self->{custom_recsep} = $p{recsep};
    delete $p{recsep};
    delete $self->{testing} if ! $p{testing};
    delete $self->{copy};

    for (keys %p){
        $self->{$_} = $p{$_};
    }
}
sub _handle {

    my $self = shift;
    my $file = shift;

    my $temp_file = "$$.tmp";

    my $fh = $self->_open($file);
    binmode $fh, ':raw';

    my $wfh = $self->_open($temp_file, 'w');
    binmode $wfh, ':raw';

    $self->platform_recsep;

    for (<$fh>){
        s/\R/$self->{platform_recsep}/;
        print $wfh $_;
    }

    close $fh or die "can't close file $file: $!";
    close $wfh or die "can't close file $file: $!";

    my $ret_fh = $self->_open($temp_file);

    return $ret_fh;
}
sub _open {

    my $self = shift;
    my $file = shift;
    my $mode = shift || 'r';

    my $fh;

    if ($mode =~ /^w/){
        open $fh, '>', $file
          or croak "can't open file $file for writing!: $!";
    }
    else {
        open $fh, '<', $file
          or croak "can't open file $file for reading!: $!";
    }

    binmode $fh, ':raw';

    return $fh;
}
sub DESTROY {
    if (-f "$$.tmp"){
        eval { unlink "$$.tmp" or die $!; };
        if ($@){
            croak "can't unlink temp file $$.txt in DESTROY()";
        }
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

Get a (read-only) file handle which (if necessary) has had the existing record separator (line endings) replaced with the current local platform's (OS's).

    my $fh = $rw->read(file => 'file.txt');

Get an array of the contents of the file after having record separators checked/stored, modify the contents, then re-write
the file with the original record separator found.

    my @contents = $rw->read(file => 'file.txt');

    s/this/that/g for @contents;

    $rw->write(contents => \@contents);

When writing, override the original record separator with a custom one.

    $rw->write(recsep => "\r\n", contents => \@contents);

Get the original record separator found in the file in hex format.

    my $hex_record_separator = $rw->recsep('file');

Get the local platforms record separator. This will be in string representation.

    my $platform_recsep = $rw->platform_recsep;


=head1 DESCRIPTION

The default behaviour of C<perl> is to read and write files using the Operating System's (OS) default record separator (line ending). If you open a file on an OS where the record separators are that of another OS, things can and do break.

This module will read in a file, keep track of the file's current record separators regardless of the OS. It can return either a file handle (in scalar context) that has had its line endings replaced with that of the local OS platform, or an array of the file's contents (in list context) with line endings stripped off. You can then modify this array and send it back in for writing to the same file or a new file, where the original file's line endings will be re-appended (or a custom ending if you so choose).

Uses are for dynamically reading/writing files while on one Operating System, but you don't know whether the record separators are platform-standard. Shared storage between multpile platforms are a good use case. This module affords you the ability to not have to check each file, and is very useful in looping over a directory where various files may have been written by different platforms.


=head1 METHODS

=head2 C<new>

Returns a new C<File::Edit::Portable> object.

=head2 C<read>

Parameters: C<file =E<gt> 'filename'>

In scalar context, will return a read-only file handle to a copy of the file that has had its line endings replaced with those of the local OS platform's record separator.

In list context, will return an array, where each element is a line from the file, with all line endings stripped off.

In both cases, we save the line endings that were found in the original file (which is used when C<write()> is used, by default).



=head2 C<write>

Writes the data back to the original file, or alternately a copy of the file. Returns 1 on success. If you inadvertantly append newlines to the new elements of the contents array, we'll strip them off before appending the real newlines.

Parameters: 

C<file =E<gt> 'file'>: Not needed if you've used C<read()> to open the file. 

C<copy =E<gt> 'file2'>: Set this if you want to write to an alternate (new) file, rather than the original.

C<contents =E<gt> \@contents>: Mandatory, should contain a reference to the array that was returned by C<read()>.

C<recsep =E<gt> "\r\n">: Optional, a double-quoted string of any characters you want to write as the line ending (record separator). This value will override what was found in the C<read()> call. Common ones are C<"\r\n"> for Windows, C<"\n"> for Unix and C<"\r"> for Mac. 

=head2 C<recsep('file')>

Returns a string of the hex representation of the line endings (record separators) in 'file'. For example, "\0d\0a" will be returned for Windows line endings (CRLF).

=head2 C<platform_recsep>

Returns the string representation of the current platform's (OS) record separator. Takes no parameters.

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-file-edit-portable at rt.cpan.org>, or through
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


