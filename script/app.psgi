# vim:set ft=perl:
use strict;
use warnings;
use lib glob 'modules/*/lib';
use lib 'lib';

use List::Util ('first');
use UNIVERSAL::require;
use Path::Class;
use Plack::Builder;
use Cache::MemoryCache;

use LWP::UserAgent;
use OAuth::Lite::Agent;

my $namespace = 'Diary';
$namespace->use or die $@;

my $root = file(__FILE__)->parent->parent;

$ENV{GATEWAY_INTERFACE} = 1; ### disable plack's accesslog
$ENV{PLACK_ENV} = ($ENV{RIDGE_ENV} =~ /production|staging/) ? 'production' : 'development';

# DB の設定を読み込んで, 接続先 DB を設定
# Database に関する設定を読み込み
my $dbconfpath = "config/db_for_production.conf";
if ( !-f $dbconfpath ) {
    die '接続先 DB の設定ファイルが存在しません. ' . "\n"
                . 'はじめに initdb.pl を使用して接続先 DB の設定を行ってください.' . "\n";
}
Diary::Database->load_db_config( $dbconfpath );


builder {
    unless ($ENV{PLACK_ENV} eq 'production') {
        enable "Plack::Middleware::Debug";
        enable "Plack::Middleware::Static",
            path => qr{\A/(images|js|css|style)/},
            root => $root->subdir('static');
    }

    enable "Plack::Middleware::ReverseProxy";

    # hatenatraining の記事中のサンプルコードをそのまま使用
    # (proxy のため ua 設定のみ追加)
    enable 'Session';

    # HTTP プロキシを環境変数から読み込んで設定 (case insensitive)
    # (大文字小文字が異なる複数の 'http_proxy' がある場合はどれが選択されるか未定義)
    # (HTTPS は Crypt::SSLeay モジュール内で HTTPS_PROXY 環境変数を読んでくれる
    #   参考 : http://perl-users.jp/articles/advent-calendar/2009/casual/17.html )
    my $ua = LWP::UserAgent->new();
    my $k = first { lc($_) eq 'http_proxy' } keys %ENV;
    $ua->proxy( 'http', $ENV{$k} ) if $k; 

    enable 'Plack::Middleware::HatenaOAuth',
        consumer_key       => 'vUarxVrr0NHiTg==',
        consumer_secret    => 'RqbbFaPN2ubYqL/+0F5gKUe7dHc=',
        login_path         => '/login',
        ua                 => $ua,
        ;

    sub {
        my $env = shift;
        $namespace->process($env, {
            root => $root,
        });
    }
};

