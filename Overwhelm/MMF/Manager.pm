###
# Manager Daemon
# @version 1.0
# @see
# programmed by D.Kim
##

package Overwhelm::MMF::Manager;
use strict;
use warnings;

BEGIN {
    use Exporter;
    use File::Basename;
    use File::Copy;
    use Time::Local;
    use vars qw(@ISA);
    @ISA = qw(Exporter);
    require Overwhelm::Daemon;
    push @ISA, qw(Overwhelm::Daemon);
}

use Overwhelm::Util;
use Overwhelm::Exception;
use threads;
use Time::HiRes;
use POSIX qw(strftime);

# When distribute a daemon
my $host = `hostname`;

###
# initialize
##
sub _init {
    my $self = shift;
    $self->{__name} = 'manager';
}

###
# Runnable
##
sub _run {
    my $self = shift;
    $self->_daemonize(\&__end);
    while (1) {
        if (Overwhelm::Util::hasThread) {
            &__worker("worker(manager)");
        } else {
            &__prefork("prefork(manager)");
        }
        sleep 5;
    }
}

###
# Finalize
##
sub __end {
    print "end.. ´n";
}


###
# Make thread when supported multi-thread
##
sub __worker {
    my $str = shift;
    threads->create(\&__execute, $str);
    foreach my $thread (threads->list) {
        if ($thread->tid && !threads::equal($thread, threads->self)) {
            $thread->join;
        }
    }
}

###
# Fork process when not supported multi-thread
##
sub __prefork {
    my $str = shift;
    my @processes;
    if (my $pid = fork) {
        push @processes, $pid;
    } elsif (defined $pid) {
        &__execute($str);
        exit 0;
    } else {
        new Overwhelm::Exception("Can not fork : $!\n");
    }
    
    foreach my $process (@processes) {
        waitpid($process, 0);
    }
}

###
# Execute job
##
sub __execute {
    my $who = shift;
    my $manage = "/tmp/overwhelm";
    my $send = "/tmp/overwhelm/send";
    my $receive = "/tmp/overwhelm/receive";
    
    # Replication and Check Synchronization for the data by the sender and the recevier ..
    foreach my $file (grep -f, glob("/tmp/overwhelm/*")) {
        if ($file =~ m/^.*_MMF\.dat$/) {
            print localtime . ":$who is executed..\n";
            my $mFile = "$file" . ".m";
            
            rename "$file", "$mFile";
            mkdir "$send", 0777 if (! -d "$send");
            mkdir "$receive", 0777 if (! -d "$receive");
            
            `cp -p $mFile $send`;
            `cp -p $mFile $receive`;
            
            
            my $sFile = "$send/" . basename($mFile);
            my $rFile = "$receive/" . basename($mFile); 
            while (1) {
                if (-f $rFile || -f $sFile) {
                    Time::HiRes::sleep(0.5);
                    next;
                }
                last;
            }
            
            unlink $mFile;
        }
    }
}

1;
__END__