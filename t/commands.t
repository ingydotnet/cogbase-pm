use Test::More skip_all => 'not yet';
use TestML -run, -bridge => 't::Bridge';

__DATA__
%TestML 1.0

True.OK;
# *command.run().pathsExist(*paths);

=== Init a CogBase
--- command: init
--- files
CogBase/
cache/
index/
node/
tmp/
cogbase.yaml
