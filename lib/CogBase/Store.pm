package CogBase::Store;
use Mouse;
use Git::Wrapper;
use Digest::MD5;
use Convert::Base32;
use IO::All;

use XXX;

has root => (is => 'ro', required => 1);
has git => (is => 'ro', builder => sub {
    my $self = shift;
    Git::Wrapper->new($self->root);
});

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

    my $uuid = $self->_uuid;
    io("$root/config.yaml")->print(<<"...");
cogbase: 0.0.1
uuid: $uuid
base_uri: http://127.0.0.1:1234/
...

    io("$root/.gitignore")->print(<<"...");
.gitignore
cogbase/
cache/
...

    $self->_git_cmd('init');
}

sub _git_cmd {
    my ($self, $cmd, @args) = @_;
    local $ENV{GIT_DIR} = 'cogbase';
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

sub add {
}

sub import {
}

sub export {
}

sub branch {
}

sub merge {
}

sub get {
}

sub find {
}

sub store {
    my $self = shift;
    my $node = shift;
    $self->validate($node);
    # Explode the node to disk
    $self->git->add('.');
    $self->git->commit();
}

sub fetch {
}

1;
