package Diary::Engine::Auth;
use strict;
use warnings;
use Plack::Session;
use Diary::Engine -Base;

sub logout : Public {
    my ( $self, $r ) = @_;
    return $r->follow_method;
}
sub _logout_post {
    my ( $self, $r ) = @_;
    my $session = Plack::Session->new($r->req->env);
    $session->remove( 'user_id' );
    $r->res->redirect('/');
}

1;
