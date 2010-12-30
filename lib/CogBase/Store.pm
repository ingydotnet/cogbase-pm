package CogBase::Store;
use Mouse;
use Git::Wrapper;
use Digest::MD5;
use Convert::Base32;
use IO::All;
use Time::ParseDate;
use CogBase::Schema;
use CogBase::Index;
use YAML::XS;

use XXX;

has root => ( is => 'ro', required => 1 );
has git => ( is => 'ro', builder => sub {
    my $self = shift;
    Git::Wrapper->new($self->root);
});
has index => ( is => 'ro', builder => sub {
    my $self = shift;
    CogBase::Index->new(root => $self->root);
});
has schemata => ( is => 'ro', default => sub{{}} );

sub init {
    my $self = shift;
    my $root = $self->root;

    die "Can't init cogbase in a non-empty directory"
        if -d $root and not io($root)->empty;
    io($root)->mkpath unless -e $root;
    die "'$root' is not a directory"
        unless -d $root;

    io("$root/node")->mkdir or die;
    io("$root/index")->mkdir or die;
    io("$root/index/schema")->mkdir or die;
    io("$root/cache")->mkdir or die;
    io->link("$root/cogbase")->symlink(".git");

    my $uuid = $self->new_uuid;
    io("$root/cogbase.yaml")->print(<<"...");
cogbase: 0.0.1
uuid: $uuid
...

    io("$root/.gitignore")->print(<<"...");
.gitignore
cogbase
cache
...

    $self->git->init();
}

sub get_schema_node {
    my $self = shift;
    my $type = shift;
    my $id = $self->index->schema($type);
    my $node = $self->get($id) or die "No Schema node for type '$type'";
    eval $node->perl or die $@;
    return $node;
}

# adds a new node to the cogbase of a given type.
# the node must be 'put' to actually store it.
sub add {
    my $self = shift;
    my $type = shift or die;
    my $schema = $self->schemata->{$type} ||= $self->get_schema_node($type);
    my ($id, $uuid) = $self->new_id_pair;
    my $node = $schema->class->new(
        Id => $id,
        UUID => $uuid,
        Rev => 0,
        Type => $type,
        @_,
    );
    $self->write($node);
    return $node;
}

sub add_schema {
    my $self = shift;
    my $type = shift or die;
    my ($id, $uuid) = $self->new_id_pair;
    my $node = CogBase::Schema->new(
        Id => $id,
        Type => 'Schema',
        type => $type,
        Rev  => 0,
        UUID => $uuid,
        @_,
    );
    $self->write($node);
    return $node;
}

# retrieve a node object from an id. return undef if not found.
sub get {
    my $self = shift;
    my $id = shift or die;
    my $dir = $self->node_dir($id);
    return unless -e $dir;
    my $hash = $self->read($id);
    my $type = $hash->{Type};
    return $hash if $type eq 'Schema';
    my $schema = $self->schemata->{$type} ||= $self->get_schema_node($type);
    my $node = $schema->class->new(%$hash);
    return $node;
}

# store a new revision of an existing node
sub put {
    my $self = shift;
    my $node = shift;
    my $prev = $self->get($node->Id);
    $node->Rev($prev->Rev + 1);
    $self->lock;
    $self->write($node);
    $self->write_index($node);
    $self->commit($node);
    $self->unlock;
}

sub write_index {
    my $self = shift;
    my $node = shift;
    if ($node->Type eq 'Schema') {
        $self->index->schema($node->type, $node->Id);
    }
}

BEGIN { srand() }
# Upper cased base32 128bit random number.
sub new_uuid {
    my $self = shift;
    while (1) {
        my $id = uc Convert::Base32::encode_base32(
            join "", map { pack "S", int(rand(65536)) } 1..8
        ); 
        return $id if $id =~ /^(?:[A-Z][2-7]|[2-7][A-Z])/;
    }
}

sub new_id_pair {
    my $self = shift;
    while (1) {
        my $uuid = $self->new_uuid;
        my $id = substr($uuid, 0, 4);
        my $dir = $self->node_dir($id);
        next if -e $dir;
        io->dir($dir)->mkpath;
        return ($id, $uuid);
    }
}

sub read {
    my $self = shift;
    my $id = shift;
    my $dir = $self->node_dir($id);
    YAML::XS::LoadFile("$dir/node.yaml");
}

sub write {
    my $self = shift;
    my $node = shift;
    my $time = $node->Time;
    my $id = $node->Id or die;
    my $dir = $self->node_dir($id);
    my $blob = $node->Type eq 'Schema' ? $node : {%$node};
    YAML::XS::DumpFile("$dir/node.yaml", $blob);
    io->file("$dir/node.yaml")->utime($time);
}

sub commit {
    my $self = shift; 
    my $node = shift; 
    $ENV{GIT_AUTHOR_EMAIL} = $ENV{GIT_COMMITTER_EMAIL} = '';
    $ENV{GIT_AUTHOR_NAME} = $ENV{GIT_COMMITTER_NAME} = $node->{User};
    $ENV{GIT_AUTHOR_DATE} = $ENV{GIT_COMMITTER_DATE} = $node->{Time};

    my ($id, $rev, $type, $name) = @$node{qw(Id Rev Type Name)};
    my $title = $name->[0] || '';
    my $message = "($type) ${id}0$rev";
    $message .= " - $title" if $title;
        
    $self->git->add('.');
    $self->git->commit({all => 1, message => $message});
}

sub node_dir {
    my $self = shift;
    my $id = shift;
    return join '/', $self->root, 'node', (($id) =~ /(..)/g);
}

sub lock {}
sub unlock {}

# find a set of nodes (ids) that match a query
sub query {
    my $self = shift;
    die "query no yet implemented";
}

# import many nodes from a set of cogtext files.
sub _import {
    my $self = shift;
    die "import no yet implemented";
}

# export many nodes to a directory of cogtext files.
sub export {
    my $self = shift;
    die "export no yet implemented";
}

# copy the cogbase to edit many nodes in parallel
sub branch {
    my $self = shift;
    die "branch no yet implemented";
}

# merge a branch back to head, fixing various meta data
sub merge {
    my $self = shift;
    die "merge no yet implemented";
}

1;
