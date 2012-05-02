###
# Sender Daemon
# @version 1.0
# @see
# programmed by D.Kim
##

package Overwhelm::MMF::Sender;
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
use Fcntl qw(:DEFAULT :flock :seek);
use POSIX qw(strftime);

# When distribute a daemon
my $host = `hostname`;

###
# initialize
##
sub _init {
    my $self = shift;
    $self->{__name} = 'sender';
}

###
# Runnable
##
sub _run {
    my $self = shift;
    $self->_daemonize(\&__end);
    while (1) {
        if (Overwhelm::Util::hasThread) {
            &__worker("worker(sender)");
        } else {
            &__prefork("prefork(sender)");
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
    my $dat = "/Applications/MAMP/htdocs";
    my $work = "/tmp/overwhelm/work";
    
    foreach my $file (grep -f, glob("/tmp/overwhelm/send/*")) {
        if ($file =~ m/^.*_MMF\.dat\.m$/) {
            print localtime . ":$who is executed..\n";
            mkdir "$work", 0777 if (! -d "$work");
            my $workFile = "$work/" . basename($file) . ".s";
            `mv $file $workFile`;
            
            open(IN, "<$workFile");
            while (my $line = <IN>) {
                my @lines = split (/,/, $line);
                my $mode = shift @lines;
                my $html = shift @lines;
                $html = "${dat}/${html}.html";
                my $nhtml = "$workFile" . ".html";
                
                open(R, "<$html");
                open(W, ">$nhtml");
                while (my $l = <R>) {
                    if ($mode eq 'insert' && $l =~ m/MMF:/) {
                        my $ol = $l;
                        foreach my $e (@lines) {
                            $l =~ s/\?/$e/;
                        }
                        $l =~ s/<!--MMF://g;
                        $l =~ s/:MMF--!>//g;
                        print W "$ol";
                    }
                    print W $l;
                    # TODO : Implement the cases by update and delete
                }
                `mv -f $nhtml $html`;
                close R;
                close W;
            }
            close IN;
            
            unlink $workFile;
        }
    }
}

1;
__END__