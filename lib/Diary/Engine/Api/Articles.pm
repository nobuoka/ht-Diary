package Diary::Engine::Api::Articles;
use strict;
use warnings;
use utf8;
use Readonly;
use JSON::XS;
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

    # Diary::Engine::Articles と共通のチェックがあるので, モジュールにまとめるべき

    # パラメータの取得と確認
    my $requested_page = $r->req->param('page');
    my $page = ( defined $requested_page ? $requested_page : '1' );
    if ( $page !~ /\A[1-9]\d*\z/ms ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }
    my $requested_num_per_page = $r->req->param('num_per_page');
    my $num_per_page = ( defined $requested_num_per_page ? $requested_num_per_page
                                                         : $NUM_ITEM_PER_PAGE );
    if ( $page !~ /\A[1-9]\d*\z/ms ) {
        # 例外
        $r->res->code( '404' );
        $r->res->content( '404 NOT FOUND' );
        return;
    }
    my $user_name = $r->req->param('user_name');
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

    # とりあえず json のみ
    if ( $r->req->uri->view eq 'json' ) {
        $r->res->content_type( 'text/json' );
        my @hash_articles = map {
            my $h = $_->to_hash;
            # 日時は ISO 8601 形式の文字列 (UTC)
            $h->{'created_on'} = $h->{'created_on'}->set_time_zone( '+0000' )->strftime('%FT%TZ');
            $h->{'updated_on'} = $h->{'updated_on'}->set_time_zone( '+0000' )->strftime('%FT%TZ');
            $h->{'uri'       } = '/user:' . $user_name . '/article:' . $h->{'id'};
            $h;
        } @{$articles->to_a};
        $r->res->content( JSON::XS::encode_json([ @hash_articles ])  );
        #$r->res->content( JSON::XS::encode_json([ map { $_->to_hash } $articles->to_a ])  );
    } else {
        $r->res->code( '404' );
    }
}

# XXX Ridge アクションが空で view が指定されたとき, action が view と一致するので
# エイリアスを張る (/api/articles.json へのアクセス時に, action が json になってしまう)
*_json_get = \&_get;

1;
