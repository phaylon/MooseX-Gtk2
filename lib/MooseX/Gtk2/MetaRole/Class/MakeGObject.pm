use strictures 1;

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
    $self->install_value_management;
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

method install_value_management {
#    warn "WRAPPERS";
#    $self->add_method(GET_PROPERTY => $self->_value_getter_callback);
#    $self->add_method(SET_PROPERTY => $self->_value_setter_callback);
}

method _value_setter_callback {
    return method ($prop, $value) {
        my $name = $prop->get_name;
        warn "SET $name TO $value";
        my $attr = $self->meta->find_attribute_by_name($name);
        return $self->{$name} = $value
            unless $attr->has_type_constraint;
        my $tc = $attr->type_constraint;
        return $self->{$name} = $tc->assert_coerce($value)
            if $attr->should_coerce and $tc->has_coercion;
        $tc->assert_valid($value);
        return $self->{$name} = $value;
    };
}

method _value_getter_callback {
    return method ($prop) {
        my $name = $prop->get_name;
        warn "GET $name";
        if (exists $self->{$name}) {
            return $self->{$name};
        }
        my $attr = $self->meta->find_attribute_by_name($name);
        return undef
            unless $attr->is_lazy;
        if ($attr->has_default) {
            my $value = $self->{$name} = $attr->default($self);
            $self->notify($name);
            return $value;
        }
        elsif ($attr->has_builder) {
            my $builder = $attr->builder;
            my $value = $self->{$name} = $self->$builder;
            $self->notify($name);
            return $value;
        }
        return undef;
    };
}

1;
