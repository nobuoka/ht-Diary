use strict;
use warnings;

use IO::File;
use Diary::DBConf;

package Diary::Database;
use base 'DBIx::MoCo::DataBase';

#__PACKAGE__->dsn( 'dbi:mysql:dbname=XXXXXX' );
#__PACKAGE__->username( 'XXXXXXX' );
#__PACKAGE__->password( 'XXXXXXX' );

sub load_db_config {
    my $pkg = shift;
    my $dbconfpath = shift;

    my $dbconf = Diary::DBConf->new( $dbconfpath );
    $pkg->dsn( $dbconf->dsn );
    $pkg->username( $dbconf->username );
    $pkg->password( $dbconf->password );
    return 1;
}

1;
