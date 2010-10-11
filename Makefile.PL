use inc::Module::Install;

name            'CogBase';
all_from        'lib/CogBase.pm';
readme_from;
version_check;
ack_xxx;

use_gloom 'CogBase::OO';
use_testml;

WriteAll;
