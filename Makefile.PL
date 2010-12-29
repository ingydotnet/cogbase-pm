use inc::Module::Install;

name            'CogBase';
all_from        'lib/CogBase.pm';
readme_from;
version_check;
ack_xxx;
# repository 'git://github.com/ingydotnet/cogbase-pm.git';

requires 'Mouse';
requires 'YAML::XS';
requires 'Git::Wrapper';
requires 'Digest::MD5';
requires 'Convert::Base32';
requires 'IO::All';
requires 'Time::ParseDate';

# use_testml;

install_script 'bin/cogbase';

WriteAll;
