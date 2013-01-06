package DBIx::Foo;

use strict;

use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(selectrow selectrow_array selectrow_hashref selectall selectall_arrayref selectall_hashref dbh_do);

sub selectrow
{
	my ($self, $sql, $opts, @args) = @_;

	nice_params(\$opts, \@args);

    my $logger = Log::Log4perl->get_logger('db.simplequery.selectrow');

	my $row = $self->dbh->selectrow_hashref($sql, $opts, @args);

	log_query($self->dbh, $sql, \@args, $logger);

	return $row;
}

sub selectrow_hashref
{
	my ($self, $sql, $opts, @args) = @_;

	nice_params(\$opts, \@args);

    my $logger = Log::Log4perl->get_logger('db.simplequery.selectrow_hashref');

	my $row = $self->dbh->selectrow_hashref($sql, $opts, @args);

	log_query($self->dbh, $sql, \@args, $logger);

	return $row;
}

sub selectrow_array
{
	my ($self, $sql, $opts, @args) = @_;

	nice_params(\$opts, \@args);

    my $logger = Log::Log4perl->get_logger('db.simplequery.selectrow_array');

	my @row = $self->dbh->selectrow_array($sql, $opts, @args);

	log_query($self->dbh, $sql, \@args, $logger);

	return $row[0] if scalar @row == 1; # for compatibility

	return @row;
}

sub selectall
{
	my ($self, $sql, @args) = @_;

	my $opts = { Slice => {} };

    my $logger = Log::Log4perl->get_logger('db.simplequery.selectall');

	my $rows = $self->dbh->selectall_arrayref($sql, $opts, @args);

	log_query($self->dbh, $sql, \@args, $logger);

	return $rows;
}

sub selectall_arrayref
{
	my ($self, $sql, $opts, @args) = @_;

	nice_params(\$opts, \@args);

    my $logger = Log::Log4perl->get_logger('db.simplequery.selectall_arrayref');

	my $rows = $self->dbh->selectall_arrayref($sql, $opts, @args);

	log_query($self->dbh, $sql, \@args, $logger);

	return $rows;
}

sub selectall_hashref
{
	my ($self, $sql, $key_field, $opts, @args) = @_;

	nice_params(\$opts, \@args);

    my $logger = Log::Log4perl->get_logger('db.simplequery.selectall_hashref');

	my $rows = $self->dbh->selectall_hashref($sql, $key_field, $opts, @args);

	log_query($self->dbh, $sql, \@args, $logger);

	return $rows;
}

sub dbh_do
{
	my ($self, $sql, $opts, @args) = @_;

	nice_params(\$opts, \@args);

	my $logger = Log::Log4perl->get_logger('db.simplequery.dbh_do');

	# MSSQL insert requires extra SCOPE_IDENTITY() call to give inserted value - current best solution MT (only way I can make it work...)
	if ($self->dbh->get_info(17) eq 'Microsoft SQL Server' && $sql =~ /^insert/i) {
		
		return mssql_insert($self->dbh, $sql, $opts, @args);
	}
	
	
	my $result = $self->dbh->do($sql, $opts, @args);

	log_query($self->dbh, $sql, \@args, $logger);

	if ($result && $sql =~ /^insert/i) {
		
		my $newid = $self->dbh->{mysql_insertid};
		
		$logger->debug("Got insertid : $newid");
		
		return $newid;
	}
	else {
		
		return $result;
	}
}

sub mssql_insert
{
	my ($dbh, $sql, $opts, @args) = @_;

	my $logger = Log::Log4perl->get_logger('db.simplequery.mssql_insert');

	$sql .= ';' unless $sql =~ /;\s*/;
	$sql .= "select SCOPE_IDENTITY();";

	my $newid = $dbh->selectrow_array($sql, $opts, @args);
	
	log_query($dbh, $sql, \@args, $logger);
	
	return $newid;
}

sub log_query
{
	my ($dbh, $sql, $args, $logger) = @_;

	# use the 'caller' function name to work out context
	my $caller = ( caller(2) )[3];

	if ($dbh->err) {

		$logger->error($dbh->errstr . " - $sql (" . join(",", @$args) . ") called by $caller");

	} else {

		$logger->debug("$sql (" . join(",", @$args) . ") called by $caller");
	}
}

sub nice_params
{
	my ($opts_ref, $args_ref) = @_;

	my $opts = $$opts_ref;

	return unless defined $opts;

	unless (ref($opts) eq 'HASH') { #allow $opts hashref to be omitted

		unshift @$args_ref, $opts;
		$$opts_ref = {};

		$opts_ref = \$opts;
	}
}

1;



1;

