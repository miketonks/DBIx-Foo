package DBIx::Foo;

use strict;

use DBIx::Foo::SearchQuery;
use DBIx::Foo::SimpleQuery;
use DBIx::Foo::UpdateQuery;

use Log::Any qw($log);

use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(selectrow selectrow_array selectrow_hashref selectall selectall_arrayref selectall_hashref dbh_do);

our $VERSION = '0.01';

sub new {
    my ($class) = shift;
    $class->connect(@_);
}    

sub connect {
    my ($class, @arguments) = @_;

	my $self = {};
	
    if (defined $arguments[0] and UNIVERSAL::isa($arguments[0], 'DBI::db')) {
        $self->{dont_disconnect} = 1;
		$self->{dbh} = shift @arguments;
		Carp::carp("Additional arguments for $class->connect are ignored") if @arguments;
    } else {
		$arguments[3]->{PrintError} = 0
	    unless defined $arguments[3] and exists $arguments[3]{PrintError};
        $arguments[3]->{RaiseError} = 1
            unless defined $arguments[3] and exists $arguments[3]{RaiseError};
		$self->{dbh} = DBI->connect(@arguments);
    }

    return undef unless $self->{dbh};

    $self->{dbd} = $self->{dbh}->{Driver}->{Name};
    bless $self, $class;

    return $self;
}

sub disconnect {
	my $self = shift;
	$self->{dbh}->disconnect();	
}

sub dbh {
	my $self = shift;
	return $self->{dbh};
}

1;
