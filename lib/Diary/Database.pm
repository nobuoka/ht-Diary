use strict;
use warnings;

use IO::File;

package Diary::Database;
use base 'DBIx::MoCo::DataBase';

#__PACKAGE__->dsn( 'dbi:mysql:dbname=XXXXXX' );
#__PACKAGE__->username( 'XXXXXXX' );
#__PACKAGE__->password( 'XXXXXXX' );

sub load_db_config {
    my $pkg = shift;
    my $dbconfpath = shift;
    #print $dbconfpath, "\n";
    my $dbconffile = IO::File->new( $dbconfpath, '<' );
    my @lines = $dbconffile->getlines();
    chomp( @lines );
    # 設定ファイルのコメント行を取り除く
    @lines = grep( !/^#/, @lines );
    # TODO : 行数確認とか
    #foreach( @lines ) {
    #    print "::", $_, "\n";
    #}
    $pkg->dsn( $lines[0] );
    $pkg->username( $lines[1] );
    $pkg->password( $lines[2] );
    $dbconffile->close();
}

1;
