package Diary::MoCo;
use strict;
use warnings;
use base qw(DBIx::MoCo);

use Diary::Database;
use DateTime;
use DateTime::Format::MySQL;

__PACKAGE__->db_object( 'Diary::Database' );
my $infsub_for_datetime_ref = {
    inflate => sub {
        my $value = shift;
        return $value eq '0000-00-00 00:00:00' ? undef 
                                               : DateTime::Format::MySQL->parse_datetime($value);
    },
    deflate => sub {
        my $dt = shift;
        return DateTime::Format::MySQL->format_datetime($dt);
    },
};
__PACKAGE__->inflate_column(
    created_on => $infsub_for_datetime_ref,
    updated_on => $infsub_for_datetime_ref,
);

__PACKAGE__->add_trigger(
    before_create => sub {
        my ($class, $args) = @_;
        foreach my $col (qw(created_on updated_on)) {
            if ($class->has_column($col) && !defined $args->{$col}) {
                $args->{$col} = $class->now.q();
            }
        }
    }
);

__PACKAGE__->add_trigger(
    before_update => sub {
        my ($class, $self, $args) = @_;
        foreach my $col (qw(updated_on)) {
            if ($class->has_column($col) && !defined $args->{$col}) {
                $args->{$col} = $class->now.q();
            }
        }
    }
);

sub now {
    my $dt = DateTime->now(
        time_zone => 'UTC',
        formatter => 'DateTime::Format::MySQL',
    );
    return $dt;
}

1;
