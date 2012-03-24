package Diary::Engine::Api::Article;
use strict;
use warnings;
use utf8;

use JSON::XS;
use Diary::Engine -Base;
use Diary::MoCo::User;

sub default : Public {
    my ($self, $r) = @_;
    return $r->follow_method;
}

sub _get {
    my ( $self, $r ) = @_;

    # Diary::Engine::Articles と共通のチェックがあるので, どこかににまとめるべき

    # パラメータの取得と確認
    my $user_name = $r->req->param('user_name');
    if ( ! defined $user_name ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND : user_name undefined' );
        return;
    }
    my $article_id = $r->req->param('article_id');
    if ( ! defined $article_id ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND : article_id undefined' );
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

    # Article オブジェクトの取得
    my $article = $user->select_article_by_id( $article_id );
    if ( ! defined $article ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }

    # とりあえず json のみ
    if ( $r->req->uri->view eq 'json' ) {
        $r->res->content_type( 'text/json' );
        $r->res->content( _article_to_json( $article ) );
    } else {
        $r->res->code( '404' );
    }
}

sub update : Public {
    my ($self, $r) = @_;
    return $r->follow_method;
}

sub _update_post {
    my ( $self, $r ) = @_;
    $r->res->content( "aaaaa" );

    # ログインユーザー
    my $auth_user = $r->user;
    if ( ! defined $auth_user ) {
        $r->res->code( '401' );
        $r->res->content( '401 Unauthorized' );
        return;
    }

    # query params
    my $article_id = $r->req->query_parameters->get('article_id');
    my $user_name  = $r->req->query_parameters->get('user_name');
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

    # TODO 必要な処理
    $article->param( 'body',  $body  );
    $article->param( 'title', $title );
    #$r->res->redirect( '/user:' . $user_name . '/article:' . $article_id );
    #return;
    # とりあえず json のみ
    if ( $r->req->uri->view eq 'json' ) {
        $r->res->content_type( 'text/json' );
        $r->res->content( _article_to_json( $article )  );
    } else {
        $r->res->code( '404' );
    }
}

# XXX Ridge アクションが空で view が指定されたとき, action が view と一致するので
# エイリアスを張る (/api/articles.json へのアクセス時に, action が json になってしまう)
*_json_get = \&_get;

sub _article_to_json {
    my ( $article ) = @_;
    my $h = _article_to_hash( $article );
    return JSON::XS::encode_json( $h );
}

sub _article_to_hash {
    my ( $article ) = @_;
    my $user_name = $article->user->name;
    my $h = $article->to_hash;
    # 日時は ISO 8601 形式の文字列 (UTC)
    $h->{'created_on'} = $h->{'created_on'}->set_time_zone( '+0000' )->strftime('%FT%TZ');
    $h->{'updated_on'} = $h->{'updated_on'}->set_time_zone( '+0000' )->strftime('%FT%TZ');
    $h->{'created_on_epoch'} = $article->created_on->epoch;
    $h->{'updated_on_epoch'} = $article->updated_on->epoch;
    $h->{'uri'       } = '/user:' . $user_name . '/article:' . $h->{'id'};
    return $h;
}

1;
