###
# Object as root
# @version 1.0
# @see
# programmed by D.Kim
##

package Overwhelm::Object;
use strict;
use warnings;

###
# Constructor
##
sub new {
    my $class = shift;
    my $self = {};
    bless $self, ref($class) || $class;
    $self->_init(@_);
    return $self;
}

###
# Initialize
##
sub _init {
    my $self = shift;
    my (@args) = @_;
}

###
# Dump self
# @return hashTable
##
sub dump {
    my ($self) = @_;
    my @dump = ();
    foreach my $key (sort keys %$self) {
        my $rec = "$key = ";
        $rec .= defined $self->{$key} ? $self->{$key} : '(undef)';
        $rec .= "\n";
        push @dump, $rec;
    }
    return @dump
}

1;
__END__
