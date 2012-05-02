###
# Receiver Daemon
# @version 1.0
# @see
# programmed by D.Kim
##

package Overwhelm::MMF::Receiver;
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
use Overwhelm::DB;
use threads;
use POSIX qw(strftime);

# When distribute a daemon
my $host = `hostname`;

###
# initialize
##
sub _init {
    my $self = shift;
    $self->{__name} = 'receiver';
}

###
# Runnable
##
sub _run {
    my $self = shift;
    $self->_daemonize(\&__end);
    while (1) {
        if (Overwhelm::Util::hasThread) {
            &__worker("worker(receiver)");
        } else {
            &__prefork("prefork(receiver)");
        }
        sleep 1;
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
    my $work = "/tmp/overwhelm/work";
    my @conn = Overwhelm::DB::conn;
    my $dbh = $conn[2];
    
    foreach my $file (grep -f, glob("/tmp/overwhelm/receive/*")) {
        if ($file =~ m/^.*_MMF\.dat\.m$/) {
            print localtime . ":$who is executed..\n";
            mkdir "$work", 0777 if (! -d "$work");
            my $workFile = "$work/" . basename($file) . ".r";
            `mv $file $workFile`;
            
            open(IN, "<$workFile");
            while (my $line = <IN>) {
                my @lines = split (/,/, $line);
                my ($re, $msg) = Overwhelm::DB::proc($dbh, shift @lines, shift @lines, @lines);
            }
            close IN;
            
            unlink $workFile;
        }
    }
    
    Overwhelm::DB::disc($dbh);
}

1;
__END__
