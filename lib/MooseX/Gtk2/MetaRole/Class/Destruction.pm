use strictures 1;

package MooseX::Gtk2::MetaRole::Class::Destruction;
use Moose::Role;
use Glib;

use syntax qw( simple/v2 );
use namespace::autoclean;

before make_immutable {
    my $handler = $self->name->can('DEMOLISH');
    $self->add_method(FINALIZE_INSTANCE => $handler)
        if $handler;
}

1;
