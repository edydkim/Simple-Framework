###
# Exception
# @version 1.0
# @see
# programmed by D.Kim
##

package Overwhelm::Exception;
use strict;
use warnings;

BEGIN {
    use Exporter;
    use vars qw(@ISA);
    @ISA = qw(Exporter);
}

our $gmsg = "Exception occurs..";

###
# Constructor
##
sub new {
    my ($class, $message) = @_;
    $message = defined $message ? $message : $gmsg;
    my $log = "/tmp/overwhelm/overwhelm_stdwarn.log";
    
    open (OUT, ">>$log");
    print OUT "$class : $message\n";
    close OUT;
}


1;
__END__
