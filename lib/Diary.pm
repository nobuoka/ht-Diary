package Diary;
use strict;
use warnings;
use base qw/Ridge/;

use Diary::Database;
use Diary::MoCo::Session;

__PACKAGE__->configure;

# DB の設定ファイルの位置
my $dbconfpath = "config/db_for_production.conf";

# Database に関する設定を読み込み
if ( !-f $dbconfpath ) {
    print STDERR '接続先 DB の設定ファイルが存在しません. ' . "\n"
                    . 'はじめに initdb.pl を使用して接続先 DB の設定を行ってください.' . "\n";
    exit 2;
}
Diary::Database->load_db_config( $dbconfpath );

sub truncate_db {
    for ( qw(user entry) ) {
        Diary::Database->execute( "TRUNCATE TABLE $_" );
    }
}

###
# ログイン中のユーザーを返す.
# ログインしてない場合は undef を返す
sub user {
    my $self = shift;

    my $session_id = $self->req->session->{'session_id'}
            or return;
    my $session = Diary::MoCo::Session->find( id => $session_id )
            or return;
    return $session->user;
}

1;
