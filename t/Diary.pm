package t::Diary;

use strict;
use warnings;
use utf8;

use Diary::Database;


# DB の設定ファイルの位置
my $dbconfpath = "config/db_for_test.conf";

# Database に関する設定を読み込み
if ( !-f $dbconfpath ) {
    print STDERR '接続先 DB の設定ファイルが存在しません. ' . "\n"
                    . 'はじめに initdb.pl を使用して接続先 DB の設定を行ってください.' . "\n";
    exit 2;
}
Diary::Database->load_db_config( $dbconfpath );

sub truncate_db {
    for ( qw(user article user_hatena) ) {
        Diary::Database->execute( "TRUNCATE TABLE $_" );
    }
}

1;
