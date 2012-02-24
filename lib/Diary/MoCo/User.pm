use strict;
use warnings;

package Diary::MoCo::User;
use base 'Diary::MoCo';

use Diary::MoCo::Article;

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
    my ( $article_title, $article_body ) = @_;

    my $article = Diary::MoCo::Article->create(
        user_id => $self->id,
        title   => $article_title,
        body    => $article_body,
    );
}

sub delete_article_by_id {
    my $self = shift;
    my ( $article_id ) = @_;

    my $article = $self->select_article_by_id( $article_id )
        or return;
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

1;
