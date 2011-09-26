use strictures 1;

# ABSTRACT: Manage generic attribute access

package MooseX::Gtk2::MetaRole::Class::WrapAccessors;
use Moose::Role;
use Moose::Util     qw( does_role );
use Sub::Identify   qw( stash_name );

use syntax qw( simple/v2 );
use namespace::autoclean;

method _method_stash_name ($name) {
    my $code = $self->name->can($name)
        or return '';
    return stash_name $code;
}

method install_accessor_wrappers {
    my $class = $self->name;
    for my $setter (qw( set set_property )) {
        next unless $self->_method_stash_name($setter) eq 'Glib::Object';
        $self->install_set_wrapper($setter);
    }
    for my $getter (qw( get get_property )) {
        next unless $self->_method_stash_name($getter) eq 'Glib::Object';
        $self->install_get_wrapper($getter);
    }
}

method install_get_wrapper ($method_name) {
    $self->add_method($method_name, method ($instance: @attr_names) {
        my $meta = $instance->meta;
        my @gathered;
        for my $attr_name (@attr_names) {
            my $attr = $meta->find_attribute_by_name($attr_name)
                or $meta->throw_error("Unknown attribute '$attr_name'");
            unless ($attr->is_generally_readable) {
                $attr->throw_error(sprintf
                    q{Attribute '%s' is not readable via %s()},
                    $attr_name,
                    $method_name,
                );
            }
            push @gathered, $attr->get_value($instance);
        }
        return wantarray ? @gathered : shift(@gathered);
    });
}

method install_set_wrapper ($method_name) {
    $self->add_method($method_name, method ($instance: %new_value) {
        my $meta = $instance->meta;
        for my $attr_name (keys %new_value) {
            my $attr = $meta->find_attribute_by_name($attr_name)
                or $meta->throw_error("Unknown attribute '$attr_name'");
            unless ($attr->is_generally_writable) {
                $attr->throw_error(sprintf
                    q{Attribute '%s' is not writeable via %s()},
                    $attr_name,
                    $method_name,
                );
            }
            $attr->set_value($instance, $new_value{$attr_name});
        }
        return 1;
    });
}

1;
