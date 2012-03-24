package Diary::Engine::User::Articles;
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

    # パラメータの取得と確認
    my $requested_page = $r->req->param('page');
    my $page = ( defined $requested_page ? $requested_page : '1' );
    if ( $page !~ /\A[1-9]\d*\z/ms ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }
    my $user_name = $r->req->uri->param('user_name');
    if ( ! defined $user_name ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND : user_name undefined' );
        return;
    }

    # User オブジェクトの取得; 失敗の場合は 404 エラー
    my $user = Diary::MoCo::User->find( name => $user_name );
    if ( ! defined $user ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND : unknown user (' . $user_name . ')' );
        return;
    }

    my $articles     = $user->paged_articles( $page, $NUM_ITEM_PER_PAGE );
    my $num_articles = $user->num_articles;
    if ( $articles->size == 0 and defined $requested_page ) {
        $r->res->code( '404' );
    }
    $r->stash->param(
        page_specified   => ( defined $requested_page ),
        user             => $user,
        articles_on_page => $articles,
        num_articles     => $num_articles,
        num_pages        => int( ( $num_articles - 1 ) / $NUM_ITEM_PER_PAGE + 1 ),
        num_per_page     => $NUM_ITEM_PER_PAGE,
        cur_page         => $page,
    );
}

sub _post{
    my ( $self, $r ) = @_;

    # ログインユーザー
    my $auth_user = $r->user;
    if ( ! defined $auth_user ) {
        $r->res->code( '401' );
        $r->res->content( '401 Unauthorized' );
        return;
    }

    # パラメータの取得と確認
    my $title = $r->req->param('title');
    my $body  = $r->req->param('body' );
    if ( ! defined $title ) {
        # 例外
        $r->res->code( '400' );
        $r->res->content( '400 BAD REQUEST : no title' );
        return;
    }
    if ( ! defined $body ) {
        # 例外
        $r->res->code( '400' );
        $r->res->content( '400 BAD REQUEST : no body' );
        return;
    }
    my $user_name = $r->req->uri->param('user_name');
    if ( ! defined $user_name ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND : user_name undefined' );
        return;
    }
    if ( $user_name ne $auth_user->name ) {
        $r->res->code( '403' );
        $r->res->content( '403 FORBIDDEN' );
        return;
    }

    # User オブジェクトの取得; 失敗の場合は 404 エラー
    my $user = Diary::MoCo::User->find( name => $user_name );
    if ( ! defined $user ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }

    my $article = $user->create_article( $title, $body );
    $r->res->redirect( '/user:' . $user_name . '/article:' . $article->id );
    $r->res->code( '303' );
    #print '[SUCCESS] wrote new article (id: ', $article->id, ') : ', $article->title, "\n";
    #$r->res->content_type('text/plain');
    #$r->res->content('Welcome to the Ridge world!');
}

1;
