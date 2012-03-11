package Diary::Engine::User::Article;
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
    if ( ! defined $article ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }

    $r->stash->param(
        user    => $user,
        article => $article,
    );
}

sub newly : Public {
    my ( $self, $r ) = @_;
    return $r->follow_method;
}
sub _newly_get {
    my ($self, $r) = @_;

    # ログインユーザー
    my $auth_user = $r->user;
    if ( ! defined $auth_user ) {
        $r->res->code( '401' );
        $r->res->content( '401 Unauthorized' );
        return;
    }

    # URI params
    my $user_name  = $r->req->uri->param('user_name');
    if ( ! defined $user_name ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }
    if ( $user_name ne $auth_user->name ) {
        $r->res->code( '403' );
        $r->res->content( '403 Forbidden' );
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
    $r->stash->param(
        user    => $user,
    );
}

sub edit : Public {
    my ( $self, $r ) = @_;
    return $r->follow_method;
}
sub _edit_get {
    my ($self, $r) = @_;

    # ログインユーザー
    my $auth_user = $r->user;
    if ( ! defined $auth_user ) {
        $r->res->code( '401' );
        $r->res->content( '401 Unauthorized' );
        return;
    }

    # URI params
    my $article_id = $r->req->uri->param('article_id');
    my $user_name  = $r->req->uri->param('user_name');
    if ( ! defined $article_id ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }
    if ( ! defined $user_name ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }
    if ( $user_name ne $auth_user->name ) {
        $r->res->code( '403' );
        $r->res->content( '403 Forbidden' );
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

    # Article オブジェクトの取得; 失敗の場合は 404 エラー
    my $article = $user->select_article_by_id( $article_id );
    if ( ! defined $article ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }

    $r->stash->param(
        user    => $user,
        article => $article,
    );
} 

sub update : Public {
    my ( $self, $r ) = @_;
    return $r->follow_method;
}
sub _update_post {
    my ($self, $r) = @_;

    # ログインユーザー
    my $auth_user = $r->user;
    if ( ! defined $auth_user ) {
        $r->res->code( '401' );
        $r->res->content( '401 Unauthorized' );
        return;

    }

    # URI params
    my $article_id = $r->req->uri->param('article_id');
    my $user_name  = $r->req->uri->param('user_name');
    if ( ! defined $article_id ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }
    if ( ! defined $user_name ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }

    # body params
    my $body  = $r->req->body_parameters->get( 'body'  );
    my $title = $r->req->body_parameters->get( 'title' );
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
 
    # User オブジェクトの取得; 失敗の場合は 404 エラー
    my $user = Diary::MoCo::User->find( name => $user_name );
    if ( ! defined $user ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }

    # Article オブジェクトの取得; 失敗の場合は 404 エラー
    my $article = $user->select_article_by_id( $article_id );
    if ( ! defined $article ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }
    $article->param( 'body',  $body  );
    $article->param( 'title', $title );
    $r->res->redirect( '/user:' . $user_name . '/article:' . $article_id );
    return;
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
    $r->res->redirect( '/user:' . $user_name . '/articles' );
    return;
    $r->stash->param(
        user    => $user,
        #    article => $article,
    );
    #$r->res->content_type('text/plain');
    #$r->res->content('Welcome to the Ridge world!');
}

1;
