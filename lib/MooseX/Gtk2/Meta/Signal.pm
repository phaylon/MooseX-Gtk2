use strictures 1;

package MooseX::Gtk2::Meta::Signal;
use Moose;
use MooseX::Types::Common::String   qw( NonEmptySimpleStr );
use MooseX::Types::Moose            qw( CodeRef Int Bool );
use MooseX::Gtk2::Types             qw( SignalRunType );

use syntax qw( simple/v2 );
use namespace::autoclean;

has name => (
    is          => 'ro',
    isa         => NonEmptySimpleStr,
    required    => 1,
);

has associated_class => (
    is          => 'ro',
    isa         => 'Moose::Meta::Class',
    weak_ref    => 1,
    writer      => 'attach_to_class',
    clearer     => 'detach_from_class',
);

has arity => (
    is          => 'ro',
    isa         => Int,
    required    => 1,
    default     => 0,
);

has run_type => (
    is          => 'ro',
    isa         => SignalRunType,
    init_arg    => 'runs',
    default     => 'last',
);

has handler => (
    is          => 'ro',
    isa         => NonEmptySimpleStr | CodeRef,
    predicate   => 'has_handler',
);

has does_restart => (
    is          => 'ro',
    isa         => Bool,
    default     => 0,
    init_arg    => 'restart',
);

has accumulator => (
    is          => 'ro',
    isa         => CodeRef,
    init_arg    => 'collect',
    predicate   => 'has_accumulator',
);

method as_signal_spec {
    return {
        class_closure   => $self->_glib_class_closure,
        flags           => $self->_glib_flags,
        param_types     => $self->_glib_param_types,
        $self->run_type ne 'first'
            ? (return_type  => 'Glib::Scalar')
            : (),
        $self->has_accumulator
            ? (accumulator  => $self->accumulator)
            : (),
    };
}

method _glib_class_closure {
    return sub { undef }
        unless $self->has_handler;
    my $handler = $self->handler;
    return $handler
        if ref $handler;
    my $class  = $self->associated_class;
    return method (@args) { $self->$handler(@args) };
}

method _glib_flags {
    return [
        qw( action ),
        $self->does_restart ? 'no-recurse' : (),
        join '-', run => $self->run_type,
    ];
}

method _glib_param_types {
    return [
        $self->associated_class->name,
        ('Glib::Scalar') x $self->arity,
    ];
}

1;
