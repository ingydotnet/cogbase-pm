package CogBase::Schema;
use Mouse;

my $classes = {};

extends 'CogBase::Type::Node';

use XXX;

has type => ( is => 'ro' );
has base => ( is => 'ro' );
has fields => ( is => 'ro', default => sub{[]} );
has class => ( is => 'ro', builder => sub {
    my $self = shift;
    "CogNode::Type::" . $self->type;
});

sub BUILD {
    my ($self, $args) = @_;
    for (@{$args->{adds}}) {
        push @{$self->fields}, CogBase::Schema::Field->new(%$_);
    }
}

sub perl {
    my $self = shift;
    my $perl = <<"...";
package CogNode::Type::$self->{type};
use Mouse;
extends 'CogBase::Type::$self->{base}';
...
    for my $field (@{$self->fields}) {
        $perl .= <<"...";
has $field->{name} => ( is => 'rw' );
...
    }
    $perl .= <<"...";
1;
...
    return $perl;
}

package CogBase::Schema::Field;
use Mouse;

has name => ( is => 'ro' );
has type => ( is => 'ro' );
has size => ( is => 'ro' );
has enum => ( is => 'ro' );
has default => ( is => 'ro' );

1;
