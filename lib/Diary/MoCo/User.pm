package Diary::MoCo::User;
use strict;
use warnings;
use base qw(Diary::MoCo);

use Carp qw( croak );
use Diary::MoCo::Article;
use Diary::MoCo::UserHatena;
use Diary::MoCo;

__PACKAGE__->table( 'user' );
__PACKAGE__->utf8_columns( 'name' );

sub articles {
    my $self = shift;
    return Diary::MoCo::Article->search(
        where => { user_id => $self->id },
        order => 'created_on DESC',
    );
}

sub paged_articles {
    my $self = shift;
    my ( $page_num, $num_per_page ) = @_;
    if ( ! defined $page_num ) {
        croak 'invalid arguments : $page_num not defined';
    }
    if ( $page_num <= 0 ) {
        croak 'invalid arguments : ページ番号は 1 以上の数字である必要があります.';
    }
    if ( ! defined $num_per_page ) {
        croak 'invalid arguments : $num_per_page not defined';
    }

    my $offset = ( $page_num - 1 ) * $num_per_page;
    return Diary::MoCo::Article->search(
        where  => { user_id => $self->id },
        offset => $offset,
        limit  => $num_per_page,
        order  => 'created_on DESC, id DESC',
    );
}

sub num_articles {
    my $self = shift;
    Diary::MoCo::Article->count( user_id => $self->id );
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
        croak 'invalid argument : $article_id not defined';
    }

    my $article = $self->select_article_by_id( $article_id )
        or croak "not found article whose id=$article_id";
    $article->delete();
    return 1;
}

sub select_article_by_id {
    my $self = shift;
    my ( $article_id ) = @_;
    if( !defined $article_id ) {
        croak 'invalid argument : $article_id not defined';
    }

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

    # とりあえず現状では hatena の user_name と Diary の user_name を同一にする
    my $user_hatena = Diary::MoCo::UserHatena->create(
        name          => $hatena_name,
        assoc_user_id => $self->id,
    );
    return $user_hatena;
}

1;
