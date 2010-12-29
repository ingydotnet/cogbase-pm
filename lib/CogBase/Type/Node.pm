package CogBase::Type::Node;
use Mouse;

has Id => (is => 'ro');
has Rev => (is => 'rw');
has UUID => (is => 'rw');
has Type => (is => 'rw');
has Time => (is => 'rw');
has User => (is => 'rw');

1;
