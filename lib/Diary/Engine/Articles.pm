package Diary::Engine::Articles;
use strict;
use warnings;
use utf8;
use Readonly;
use Diary::Engine -Base;
use Diary::MoCo::User;

## 設定

# 1 ページあたりの記事数
Readonly my $NUM_ITEM_PER_PAGE => 10;

sub default : Public {
    my ($self, $r) = @_;
    return $r->follow_method;
}

sub _get {
    my ( $self, $r ) = @_;

    my $page = $r->req->param('page');
    if ( ! defined $page ) {
        $page = '1';
    }
    if ( $page !~ /\A[1-9]\d*\z/ms ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }

    # とりあえずユーザー名は決めうち
    my $user = Diary::MoCo::User->find( name => 'nobuoka' )
        or die "can't find you on database. please do userconf command at first.";

    # TODO:
    # ここら辺はモデル側を変更する必要あり
    my $articles = $user->articles;
    my $num_articles = $articles->length;
    my $offset = ( $page - 1 ) * $NUM_ITEM_PER_PAGE;
    my $limit  = $NUM_ITEM_PER_PAGE;
    $articles = $articles->sort( sub{ $_[1]->updated_on <=> $_[0]->updated_on } );
    $articles = $articles->slice( $offset, $offset + $limit - 1 );

    $r->stash->param(
        user             => $user,
        articles_on_page => $articles,
        num_articles     => $num_articles,
        num_pages        => int( ( $num_articles - 1 ) / $NUM_ITEM_PER_PAGE ) + 1,
        cur_page         => $page,
    );
    #$r->res->content_type('text/plain');
    #$r->res->content('Welcome to the Ridge world!');
}

sub _post{
    my ( $self, $r ) = @_;

    my $title = $r->req->param('title');
    my $body  = $r->req->param('body' );
    if ( ! defined $title ) {
        # TODO: 例外
        $r->res->code( '400' );
        $r->res->content( '400 BAD REQUEST : no title' );
        return;
    }
    if ( ! defined $body ) {
        # TODO: 例外
        $r->res->code( '400' );
        $r->res->content( '400 BAD REQUEST : no body' );
        return;
    }

    # とりあえずユーザー名は決めうち
    my $user = Diary::MoCo::User->find( name => 'nobuoka' )
        or die "can't find you on database. please do userconf command at first.";

    my $article = $user->create_article( $title, $body );
    $r->res->redirect( '/article?id=' . $article->id );
    #print '[SUCCESS] wrote new article (id: ', $article->id, ') : ', $article->title, "\n";
    #$r->res->content_type('text/plain');
    #$r->res->content('Welcome to the Ridge world!');
}

1;
