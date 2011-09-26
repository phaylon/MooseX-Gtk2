use strictures 1;

# ABSTRACT: Internal type library

package MooseX::Gtk2::Types;

use namespace::clean;

use MooseX::Types -declare => [qw(
    SignalRunType
)];

enum SignalRunType, qw( first last cleanup );

1;
