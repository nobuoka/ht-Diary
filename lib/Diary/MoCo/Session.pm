package Diary::MoCo::Session;
use strict;
use warnings;

use base 'Diary::MoCo';

use String::Random;

use Carp qw( croak );
use Diary::MoCo::User;

__PACKAGE__->table( 'session' );
__PACKAGE__->utf8_columns( 'id' );

sub user {
    my $self = shift;
    return Diary::MoCo::User->find(
        id => $self->user_id,
    );
}

sub new_session {
    my $self = shift;
    my ( $user_id ) = @_;

    # TODO: id が既に存在していないかどうかの確認
    # ランダム文字列で id を生成
    my $session_id = String::Random->new->randregex('[A-Za-z0-9]{128}');
    $self->create( id => $session_id, user_id => $user_id );
    return $session_id;
}

1;
