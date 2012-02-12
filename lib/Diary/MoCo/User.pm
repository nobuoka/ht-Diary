use strict;
use warnings;

package Diary::MoCo::User;
use base 'Diary::MoCo';

__PACKAGE__->table( 'user' );
__PACKAGE__->utf8_columns( 'name' );


1;
