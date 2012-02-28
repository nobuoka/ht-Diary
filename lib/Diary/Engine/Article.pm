package Diary::Engine::Article;
use strict;
use warnings;
use Diary::Engine -Base;
use Diary::MoCo::User;

sub default : Public {
    my ($self, $r) = @_;

    # とりあえずユーザー名は決めうち
    my $user = Diary::MoCo::User->find( name => 'nobuoka' )
        or die "can't find you on database. please do userconf command at first.";
    my $article = $user->select_article_by_id( $r->req->param('id') );
    $r->stash->param(
        user    => $user,
        article => $article,
    );
    #$r->res->content_type('text/plain');
    #$r->res->content('Welcome to the Ridge world!');
}

1;
