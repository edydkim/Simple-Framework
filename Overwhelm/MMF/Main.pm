#!/usr/bin/perl -I/Users/kimudaiki/Desktop

###
# Main
# @version 1.0
# @see
# programmed by D.Kim
##

package Overwhelm::MMF::Main;
use strict;
use warnings;

use Overwhelm::MMF::Receiver;
use Overwhelm::MMF::Sender;
use Overwhelm::MMF::Manager;

use vars qw(@PARAM);
@PARAM = @ARGV;

my $daemonName = shift @PARAM;

if (!defined $daemonName) {
    print "Fatal : Daemon name is not defined..\n";
    exit 1;
}

# Receive the data and call stored procedure to DB
if ($daemonName eq 'receiver') {
    my $receiver = new Overwhelm::MMF::Receiver;
    exit 11 if !defined $receiver;
    print 'Receiver daemon (pid' . $receiver->pid . ") is started..\n";
}

# Send the data to HTML
if ($daemonName eq 'sender') {
    my $sender = new Overwhelm::MMF::Sender;
    exit 12 if !defined $sender;
    print 'Sender daemon (pid' . $sender->pid . ") is started..\n";
}

# Manage receiver and sender
if ($daemonName eq 'manager') {
    my $manager = new Overwhelm::MMF::Manager;
    exit 13 if !defined $manager;
    print 'Manager daemon (pid' . $manager->pid . ") is started..\n";
}

exit 0;

1;
__END__
