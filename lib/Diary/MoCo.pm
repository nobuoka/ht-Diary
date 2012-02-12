use strict;
use warnings;

package Diary::MoCo;
use base 'DBIx::MoCo';

use Diary::Database;

__PACKAGE__->db_object( 'Diary::Database' );

1;
