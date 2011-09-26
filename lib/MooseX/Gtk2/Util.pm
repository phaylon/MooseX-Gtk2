use strictures 1;

# ABSTRACT: Internal utility functions

package MooseX::Gtk2::Util;

use MooseX::Gtk2::Init;
use Moose ();
use Moose::Object;
use Moose::Util::MetaRole;
use Class::Load             qw( is_class_loaded load_class );

use syntax qw( simple/v2 );
use namespace::clean;

use Sub::Exporter -setup => {
    exports => [qw( membrane_class_of )],
};

my $MembraneMeta = 'Moose::Meta::Class';
my %MembraneRegistry;

fun membrane_class_of ($orig_class) {
    load_class($orig_class)
        unless is_class_loaded($orig_class);
    return $orig_class
        if $orig_class->can('meta');
    return $MembraneRegistry{$orig_class}
        ||= make_membrane_class($orig_class);
}

fun membrane_name_of ($orig_class) {
    return sprintf 'MooseX::Gtk2::MEMBRANE::%s', $orig_class;
}

fun make_membrane_class ($orig_class) {
    my $plain = make_plain_membrane_meta($orig_class);
    my $meta  = setup_membrane_meta_roles($plain);
    sync_attributes($meta, $orig_class);
    sync_signals($meta, $orig_class);
    finalize_membrane_meta($meta);
    return $meta->name;
}

fun setup_membrane_meta_roles ($meta) {
    return Moose::Util::MetaRole::apply_metaroles(
        for             => $meta,
        class_metaroles => {
            instance    => ['MooseX::Gtk2::MetaRole::Instance'],
            class       => [qw(
                MooseX::Gtk2::MetaRole::Class::WrapAccessors
                MooseX::Gtk2::MetaRole::Class::Destruction
                MooseX::Gtk2::MetaRole::Class::SignalHandling
            )],
        },
    );
}

fun sync_signals ($meta, $source) {
    for my $signal (Glib::Type->list_signals($source)) {
        (my $name = $signal->{signal_name}) =~ s/-/_/g;
        $meta->add_signal($name);
    }
}

fun sync_attributes ($meta, $source) {
    for my $property ($source->list_properties) {
        (my $name = $property->{name}) =~ s{-}{_}g;
        my %flag = map { ($_ => 1) } @{$property->{flags}||[]};
        $meta->add_attribute
            ($name,
            is                      => 'bare',
            is_generally_readable   => $flag{readable},
            is_generally_writable   => $flag{writable},
            traits                  => [qw(
                MooseX::Gtk2::MetaRole::Attribute::Access
            )],
            $source->can("get_$name")
                ? (reader => "get_$name")
                : (),
            $source->can("set_$name")
                ? (writer => "set_$name")
                : (),
        );
    }
    return 1;
}

fun finalize_membrane_meta ($meta) {
    my ($parent) = $meta->superclasses;
    $meta->install_accessor_wrappers;
    ensure_compatibility_methods($meta);
    $meta->make_immutable(
        replace_constructor => 1,
        replace_destructor  => 0,
    );
    Glib::Type->register_object(
        $parent,
        $meta->name,
    );
    return 1;
}

fun ensure_compatibility_methods ($meta) {
    $meta->add_method($_ => Moose::Object->can($_))
        for qw( BUILDALL BUILDARGS );
}

fun make_plain_membrane_meta ($orig_class) {
    return $MembraneMeta->create(
        membrane_name_of($orig_class),
        superclasses => [$orig_class],
    );
}

1;
