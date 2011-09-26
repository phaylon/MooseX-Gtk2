use strictures 1;

# ABSTRACT: Turn a MooseX::Gtk2 class into a Glib class

package MooseX::Gtk2::MetaRole::Class::MakeGObject;
use Moose::Role;
use Moose::Util         qw( does_role );
use MooseX::Gtk2::Util  qw( membrane_class_of );
use Glib;

use syntax qw( simple/v2 );
use namespace::autoclean;

has is_gobject => (
    traits      => [qw( Bool )],
    is          => 'ro',
    handles     => {
        _mark_as_gobject => 'set',
    },
);

around superclasses (@classes) {
    $self->throw_error('GObject classes do not support multiple inheritance')
        if @classes > 1;
    return $self->$orig(map membrane_class_of($_), @classes);
}

method make_gobject {
    $self->make_immutable(replace_constructor => 1, replace_destructor => 0)
        unless $self->is_immutable;
    my ($parent) = $self->superclasses;
    Glib::Type->register_object(
        $parent,
        $self->name,
        properties  => $self->_registerable_properties,
        signals     => $self->_registerable_signals,
    );
    $self->_mark_as_gobject;
    return 1;
}

method _registerable_signals {
    return {
        map { ($_->name, $_->as_signal_spec) }
        map { $self->get_signal($_) }
            $self->get_signal_list
    };
}

method _registerable_properties {
    return [
        map  { $_->as_param_spec }
        grep { does_role $_, 'MooseX::Gtk2::MetaRole::Attribute::Register' }
        map  { $self->get_attribute($_) }
            $self->get_attribute_list
    ];
}

before make_mutable {
    $self->throw_error('GObject classes cannot be made mutable again')
        if $self->is_gobject;
}

1;
