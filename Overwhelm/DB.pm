###
# DB Connection to SQLite
# This class has Control and Model in the parts of  MVC.
# @version 1.0
# @see
# programmed by D.Kim
##

package Overwhelm::DB;
use strict;
use warnings;

BEGIN {
    use Exporter;
    use vars qw(@ISA @EXPORT);
    @ISA = qw(Exporter);
    @EXPORT = qw(conn disc proc);
}

use Overwhelm::Exception;
use DBI;

###
# Connect to DB
# @return success or fail, error, db handler
##
sub conn {
    # no use on adhoc memory
    my $database = "dbi:SQLite:dbname=/Users/kimudaiki/Desktop/sqlite/overwhelm.sqlite";
    my $dbh = DBI->connect($database);
    $dbh->{RaiseError} = 0;
    $dbh->{PrintError} = 0;
    $dbh->{AutoCommit} = 1;
    my $msg = $DBI::errstr;
    if ($msg) {
        return (1, $msg, '');
    }
    return (0, '', $dbh);
}

###
# Disconnect from DB
# @return success or fail, error
##
sub disc {
    my $dbh = shift;
    $dbh->disconnect;
    my $msg = $DBI::errstr;
    if ($msg) {
        return (1, $msg);
    }
    return (0, '');
}

###
# Run Procedure
# As you know, This is new method because SQLite has no package, procedure and function rather than Oracle I could not find.
# I will show you pseudo code for Oracle instead..
# @return success or fail, error
##
sub proc {
    my ($dbh, $dml, $table, @binds) = @_;
    my $sql = "";

    if ($dml eq 'insert') {
        $sql = "INSERT INTO $table VALUES (?, ?);";
    }
    if ($dml eq 'update') {
        $sql = "UPDATE $table SET $binds[0] = ? WHERE ID = ?;";
        shift @binds;
    }
    if ($dml eq 'delete') {
        $sql = "DELETE FROM $table WHERE ID = ?;";
    }
    if ($dml eq 'select') {
        # no sql
        new Overwhelm::Exception("It does not have select query\n");

        # This is only use for Debug
        $sql = "SELECT * FROM $table;";
    }
    
    my $sth = $dbh->prepare($sql);
    $sth->execute(@binds);
     
    # This is only use for Debug
    if ($dml eq 'select') {
        my $ref = $sth->fetchall_arrayref;
        foreach my $row (@$ref) {
            print "@$row";
        }
    }
    $sth->finish;

    my $msg = $DBI::errstr;
    if ($msg) {
        return (1, $msg);
    }
    return (0, '');
}

1;
__END__
