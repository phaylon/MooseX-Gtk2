use strictures 1;
use Test::More;
use Test::Fatal;
use MooseX::Gtk2::Util qw( membrane_class_of );
use syntax qw( simple/v2 );

my $class = membrane_class_of('Gtk2::Window');
isa_ok($class, 'Gtk2::Window', 'membrane class');
ok $class->meta->has_attribute('title'), 'window has title attribute';

my $win = $class->new;
isa_ok($win, 'Gtk2::Window', 'membrane object');
isa_ok($win, $class, 'membrane object');

my ($BUILD, $DEMOLISH, $SIGNAL, $RSIGNAL, $TRSIGNAL, $SUBBUILD);

do {
    package MyOtherWindowRole;
    use MooseX::Gtk2::Role;
    use syntax qw( simple/v2 );

    signal twice_removed => (handler => '_handle_twice_removed');

    method _handle_twice_removed { $TRSIGNAL++; 17 }
};

do {
    package MyWindowRole;
    use MooseX::Gtk2::Role;

    has title_postfix => (
        is          => 'rw',
        isa         => 'Str',
    );

    signal barqux => (handler => '_handle_barqux');

    with qw( MyOtherWindowRole );
};

do {
    package MyWindow;
    use MooseX::Gtk2;
    use MooseX::Types::Common::String qw( NonEmptySimpleStr );
    use syntax qw( simple/v2 );

    extends 'Gtk2::Window';

    has '+title' => (isa => NonEmptySimpleStr);

    has some_list => (
        traits      => [qw( Array )],
        default     => sub { [] },
        handles     => {
            some_list   => 'elements',
            add_to_list => 'push',
        },
    );

    has buildargs_called => (is => 'ro');

    signal foobar => (handler => '_handle_foobar');

    method _handle_foobar { $SIGNAL++; 23 }
    method _handle_barqux { $RSIGNAL++; 42 }

    method BUILD    { $BUILD++ }
    method DEMOLISH { $DEMOLISH++ }

    with qw( MyWindowRole );

    around BUILDARGS (@args) {
        my $attrs = $self->$orig(@args);
        $attrs->{buildargs_called} = 1;
        return $attrs;
    }

    register;

    package SubWindow;
    use MooseX::Gtk2;;
    extends 'MyWindow';
    sub BUILD { $SUBBUILD++ }
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

    $newwin->set(title_postfix => 'qux');
    is $newwin->get_title_postfix, 'qux', 'role attribute value set()';

    like exception { $newwin->set_title('') },
        qr{does not pass the type constraint}i,
        'type constraint on inherited attribute sticks';

    like exception { $newwin->set(title => '') },
        qr{does not pass the type constraint}i,
        'type constraint on inherited attribute via set() sticks';

    is $newwin->signal_emit(foobar => $newwin), 23, 'signal return value';
    is $newwin->signal_emit(barqux => $newwin), 42, 'composed signal';
    is $newwin->signal_emit(twice_removed => $newwin), 17, 'role in role';

    $newwin->add(Gtk2::Button->new('Test'));

    is $newwin->get('type'), 'toplevel', 'builtin default value';

    ok $newwin->get_buildargs_called, 'BUILDARGS was used';

    my $subwin = SubWindow->new(title => 'Baz');
    isa_ok $subwin, $_, 'subclass of subclass' for qw(
        SubWindow
        MyWindow
        Gtk2::Window
    );

    if ($ENV{SHOW_TEST_WINDOW}) {
        $newwin->show_all;
        $newwin->signal_connect(destroy => sub { Gtk2->main_quit });
        Gtk2->main;
    }
    else {
        $newwin->destroy;
    }
};

is $BUILD,      2, 'BUILD was called twice (class and subclass)';
is $DEMOLISH,   1, 'DEMOLISH was called once';
is $SIGNAL,     1, 'signal handler was called once';
is $RSIGNAL,    1, 'signal composed via role calls handler';
is $TRSIGNAL,   1, 'signal composed into role calls handler';
is $SUBBUILD,   1, 'BUILD was called once in subclass';

do {
    package MyButton;
    use MooseX::Gtk2;

    extends 'Gtk2::Button';

    has foo => (is => 'rw');

    register;
};

do {
    my $button = MyButton->new(label => 'Label', foo => 23);
    is $button->get_label, 'Label', 'label after construction';
    is $button->get_foo, 23, 'own attribute after construction';

    my $sw = Gtk2::ScrolledWindow->new;

    $sw->add_with_viewport($button);

    is $sw->child->child->get_label, 'Label', 'label inside bin';
    is $sw->child->child->get_foo, 23, 'own attribute inside bin';
};

done_testing;
