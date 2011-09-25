use strictures 1;

package MooseX::Gtk2::Types;

use namespace::clean;

use MooseX::Types -declare => [qw(
    SignalRunType
)];

enum SignalRunType, qw( first last cleanup );

1;
