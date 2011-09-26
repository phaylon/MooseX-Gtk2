use strictures 1;

# ABSTRACT: Class metaclass signal handling

package MooseX::Gtk2::MetaRole::Class::SignalHandling;
use Moose::Role;

use syntax qw( simple/v2 );
use namespace::autoclean;

around add_signal (@args) {
    my $signal = $self->$orig(@args);
    $signal->attach_to_class($self);
    return $signal;
}

around remove_signal (@args) {
    my $signal = $self->$orig(@args);
    $signal->detach_from_class;
    return $signal;
}

with qw( MooseX::Gtk2::MetaRole::SignalHandling );

1;
