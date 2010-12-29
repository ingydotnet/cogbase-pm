package CogBase::Store;
use Mouse;
use Git::Wrapper;
use Digest::MD5;
use Convert::Base32;
use IO::All;
use Time::ParseDate;
use CogBase::Schema;

use XXX;

has root => ( is => 'ro', required => 1 );
has git => ( is => 'ro', builder => sub {
    my $self = shift;
    Git::Wrapper->new($self->root);
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
    io("$root/cache")->mkdir or die;
    io->link("$root/cogbase")->symlink(".git");

    my $uuid = $self->_uuid;
    io("$root/cogbase.yaml")->print(<<"...");
cogbase: 0.0.1
uuid: $uuid
base_uri: http://127.0.0.1:1234/
...

    io("$root/.gitignore")->print(<<"...");
.gitignore
cogbase
cache
...

    $self->_git_cmd('init');
}

sub _git_cmd {
    my ($self, $cmd, @args) = @_;
    $self->git->$cmd(@args);
}

BEGIN { srand() }
sub _uuid {
    my $self = shift;
    while (1) {
        my $id = uc Convert::Base32::encode_base32(
            join "", map { pack "S", int(rand(65536)) } 1..8
        ); 
        return $id if $id =~ /^((?:[A-Z][2-7]|[2-7][A-Z])..)(.*)/;
    }
}

sub _node_to_text {
    my $self = shift;
    my $node = shift;
    my $type = $node->Type;
    my $schema = $self->_get_schema_node($type)
        or die;
    my $fields = $schema->fields();
    my $text = '';
    for my $field (@$fields) {

    }
    return XXX $text;
}

sub _text_to_node {
}

# adds a new node to the cogbase of a given type.
# the node must be 'put' to actually store it.
sub add {
    my $self = shift;
    my $type = shift;
    my $schema = $self->schemata->{$type} ||= $self->_get_schema_node($type);
    my ($id, $uuid) = $self->new_id;
    my $node = $schema->class->new( Id => $id, UUID => $uuid, Rev => 0,
    Type => $type, @_, ); $self->write($node); return $node; }

# retrieve a node object from an id. return undef if not found.
sub get {
    my $self = shift;
    my $id = shift;
    my $dir = $self->node_dir($id);
    return unless -e $dir;
    my $hash = $self->read($id);
    my $type = $hash->{Type};
    my $schema = $self->schemata->{$type} ||= $self->_get_schema_node($type);
    my $node = $schema->class->new(%$hash);
    return $node;
}

# store a new revision of an existing node
sub put {
    my $self = shift;
    my $node = shift;
    my $prev = $self->get($node->Id);
    XXX $prev if not defined $prev->Rev;
    $node->Rev($prev->Rev + 1);
    # bump rev number
    $self->lock;
    $self->write($node);
#     $self->index($node);
    $self->commit($node);
    $self->unlock;
}

sub read {
    my $self = shift;
    my $id = shift;
    my $node = {};
    my $dir = $self->node_dir($id);
    for my $io (io->dir($dir)->all) {
        $node->{$io->filename} = $io->all;
    }
    return $node;
}

sub write {
    my $self = shift;
    my $node = shift;
    my $time = $node->Time;
    my $id = $node->Id or die;
    my $dir = $self->node_dir($id);
    for my $key (keys %$node) {
        my $value = $node->{$key};
        if (not defined $value) {
            next;
        }
        if (not ref($value)) {
            my $file = io->file("$dir/$key");
            $file->print($value);
            $file->close;
            $file->utime($time);
        }
        elsif (ref($value) eq 'ARRAY') {
            my $i = 0;
            for (; $i < @$value; $i++) {
                io->file("$dir/$key/$i")->assert->print($value->[$i]);
            }
            io->link("$dir/$key/_")->assert->symlink("$i");
        }
        else {
            die;
        }
    }
}

sub commit {
    my $self = shift; 
    my $commit = shift; 
    $ENV{GIT_AUTHOR_NAME} =
        $ENV{GIT_COMMITTER_NAME} = $commit->{name};
    $ENV{GIT_AUTHOR_EMAIL} =
        $ENV{GIT_COMMITTER_EMAIL} = $commit->{email};
    $ENV{GIT_AUTHOR_DATE} = $commit->{time};
    $ENV{GIT_COMMITTER_DATE} = $commit->{time};
}

sub node_dir {
    my $self = shift;
    my $id = shift;
    return join '/', $self->root, 'node', (($id) =~ /(..)/g), '_';
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
