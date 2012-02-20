use strict;
use warnings;

package Diary::MoCo::User;
use base 'Diary::MoCo';

use Diary::MoCo::Article;

__PACKAGE__->table( 'user' );
__PACKAGE__->utf8_columns( 'name' );

sub articles {
    my $self = shift;
    return Diary::MoCo::Article->search(
        where => { user_id => $self->id },
        order => 'created_on DESC',
    );
}

1;
