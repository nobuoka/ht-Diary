# vim:set ft=perl:
use strict;
use warnings;
use lib glob 'modules/*/lib';
use lib 'lib';


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
    my $ua = LWP::UserAgent->new();
    $ua->env_proxy(); # 環境変数のプロキシ設定を読み込み
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

