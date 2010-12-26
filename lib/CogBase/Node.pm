package CogBase::Node;
use Mouse;

has Id => (is => 'ro');
has Rev => (is => 'ro');
has UUID => (is => 'ro');
has Type => (is => 'ro');
has Time => (is => 'ro');
has User => (is => 'ro');
has Tags => (is => 'ro');

1;
