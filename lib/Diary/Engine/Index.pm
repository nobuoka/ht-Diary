package Diary::Engine::Index;
use strict;
use warnings;
use Diary::Engine -Base;
use Diary::MoCo::User;

sub default : Public {
    my ($self, $r) = @_;

    # とりあえずユーザー名は決めうち
    my $user = Diary::MoCo::User->find( name => 'nobuoka' )
        or die "can't find you on database. please do userconf command at first.";
    my $articles = $user->articles;
    $r->stash->param(
        user     => $user,
        articles => $articles,
    );
    #$r->res->content_type('text/plain');
    #$r->res->content('Welcome to the Ridge world!');
}

1;
