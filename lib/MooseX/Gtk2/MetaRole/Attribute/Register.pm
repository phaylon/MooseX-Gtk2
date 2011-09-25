use strictures 1;

package MooseX::Gtk2::MetaRole::Attribute::Register;
use Moose::Role;
use Glib;

use syntax qw( simple/v2 );
use namespace::autoclean;

method _process_is_option ($class: $name, $options) {
    my $is = $options->{is};
    return unless defined $is;
    return if $is eq 'bare';
    if ($is eq 'ro') {
        $options->{reader} ||= "get_$name";
    }
    elsif ($is eq 'rw') {
        $options->{reader} ||= "get_$name";
        $options->{writer} ||= "set_$name";
    }
    else {
        $class->throw_error("Unknown 'is' option: '$is'");
    }
}

method as_param_spec {
    return Glib::ParamSpec->scalar(
        $self->name,
        $self->nickname,
        $self->documentation || '',
        [qw( readable writable )],
    );
}

method nickname {
    return join ' ', map ucfirst lc, split m/_/, $self->name;
}

1;
