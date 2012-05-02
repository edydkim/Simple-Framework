###
# Utility
# @version 1.0
# @see
# programmed by D.Kim
##

package Overwhelm::Util;
use strict;
use warnings;

use Overwhelm::Exception;
use Overwhelm::Const;
use POSIX qw(strftime);

BEGIN {
    use Exporter;
    use vars qw(@ISA);
    @ISA = qw(Exporter);
}

###
# Constructor
##
sub new {
    new Overwhelm::Exception("This is a Static Class.\n");
}

###
# Use Multi-Thread or Not
# @return true or false
##
sub hasThread {
    return $Overwhelm::Const::USE_THREAD;
}

1;
__END__
