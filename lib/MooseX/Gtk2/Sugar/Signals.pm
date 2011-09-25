use strictures 1;

package MooseX::Gtk2::Sugar::Signals;

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use syntax qw( simple/v2 );
use namespace::clean;

Moose::Exporter->setup_import_methods(
    with_meta => [qw( signal )],
);

fun signal ($meta, $name, @args) {
    return $meta->add_signal_override($name, @args)
        if @args == 1;
    return $meta->add_signal($name, @args);
}

1;
