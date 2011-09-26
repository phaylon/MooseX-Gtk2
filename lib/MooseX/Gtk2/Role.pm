use strictures 1;

# ABSTRACT: Declare roles for MooseX::Gtk2 classes

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

__END__

=head1 SYNOPSIS

    package MyRole;
    use MooseX::Gtk2::Role;

    requires qw( _handle_an_event );

    has an_attribute => (is => 'rw');

    signal an_event => (handler => '_handle_an_event');

    sub _handle_an_event { ... }

    with qw( MyOtherRole );

    1;

=head1 DESCRIPTION

This is a companion extension to L<MooseX::Gtk2> that allows you to declare
roles instead of classes.

The main difference is that there is no L<extends|MooseX::Gtk2/extends> and
you don't need to L<register|MooseX::Gtk2/register> anything. Everything
else works the same as L<Moose::Role>.

=head1 SEE ALSO

=over

=item * L<MooseX::Gtk2>

=back

=cut
