package Diary::MoCo::UserHatena;
use strict;
use warnings;

use base 'Diary::MoCo';

use Carp qw( croak );
use Diary::MoCo::User;

__PACKAGE__->table( 'user_hatena' );
__PACKAGE__->utf8_columns( 'name' );

sub user {
    my $self = shift;
    return Diary::MoCo::User->find(
        id => $self->assoc_user_id,
    );
}

1;
