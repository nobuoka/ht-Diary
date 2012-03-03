package Diary::Engine::Index;
use strict;
use warnings;
use utf8;
use Readonly;
use Diary::Engine -Base;
use Diary::MoCo::User;

sub default : Public {
    my ($self, $r) = @_;
}

###
# テスト用; 変数の値などを表示
sub test : Public {
    my ($self, $r) = @_;

    # OAuth テスト
    my $u = $r->req->env->{'hatena.user'};
    my $ui = $r->req->env->{'hatena.user.detail'};
    my $str = join ',', map { $_ . '=' . $ui->{$_}  } keys %{$ui};
    my $env = $r->req->env;
    my $env_str = join "\n", map { $_ . '=' . ( $env->{$_} || '' ) } sort keys %{$env};
    my $session = $r->req->session;
    if ( !defined $session->{'session_id'} ) {
        $session->{'session_id'} = 0;
    } else {
        $session->{'session_id'} ++;
    }
    my $session_str = join "\n", map { $_ . '=' . $session->{$_}  } sort keys %{$session};
    $r->res->content( $str . "\n\n" . $env_str . "\n\n" . $session_str );
    $r->res->header( 'content_type' => 'text/plain' );
}

1;
