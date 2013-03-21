use Test::More;
use strict;

BEGIN {
    eval { require DBD::SQLite; 1 }
        or plan skip_all => 'DBD::SQLite required';
    eval { DBD::SQLite->VERSION >= 1 }
        or plan skip_all => 'DBD::SQLite >= 1.00 required';

    plan tests => 16;
    use_ok('DBIx::Foo');
}

# In memory database! No file permission troubles, no I/O slowness.
# http://use.perl.org/~tomhukins/journal/31457 ++

my $db = DBIx::Foo->connect('dbi:SQLite:dbname=:memory:');

ok($db);

ok($db->do('CREATE TABLE xyzzy (ID INTEGER PRIMARY KEY, FOO, bar, baz)'));

my $data = [
 [1, 'a', 'abc', 'x'],
 [2, 'a', 'bcd', 'x'],
 [3, 'a', 'cde', 'x'],
 [4, 'a', 'def', 'x'],
 [5, 'b', 'abc', 'x'],
 [6, 'b', 'bcd', 'x'],
 [7, 'b', 'cde', 'x'],
 [8, 'b', 'def', 'x'],
];

foreach my $row (@$data) {
	ok($db->do('INSERT INTO xyzzy (ID, FOO, bar, baz) values (?, ?, ?, ?)', @$row));
}

my $query = $db->search_query('select * from xyzzy');

$query->addFilter('FOO', 'a');
$query->addSearch('bar', 'd');
$query->addSort('ID', 'desc');

my $result = $query->DoSearch;

is(scalar @$result, 3, "3 rows Returned");
is($result->[0]->{ID}, 4);
is($result->[1]->{ID}, 3);
is($result->[2]->{ID}, 2);

ok($db->disconnect);
