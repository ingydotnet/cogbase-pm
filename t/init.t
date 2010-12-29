# CogBase::Store->new(root => $dir)->init() creates a new cogbase

use Test::More tests => 9;
use strict;
use File::Path;
use CogBase::Store;

my $cogbase_root;
BEGIN {
    $cogbase_root = 't/cogbase1';
    rmtree $cogbase_root;
}

my $s = CogBase::Store->new(root => $cogbase_root);

$s->init;

ok(-e, "$_ exists") for map "$cogbase_root/$_", qw(
    cogbase.yaml
    node
    index
    cache
    cogbase
    cogbase/config
    cogbase/objects
    .git
    .gitignore
);

END {
    rmtree $cogbase_root;
}
