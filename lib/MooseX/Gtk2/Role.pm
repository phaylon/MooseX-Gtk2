use strictures 1;

package MooseX::Gtk2::Role;

use Moose::Role ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use MooseX::Gtk2::Sugar::Signals ();
use MooseX::Gtk2::Init;

use syntax qw( simple/v2 );
use namespace::clean;

method init_meta ($class: %args) {
    Moose::Role->init_meta(%args);
    Moose::Util::MetaRole::apply_metaroles(
        for             => $args{for_class},
        role_metaroles  => {
            role => [qw(
                MooseX::Gtk2::MetaRole::SignalHandling
            )],
            applied_attribute => [qw(
                MooseX::Gtk2::MetaRole::Attribute::Register
                MooseX::Gtk2::MetaRole::Attribute::Access
            )],
            attribute => [qw(
                MooseX::Gtk2::MetaRole::Attribute::Register
                MooseX::Gtk2::MetaRole::Attribute::Access
            )],
            application_to_role => [qw(
                MooseX::Gtk2::MetaRole::Application::ApplySignals
            )],
            application_to_class => [qw(
                MooseX::Gtk2::MetaRole::Application::ApplySignals
            )],
        },
    );
}

Moose::Exporter->setup_import_methods(
    also => [qw( Moose::Role MooseX::Gtk2::Sugar::Signals )],
);

1;
