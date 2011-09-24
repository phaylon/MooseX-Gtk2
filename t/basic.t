use strictures 1;
use Test::More;
use MooseX::Gtk2::Util qw( membrane_class_of );

my $class = membrane_class_of('Gtk2::Window');
isa_ok($class, 'Gtk2::Window', 'membrane class');
ok $class->meta->has_attribute('title'), 'window has title attribute';

my $win = $class->new;
isa_ok($win, 'Gtk2::Window', 'membrane object');
isa_ok($win, $class, 'membrane object');

my ($BUILD, $DEMOLISH);

do {
    package MyWindow;
    use MooseX::Gtk2;
    use syntax qw( simple/v2 );

    extends 'Gtk2::Window';

    has title_postfix => (
        is          => 'rw',
        isa         => 'Str',
    );

    has some_list => (
        traits      => [qw( Array )],
        default     => sub { [] },
        handles     => {
            some_list   => 'elements',
            add_to_list => 'push',
        },
    );

    method BUILD    { $BUILD++ }
    method DEMOLISH { $DEMOLISH++ }

    register;
};

do {
    my $newwin = MyWindow->new(title => 'Foo', title_postfix => 'Bar');

    isa_ok($newwin, 'Gtk2::Window', 'widget subclass');
    isa_ok($newwin, $class, 'widget subclass');
    isa_ok($newwin, 'MyWindow', 'widget subclass');
    is $newwin->get_title, 'Foo', 'init_arg for Glib property';
    is $newwin->get_title_postfix, 'Bar', 'reader for Perl property';

    $newwin->add_to_list(2..5);
    $newwin->add_to_list(23);
    is_deeply [$newwin->some_list], [2..5, 23], 'delegated method';
    $newwin->set(title => 'foo');
    is $newwin->get_title, 'foo', 'title set via ->set';
    $newwin->set_title('bar');
    is $newwin->get_title, 'bar', 'title set via ->set_title';

    $newwin->destroy;
};

is $BUILD, 1, 'BUILD was called once';
is $DEMOLISH, 1, 'DEMOLISH was called once';

done_testing;
