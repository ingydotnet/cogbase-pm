use TestML -run, -bridge => 't::Bridge.pm';

__DATA__
%TestML: 1.0

*command.run().pathsExist(*paths);

=== Init a CogBase
--- command: init
--- files
CogBase/
cache/
index/
node/
tmp/
cogbase.yaml
