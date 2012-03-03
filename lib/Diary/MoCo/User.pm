use strict;
use warnings;

package Diary::MoCo::User;
use base 'Diary::MoCo';

use Carp qw( croak );
use Diary::MoCo::Article;
use Diary::MoCo::UserHatena;
use Diary::MoCo::Session;

__PACKAGE__->table( 'user' );
__PACKAGE__->utf8_columns( 'name' );

sub articles {
    my $self = shift;
    return Diary::MoCo::Article->search(
        where => { user_id => $self->id },
        order => 'created_on DESC',
    );
}

sub create_article {
    my $self = shift;
    if ( @_ != 2 ) {
        croak( 'invalid arguments : require 2 argumens' );
    }
    my ( $article_title, $article_body ) = @_;
    if ( !defined $article_title ) {
        croak 'invalid argument : $article_title not defined';
    }
    if ( !defined $article_body ) {
        croak 'invalid argument : $article_body not defined';
    }

    my $article = Diary::MoCo::Article->create(
        user_id => $self->id,
        title   => $article_title,
        body    => $article_body,
    );
}

sub delete_article_by_id {
    my $self = shift;
    my ( $article_id ) = @_;
    if( !defined $article_id ) {
        croak 'invalid argument : $article_body not defined';
    }

    my $article = $self->select_article_by_id( $article_id )
        or croak "not found article whose id=$article_id";
    $article->delete();
    return 1;
}

sub select_article_by_id {
    my $self = shift;
    my ( $article_id ) = @_;

    my $article = Diary::MoCo::Article->find(
        id => $article_id,
        user_id => $self->id,
    );
    return $article;
}

###
# このユーザーオブジェクトに結び付けられた UserHatena オブジェクトを新たに生成します
sub create_associated_user_hatena {
    my $self = shift;
    my ( $hatena_name ) = @_;

    my $user_hatena = Diary::MoCo::UserHatena->create(
        name          => $hatena_name,
        assoc_user_id => $self->id,
    );
    return $user_hatena;
}

sub new_session {
    my $self = shift;
    #my () = @_;

    # 
    my $session_id = Diary::MoCo::Session->new_session( $self->id );
    return $session_id;
}

1;
