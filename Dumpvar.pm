# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <yath@yath.de> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.
#   Sebastian Schmidt
# ----------------------------------------------------------------------------

=head1 NAME

Dumpvar - An interface to L<Devel::Peek> that returns a scalar

=head1 SYNOPSIS

    use Dumpvar;
    (...)
    my $ret = Dumpvar $foobar;

=head1 DESCRIPTION

Uses L<Devel::Peek>'s Dump to dump perl's internal representation of a
variable. There's no real magic involved here, the advantage over
C<Devel::Peek::Dump> is just that C<Dumpvar()> returns a scalar with 
C<Devel::Peek::Dump>'s output. That makes debugging handier if you
don't have a usable STDERR.

=head1 SEE ALSO

L<Devel::Peek>, L<perlguts>,
L<http://www.perl.org/tpc/1998/Perl_Language_and_Modules/Perl%20Illustrated/>
=cut

package Dumpvar;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(Dumpvar);

use Devel::Peek;
use File::Temp qw(tempfile);
use Carp qw(croak);

sub Dumpvar(\$) {
    my $var = shift;

    open (my $oldfh, ">&STDERR") || croak("Unable to dup STDERR: $!");

    my ($fh, $fn) = tempfile();
    open (STDERR, ">", $fn) || croak("Unable to open $fn for writing: $!");
    Dump $$var;
    close(STDERR) || croak("Unable to close $fn: $!");
    open(STDERR, ">&", $oldfh) || croak("Unable to restore STDERR: $!");

    my $ret = do {
        local $/;
        <$fh>;
    };
    unlink($fn);
    return $ret; 
}

1;
