use strictures 1;

package MooseX::Gtk2::MetaRole::Application::ApplySignals;
use Moose::Role;
use Moose::Util qw( does_role );

use syntax qw( simple/v2 );
use namespace::autoclean;

after apply ($role, $target) {
    $self->_ensure_signal_handler($_)
        for $role, $target;
    $self->apply_signals($role, $target);
    $self->apply_signal_overrides($role, $target);
}

method apply_signal_overrides ($role, $target) {
    for my $signal_name ($role->get_signal_override_list) {
        $role->throw_error(sprintf
            q{Signal override conflict for '%s' when applying %s to %s},
            $signal_name,
            $role->name,
            $target->name,
        ) if $target->has_signal_override($signal_name);
        $role->throw_werror(sprintf
            q{Signal '%s' defined in consumer %s cannot be overridden by %s},
            $signal_name,
            $target->name,
            $role->name,
        ) if $target->has_signal($signal_name);
        $target->add_signal_override(
            $signal_name,
            $role->get_signal_override($signal_name),
        );
    }
    return 1;
}

method apply_signals ($role, $target) {
    for my $signal_name ($role->get_signal_list) {
        $role->throw_error(sprintf
            q{Signal conflict for '%s' when applying %s to %s},
            $signal_name,
            $role->name,
            $target->name,
        ) if $target->has_signal($signal_name);
        $target->add_signal($role->get_signal($signal_name));
    }
    return 1;
}

method _ensure_signal_handler ($meta) {
    return undef
        if does_role($meta, 'MooseX::Gtk2::MetaRole::SignalHandling');
    $meta->throw_error(sprintf
        q{%s is not able to handle MooseX::Glib signals},
        $meta->name,
    );
    return 1;
}

1;
