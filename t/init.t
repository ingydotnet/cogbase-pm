# CogBase::Store->new(root => $dir)->init() creates a new cogbase

use Test::More tests => 8;
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
    config.yaml
    node
    index
    cache
    cogbase
    cogbase/config
    cogbase/objects
    .gitignore
);

END {
    rmtree $cogbase_root;
}
