use strictures 1;

# ABSTRACT: Handle DEMOLISH emulation

package MooseX::Gtk2::MetaRole::Class::Destruction;
use Moose::Role;
use Glib;
use Devel::GlobalDestruction;

use syntax qw( simple/v2 );
use namespace::autoclean;

before make_immutable {
    my $handler = $self->get_method('DEMOLISH');
    return unless $handler;
    my $code = $handler->body;
    $self->add_method(FINALIZE_INSTANCE => method ($instance:) {
        $instance->$code(Devel::GlobalDestruction::in_global_destruction);
    });
}

1;
