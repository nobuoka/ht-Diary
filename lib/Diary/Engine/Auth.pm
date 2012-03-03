package Diary::Engine::Auth;
use strict;
use warnings;
use Diary::Engine -Base;
use Diary::MoCo::User;
use Diary::MoCo::UserHatena;

sub callback_hatena : Public {
    my ( $self, $r ) = @_;
    return $r->follow_method;
}

sub _callback_hatena_get {
    my ($self, $r) = @_;
    my $article_id = $r->req->param('id');

    # hatena user_name を取得
    my $hatena_user_name = $r->req->env->{'hatena.user'};
    if ( !defined $hatena_user_name ) {
        # TODO: 例外
        $r->res->code( '400' );
        $r->res->content( '400 BAD REQUEST : hatena.user unknown' );
        return;
    }

    # 既に存在するユーザー?
    # 存在している場合, 新しい session を開始
    my $user_hatena = Diary::MoCo::UserHatena->find( name => $hatena_user_name );
    my $user;
    if ( $user_hatena ) {
        $user = $user_hatena->user;
    }
    # 存在していない場合, 新たに user をつくる
    else {
        # とりあえず hatena_user_name でユーザーを作る; 将来変更の必要あり
        $user = Diary::MoCo::User->create( name => $hatena_user_name );
        $user->create_associated_user_hatena( $hatena_user_name );
    }
    my $session_id = $user->new_session();
    $r->req->session->{'session_id'} = $session_id;

    $r->res->redirect('/');
}

1;
