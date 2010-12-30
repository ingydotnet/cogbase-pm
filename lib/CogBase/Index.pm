package CogBase::Index;
use Mouse;
use IO::All;

has root => ( is => 'ro' );

sub schema {
    my $self = shift;
    my $type = shift;
    my $root = $self->root;
    my $io = io->link("$root/index/schema/$type");
    return @_ ? $io->symlink(shift) : $io->readlink;
}

1;
