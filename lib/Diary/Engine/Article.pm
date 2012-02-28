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
    my $article_id = $r->req->param('id');

    # とりあえずユーザー名は決めうち
    my $user = Diary::MoCo::User->find( name => 'nobuoka' )
        or die "can't find you on database. please do userconf command at first.";
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
    my $article_id = $r->req->param('id');

    # とりあえずユーザー名は決めうち
    my $user = Diary::MoCo::User->find( name => 'nobuoka' )
        or die "can't find you on database. please do userconf command at first.";
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
