use Test::More;
use Log::Any::Test;
use Log::Any qw($log);
use strict;

use Data::Dumper;

BEGIN {
    eval { require DBD::SQLite; 1 }
        or plan skip_all => 'DBD::SQLite required';
    eval { DBD::SQLite->VERSION >= 1 }
        or plan skip_all => 'DBD::SQLite >= 1.00 required';

    plan tests => 10;
    use_ok('DBIx::Foo');
}

# In memory database! No file permission troubles, no I/O slowness.
# http://use.perl.org/~tomhukins/journal/31457 ++

my $db = DBIx::Foo->connect('dbi:SQLite:dbname=:memory:');

ok($db);

ok($db->do('CREATE TABLE xyzzy (FOO, bar, baz)'));

$log->contains_ok(qr/CREATE TABLE xyzzy/, "CREATE TABLE was logged");

ok($db->do('INSERT INTO xyzzy (FOO, bar, baz) VALUES (?, ?, ?)', 'a', 'b', 'c'));

$log->contains_ok(qr/INSERT INTO xyzzy/, "INSERT was logged");
$log->contains_ok(qr/Got insertid\: 1/, "insertid was logged");

my $sql = 'SELECT * FROM xyzzy ORDER BY FOO';

my @row = $db->selectrow_array($sql);

is_deeply(\@row, [ qw(a b c) ]);

$log->contains_ok(qr/SELECT \* FROM xyzzy/, "SELECT was logged");

ok($db->disconnect);

