use strict;
use warnings;
use utf8;

package Diary::MoCo::Article;
use base 'Diary::MoCo';

__PACKAGE__->table( 'entry' );
__PACKAGE__->utf8_columns( 'title' );
__PACKAGE__->utf8_columns( 'body' );

sub user {
    my $self = shift;
    return Diary::MoCo::User->find(
        where => { user_id => $self->user_id },
    );
}

sub edit {
    my $self = shift;
    my ( $title, $body ) = @_;

    DBIx::MoCo->start_session;
    $self->body( $body ); # この時点で before_update トリガ
    if ( defined $title ) {
        $self->title( $title ); # この時点で before_update トリガ
    }
    $self->save();
    DBIx::MoCo->end_session;
}

1;
