use strictures 1;

package MooseX::Gtk2::MetaRole::Attribute::Access;
use Moose::Role;
use MooseX::Types::Moose qw( Bool );

use syntax qw( simple/v2 );
use namespace::autoclean;

has is_generally_readable => (
    is          => 'ro',
    isa         => Bool,
);

has is_generally_writable => (
    is          => 'ro',
    isa         => Bool,
);

before _process_is_option ($class: $name, $options) {
    my $is = $options->{is} || '';
    if ($is eq 'rw') {
        $options->{is_generally_readable} = 1;
        $options->{is_generally_writable} = 1;
    }
    elsif ($is eq 'ro') {
        $options->{is_generally_readable} = 1;
    }
}

method _build_is_readable { ($self->reader or $self->accessor) ? 1 : 0 }
method _build_is_writable { ($self->writer or $self->accessor) ? 1 : 0 }

1;
