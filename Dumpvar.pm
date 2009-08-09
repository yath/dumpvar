# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <yath@yath.de> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.
#   Sebastian Schmidt
# ----------------------------------------------------------------------------

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
