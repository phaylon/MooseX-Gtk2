use strictures 1;

package MooseX::Gtk2;

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use syntax qw( simple/v2 );
use namespace::clean;

method init_meta ($class: %args) {
    Moose->init_meta(%args);
    Moose::Util::MetaRole::apply_metaroles(
        for             => $args{for_class},
        class_metaroles => {
            class => [qw(
                MooseX::Gtk2::MetaRole::Class::MakeGObject
                MooseX::Gtk2::MetaRole::Class::Destruction
            )],
            attribute => [qw(
                MooseX::Gtk2::MetaRole::Attribute::Register
            )],
        },
    );
}

Moose::Exporter->setup_import_methods(
    also        => [qw( Moose )],
    with_meta   => [qw( register )],
);

fun register ($meta) { $meta->make_gobject }

1;
