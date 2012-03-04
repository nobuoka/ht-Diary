package Diary::Engine::Article;
use strict;
use warnings;
use Diary::Engine -Base;
use Diary::MoCo::User;

sub default : Public {
    my ($self, $r) = @_;
    return $r->follow_method;
}

sub _get {
    my ($self, $r) = @_;
    my $article_id = $r->req->uri->param('article_id');

    # パラメータの取得
    my $user_name = $r->req->uri->param('user_name');
    if ( ! defined $user_name ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
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

    # Article オブジェクトの取得
    my $article = $user->select_article_by_id( $article_id );
    $r->stash->param(
        user    => $user,
        article => $article,
    );
    #$r->res->content_type('text/plain');
    #$r->res->content('Welcome to the Ridge world!');
}

sub delete : Public {
    my ( $self, $r ) = @_;
    return $r->follow_method;
}

sub _delete_post {
    my ($self, $r) = @_;
    my $article_id = $r->req->uri->param('article_id');

    # パラメータの取得
    my $user_name = $r->req->uri->param('user_name');
    if ( ! defined $user_name ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
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

    $user->delete_article_by_id( $article_id )
        or die "failed to delete article (id=$article_id)";
    $r->res->redirect('/articles');
    return;
    $r->stash->param(
        user    => $user,
        #    article => $article,
    );
    #$r->res->content_type('text/plain');
    #$r->res->content('Welcome to the Ridge world!');
}

1;
