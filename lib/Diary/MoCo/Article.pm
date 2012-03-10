package Diary::MoCo::Article;
use strict;
use warnings;
use utf8;
use base qw(Diary::MoCo);

use Carp qw( croak );
use Diary::MoCo::User;

__PACKAGE__->table( 'article' );
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
    if( !defined $body ) {
        croak 'invalid argument : $body not defined';
    }

    $self->body( $body );
    if ( defined $title ) {
        $self->title( $title );
    }
    $self->save();
}

1;
