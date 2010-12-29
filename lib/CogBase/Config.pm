package CogBase::Config;
use Mouse;

has cogbase_version => ( is => 'ro' );
has cogbase_uuid => ( is => 'ro' );
has config_file => ( is => 'ro' );

1;
