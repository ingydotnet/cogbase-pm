package CogBase::Schema;
use Mouse;

extends 'CogBase::Node';

has type => ( is => 'ro' );
has base => ( is => 'ro' );
has fields => ( is => 'ro' );

package CogBase::Schema::Field;
use Mouse;

has name => ( is => 'ro' );
has type => ( is => 'ro' );
has list => ( is => 'ro' );
has optional => ( is => 'ro' );

1;
