use strictures 1;

# ABSTRACT: Signal declaration sugar

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

__END__

=head1 DESCRIPTION

Used to setup a C<signal> keyword in packages built with L<MooseX::Gtk2>
or L<MooseX::Gtk2::Role>.

=cut
