package CogBase::Type::CogNode;
use Mouse;

extends 'CogBase::Type::Node';

has Name => ( is => 'rw' );
has Tag => ( is => 'rw' );
has Text => ( is => 'rw' );
has Url => ( is => 'rw' );

1;
