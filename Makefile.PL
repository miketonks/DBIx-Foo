
use inc::Module::Install;
  
# Define metadata
name           'DBIx-Foo';

author        'Mike Tonks <miket@cpan.org>';
version_from  'lib/DBIx/Foo.pm';
license       'perl', 'gpl';
 
# Specific dependencies
requires       'DBI'  => 0;
requires       'Exporter'  => 0;
requires       'Log::Any'  => 0;

#manifest_skip;

#no_index directory => 'sample';

WriteAll;
