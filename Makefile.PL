use inc::Module::Install;

name            'CogBase';
all_from        'lib/CogBase.pm';
readme_from;
version_check;
ack_xxx;
repository 'git://github.com/ingydotnet/cogbase-pm.git';

requires 'Mouse';

use_testml;

clean_files 't/data';

WriteAll;
