use inc::Module::Install;

name            'CogBase';
all_from        'lib/CogBase.pm';

use_gloom 'CogBase::Base';
use_testml;

WriteAll;
