package Diary;
use strict;
use warnings;
use base qw/Ridge/;

use Diary::Database;

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

    my $user_id = $self->req->session->{'user_id'}
            or return;
    my $user = Diary::MoCo::User->find( id => $user_id )
            or return;
    return $user;
}

# ------------------
#  出力用エスケープ
# ------------------

###
# HTML 内にテキストとして出力する文字を, HTML として解釈され内容にエスケープ
sub esc_html {
    my $self = shift;
    my ( $str ) = @_;

    $str =~ s/&/&amp;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    $str;
}

###
# 改行を br タグに
sub conv_lf_to_br_tag {
    my $self = shift;
    my ( $str ) = @_;

    $str =~ s/\n/<br>/g;
    $str;
}

1;
