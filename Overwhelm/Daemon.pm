###
# Daemon
# @version 1.0
# @see
# programmed by D.Kim
##

package Overwhelm::Daemon;
use strict;
use warnings;

BEGIN {
    use Exporter;
    use vars qw(@ISA);
    @ISA = qw(Exporter);
    require Overwhelm::Object;
    push @ISA, qw(Overwhelm::Object);
}

use Overwhelm::Exception;
use Overwhelm::Const;
use POSIX qw(EAGAIN WNOHANG strftime setsid);

###
# Constructor
##
sub new {
    my $class = shift;
    my $self = {};
    bless $self, ref($class) || $class;
    $self->_init(@_);
    
    FORK: {
        if (my $pid = fork) {
            eval {
                setpriority(0, $pid, $Overwhelm::Const::PRIORITY);
            };
            $self->{__pid} = $pid;
            return $self;
        } elsif (defined $pid) {
            $self->_run;
            exit 0;
        } elsif ($! == EAGAIN) {
            sleep 5;
            redo FORK;
        } else {
            new Overwhelm::Exception("Can not fork.$!\n");
        }
    }
}

###
# Make daemon
##
sub _daemonize {
    my $self = shift;
    my ($callback) = @_;
    my $pidFile = '/tmp/overwhelm/' . $self->{__name} . '.pid';
    new Overwhelm::Exception("PID file($pidFile) is existed.´n") if -e $pidFile;
    
    open (OUT, ">$pidFile") || new Overwhelm::Exception("fail to write $pidFile : $!\n");
    print OUT $$;
    close (OUT) || new Overwhelm::Exception("fail to close $pidFile : $!\n");
    
    $SIG{HUP} = $SIG{INT} = $SIG{QUIT} = $SIG{PIPE} = $SIG{TERM} = sub {
        my $sig = shift;
        print "$sig signal is catched..\n";
        if ((unlink $pidFile) == 0) {
            print "unlink $pidFile : $!\n";
        }
        if (ref $callback eq 'CODE') {
            &$callback;
        }
        exit 0;
    };
    
    setsid || new Overwhelm::Exception("setsid : $!\n");
    
    chdir '/';
    umask 0;
    open STDIN, '/dev/null';
    open STDOUT, '>/tmp/overwhelm/overwhelm_execute.log';
    open STDERR, '>/tmp/overwhelm/overwhelm_stderr.log';
}

###
# Get the daemon pid
# @return pid
##
sub pid {
    my $self = shift;
    return $self->{__pid};
}

###
# Alive or Dead ?
# @return true or false
##
sub alive {
    my $self = shift;
    return (waitpid($self->{__pid}, WNOHANG) == 0) && ($? == -1);
}

1;
__END__
