use strict;
use warnings;

package Diary::MoCo::Article;
use base 'Diary::MoCo';

__PACKAGE__->table( 'entry' );
__PACKAGE__->utf8_columns( 'title' );
__PACKAGE__->utf8_columns( 'body' );

sub user {
    my $self = shift;
    return Diary::MoCo::User->find(
        where => { user_id => $self->user_id },
    );
}

sub edit {
    my $self = shift;

    my ( $title, $body ) = @_;
    my $vals = { body => $body };
    if ( defined $title ) {
        %{$vals} = { title => $title };
    }
    $self->update( %{$vals} );
}

1;
