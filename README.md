# DBIx-Foo

Simple Database Wrapper and Helper Functions.  Easy DB integration without the need for an ORM.

## SimpleQuery

Simple shortcuts for common operations.

```perl
my $dbh = DBIx::Foo->connect(...) # or ->new

my $rows = $dbh->selectall("select * from test");

my $row = $dbh->selectrow("select * from test where ID = ?", 1); # alias for selectrow_hashref
```

## SearchQuery

For building complex select queries with filters, pagination, order, and support for rowcount query (total rows).

```perl
# search with pagination
my $query = $dbh->search_query('select * from test', 1, 100);

$query->addFilter('type', $type);
$query->addFilter('!id',  $id);

$query->addSort($sort);

# Perform the search
my $rows = $query->DoSearch;
my $total = $query->GetRowcount;
```

## UpdateQuery

This can be used to build a query for writing to the database.  First an insert statement:

```perl

my $query = $dbh->update_query('test');

$query->addField(Name => 'Foo');
$query->addField(Desc => 'Bar');

my $newid = $query->DoInsert;

And with very similar syntax, an update statement:

my $query = $dbh->update_query('test');

$query->addKey(ID => $newid);
$query->addField(Name => 'Fu');
$query->addField(Desc => 'Baz');

$query->DoUpdate;

This works nicely with data in a hash, which can be interated and used to update or insert as appropriate, based the existence of a key field:

my $data = {
  Name => 'Foo',
  Desc => 'Bar',
};

foreach my $field (key %$data) {

  $query->addField($field => $data->{$field}) if $data->{$field};
}

if (my $id = $data->{ID}) {

  # updating
  $query->addKey(ID => $id);

  $query->DoUpdate;
}
else {

  # inserting
  my $newid = $query->DoInsert;
}
```

INSTALLATION

To install this module type the following:

    perl Makefile.PL
    make
    make test
    make install

Or use CPAN / cpanm / carton to automate the process.

PREREQUISITES

    DBI
    Exporter
    Log::Any
