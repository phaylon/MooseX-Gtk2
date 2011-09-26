use strictures 1;

# ABSTRACT: Glib-aware instance management

package MooseX::Gtk2::MetaRole::Instance;
use Moose::Role;
use Glib;
use Data::Dump qw( pp );

use syntax qw( simple/v2 );
use namespace::autoclean;

around create_instance {
    return Glib::Object::new($self->associated_metaclass->name);
}

around inline_create_instance ($var_class) {
    return sprintf q{Glib::Object::new(%s)}, $var_class;
}

around get_slot_value ($instance, $name) {
    my ($value) = Glib::Object::get_property($instance, $name);
    return $value;
}

around set_slot_value ($instance, $name, $value) {
    Glib::Object::set_property($instance, $name => $value);
    return $value;
}

around inline_get_is_lvalue { 0 }

around inline_get_slot_value ($var_instance, $name) {
    return sprintf q{( ( Glib::Object::get_property(%s, %s) )[0] )},
        $var_instance,
        pp($name);
}

around inline_set_slot_value ($var_instance, $name, $var_value) {
    return sprintf q{Glib::Object::set_property(%s, %s, %s)},
        $var_instance,
        pp($name),
        $var_value;
}

1;
