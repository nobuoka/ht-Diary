package Diary::Database;
use strict;
use warnings;
use base qw(DBIx::MoCo::DataBase);

use IO::File;

use DBIx::MoCo::DataBase;
use Diary::DBConf;

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
