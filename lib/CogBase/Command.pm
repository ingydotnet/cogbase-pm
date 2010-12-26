package CogBase::Command;
use Mouse;

use Getopt::Long;
use Cwd;
use File::Path;
use Capture::Tiny qw(capture);

has config => ( is => 'ro');
has args => ( is => 'ro');
has command => ( is => 'ro');
has base => ( is => 'ro');
has home => ( is => 'ro');

my $options = [qw(base view file editor)];

sub init {
    my $self = shift;

    $self->{command} =
        (@_ && $_[0] !~ /^-/) && shift(@_) ||
        $ENV{COMMAND} || 'shell';

    local @ARGV = @_;
    GetOptions(
        'base=s' => \$self->{base},
        'editor=s' => \$self->{editor},
    );
    $self->{args} = [@ARGV];

    $self->{base} ||= $ENV{COGBASE_BASE} || '.';
    $self->{editor} ||= $ENV{COGBASE_EDITOR} || $ENV{EDITOR} || undef;
};

sub run {
    my $self = shift;
    $self->setup();
    $self->validate();
    my $method = "handle_" . $self->{command};
    $self->$method();
}

sub setup {
    $ENV{GIT_DIR} = 'CogBase';
}

sub validate {
    my $self = shift;
    my $command = $self->command
      or die "No cogbase command given";
    if ($command eq 'shell') {
    }
    elsif ($command eq 'create') {
        if (@{$self->args}) {
            $self->{base} = shift @{$self->args};
        }
    }
    elsif ($command eq 'add') {
    }
    elsif ($command eq 'fetch') {
    }
    elsif ($command eq 'store') {
    }
    elsif ($command eq 'query') {
    }
    elsif ($command eq 'edit') {
    }
    else {
        die "'$command' is not a valid cogbase command"
    }
}

sub handle_shell {
    die "...";
}

sub handle_create {
    my $self = shift;
    $self->assert_empty_base();
    $self->chdir_base();
    $self->git_init();
    $self->initial_config();
    $self->write_config();
    $self->mkdir('node');
    $self->mkdir('index');
    $self->mkdir('cache');
    $self->mkdir('tmp');
    $self->chdir_back();
}

sub handle_add {
    my $self = shift;
    die "...";
}

sub handle_fetch {
    my $self = shift;
    die "...";
}

sub handle_store {
    my $self = shift;
    die "...";
}

sub handle_query {
    my $self = shift;
    die "...";
}

sub assert_empty_base {
    my $self = shift;
    my $base = $self->base;
    if (-e $base) {
        opendir DIR, "$base"
            or die "Can't open '$base' as a directory";
        while (my $file = readdir DIR) {
            die "'$base' is not an empty directory"
                unless $file =~ /^\.\.?$/;
        }
    }
    else {
        File::Path::mkpath($base)
            or die "Can't mkdir '$base'";
    }
}

sub chdir_base {
    my $self = shift;
    $self->{home} = Cwd::cwd();
    chdir($self->base)
      or die "Can't chdir to '$self->base'";
}

sub chdir_back {
    my $self = shift;
    chdir($self->home)
      or die "Can't chdir to '$self->home'";
}

sub git_init {
    my $self = shift;
    $self->run_command(qw(git init));
}

sub run_command {
    my $self = shift;
    my @cmd = @_;

    my ($out, $err) = capture {
        system("@cmd") == 0
          or die "Failed to run command: '${\ join(' ', @cmd)}': $?";
    };
}

sub initial_config {
    my $self = shift;
    $self->{config} = {
        uuid => $self->gen_uuid,
    };
}

sub write_config {
    my $self = shift;
    my $config = $self->config;
    my $yaml = <<"...";
# CogBase Configuration File

uuid: $config->{uuid}
...
    open CONFIG, "> cogbase.yaml"
      or die "Can't open 'cogbase.yaml' for output";
    print CONFIG $yaml;
    close CONFIG;
}

sub gen_uuid {
    my $self = shift;
    return uc(
        Convert::Base32::encode_base32(
            Digest::MD5::md5(
                Data::UUID->new->create_str()
            )
        )
    );
}

sub mkdir {
    my $self = shift;
    my $dir = shift;
    mkdir($dir)
      or die "Couldn't mkdir '$dir'";
}
