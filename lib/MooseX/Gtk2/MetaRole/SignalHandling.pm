use strictures 1;

# ABSTRACT: Generic signal handling

package MooseX::Gtk2::MetaRole::SignalHandling;
use Moose::Role;
use MooseX::Types::Moose    qw( HashRef CodeRef );

use aliased 'MooseX::Gtk2::Meta::Signal';

use syntax qw( simple/v2 );
use namespace::autoclean;

has signals => (
    traits      => [qw( Hash )],
    isa         => HashRef[ Signal ],
    required    => 1,
    lazy        => 1,
    default     => sub { {} },
    handles     => {
        add_signal          => 'set',
        has_signal          => 'exists',
        get_signal          => 'get',
        get_signal_list     => 'keys',
        remove_signal       => 'delete',
    },
);

has signal_overrides => (
    traits      => [qw( Hash )],
    isa         => HashRef[ CodeRef ],
    required    => 1,
    lazy        => 1,
    default     => sub { {} },
    handles     => {
        add_signal_override         => 'set',
        has_signal_override         => 'exists',
        get_signal_override         => 'get',
        get_signal_override_list    => 'keys',
        remove_signal_override      => 'delete',
    },
);

around add_signal (@args) {
    my $signal;
    if (@args == 1 and ref $args[0]) {
        ($signal) = @args;
    }
    else {
        my ($name, %options) = @args;
        $signal = Signal->new(%options, name => $name);
    }
    $self->throw_error(sprintf
        q{Signal '%s' is already defined on %s},
        $signal->name,
        $self->name,
    ) if $self->has_signal($signal->name);
    $self->$orig($signal->name, $signal);
    return $signal;
}

before add_signal_override ($name) {
    $self->throw_error(sprintf
        q{Signal '%s' already overridden on %s},
        $name,
        $self->name,
    ) if $self->has_signal_override($name);
    $self->throw_error(sprintf
        q{Cannot ovverride signal '%s' in %s since it is defined in it},
        $name,
        $self->name,
    ) if $self->has_signal($name);
}

1;
