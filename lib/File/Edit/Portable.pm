package File::Edit::Portable;
use 5.010;
use strict;
use warnings;

our $VERSION = '0.10';

use Carp;
use Exporter;
use File::Temp qw(tempfile);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw (read pread write pwrite);

sub new {
    return bless {}, shift;
}
sub read {

    if (ref($_[0]) ne 'File::Edit::Portable'){
        if (wantarray){
            my @ret = pread(@_);
            return @ret;
        }
        else {
            my $fh = pread(@_);
            return $fh;
        }
    }
            
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

    if (ref($_[0]) ne 'File::Edit::Portable'){
        pwrite(@_);
        return 1;
    }

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

    $self->{is_read} = 0;
    
    close $wfh or croak "write() can't close file $file: $!";

    return 1;
}
sub recsep {

    my $self = shift;
    my $file = shift;

    my $fh = $self->_open($file);

    binmode $fh, ':raw';

    return if ! <$fh>;

    if (<$fh> =~ /(\R)/){
        $self->{recsep} = $1;
        $ENV{FEP_RECSEP} = $1;
    }

    close $fh or croak "recsep() can't close file $file!: $!";
    
    my $recsep = unpack "H*", $self->{recsep};

    $recsep =~ s/0/\\0/g;

    return $recsep;
}
sub platform_recsep {

    my $self = shift;

    my $file = $self->_temp_file;

    # this is for checking to see if we've cleaned up
    # in DESTROY

    push @{ $self->{temp_files} }, $file;

    # for platform_recsep(), we need the file open in ASCII mode,
    # so we can't use _open() or File::Temp

    open my $wfh, '>', $file
      or die "platform_recsep() can't open temp file $file for writing!: $!";

    print $wfh "abc\n";

    close $wfh
      or croak "platform_recsep() can't close temp file $file write: $!";

    my $fh = $self->_open($file);

    if (<$fh> =~ /(\R)/){
        $self->{platform_recsep} = $1;
    }

    close $fh
      or croak "platform_recsep() can't close temp file $file after run: $!";

    return $self->{platform_recsep};
}
sub pread {
    my ($file, $testing) = @_; 

    my $rw = File::Edit::Portable->new;

    $ENV{FEP_IS_READ} = 1;

    if (! $file){ 
        croak "pread() requires a file name sent in!";
    }

    $rw->recsep($file);

    if (! wantarray){
        my $handle = $rw->_handle($file);
        return $handle;
    }
    else {

        my $fh = $rw->_open($file);
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
sub pwrite {

    my ($file, $contents, $copy, $recsep) = @_;

    my $rw = File::Edit::Portable->new;

    if (! $file){
        croak "write() requires a file to be passed in!";
    }

    if (! $contents){
        croak "write() requires 'contents' param sent in";
    }

    $rw->recsep($file);

    $file = $copy if $copy;

    my $wfh = $rw->_open($file, 'w');

    for (@$contents){
        s/\R//;

        if ($recsep){
            print $wfh $_ . $recsep;
        }
       else {
            print $wfh $_ . $rw->{recsep};
        }
    }

    close $wfh or croak "write() can't close file $file: $!";

    return 1;
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

    my $fh = $self->_open($file);
    my $temp_wfh = File::Temp->new(UNLINK => 1);
    binmode $temp_wfh, ':raw';
    
    my $temp_filename = $temp_wfh->filename;

    # we'll check these in DESTROY to make sure we've
    # cleaned up appropriately

    push @{ $self->{temp_files} }, $temp_filename;

    $self->platform_recsep;

    for (<$fh>){
        s/\R/$self->{platform_recsep}/;
        print $temp_wfh $_;
    }

    close $fh or die "can't close file $file: $!";
    close $temp_wfh or die "can't close file $temp_filename: $!";

    my $ret_fh = $self->_open($temp_filename);
    
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
sub _temp_file {

    my $self = shift;
    
    my $temp_fh = File::Temp->new(UNLINK => 1);

    my $file = $temp_fh->filename;

    close $temp_fh
     or croak "_temp_file() can't close the $file temp file: $!";

    return $file;
}
sub DESTROY {
    
    my $self = shift;

    for (@{ $self->{temp_files} }){
        if (-f && $^O ne 'MSWin32'){
            eval { unlink $_ or die $!; };
            if ($@){
                croak "File::Temp didn't unlink $_ temp file, and we " .
                      "can't unlink it in our DESTROY() either!: $@";
            }
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

There's also a non-OO interface...

    use File::Edit::Portable qw(read write);

    my $fh = read('file.txt');

    # and/or

    my @contents = read('file.txt');

    # then

    write('file.txt', \@contents);


=head1 DESCRIPTION

The default behaviour of C<perl> is to read and write files using the Operating System's (OS) default record separator (line ending). If you open a file on an OS where the record separators are that of another OS, things can and do break.

This module will read in a file, keep track of the file's current record separators regardless of the OS. It can return either a file handle (in scalar context) that has had its line endings replaced with that of the local OS platform, or an array of the file's contents (in list context) with line endings stripped off. You can then modify this array and send it back in for writing to the same file or a new file, where the original file's line endings will be re-appended (or a custom ending if you so choose).

Uses are for dynamically reading/writing files while on one Operating System, but you don't know whether the record separators are platform-standard. Shared storage between multpile platforms are a good use case. This module affords you the ability to not have to check each file, and is very useful in looping over a directory where various files may have been written by different platforms.

=head1 EXPORT

None by default. See L<EXPORT_OK>

=head1 EXPORT_OK

If you desire using the non-OO functionality, the following functions are exported on demand.

C<read()> and C<write()>. If there are namespace collisions with those two functions, C<pread()> and C<pwrite()> are available as well.

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

=head1 FUNCTIONS

=head2 C<read('file.txt')>

C<pread()> can alternately be imported in the event of namespace collisions.

In scalar context, will return a read-only file handle. In list context, returns an array with each element being a line in the file, with the endings stripped off.

=head2 C<write('file.txt', \@contents, 'copy.txt', "\r\n")>

C<pwrite()> can alternately be imported in the event of namespace collisions.

Writes back out the file (or alternately a new file (copy.txt), using the original file's line endings, or optionally a custom record separator as specified by the last parameter. Note the record separator MUST be sent in within double-quotes.

If you want to send in a custom record separator but not use a copy file, just set the third parameter (copy.txt) to C<undef> within the call.


=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-file-edit-portable at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Edit-Portable>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 REPOSITORY

L<https://github.com/stevieb9/file-edit-portable>

=head1 BUILD RESULTS

Travis-CI: L<https://travis-ci.org/stevieb9/file-edit-portable>

CPAN Testers: L<http://matrix.cpantesters.org/?dist=File-Edit-Portable>

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


