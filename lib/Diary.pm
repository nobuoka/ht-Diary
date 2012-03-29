package Diary;
use strict;
use warnings;
use base qw/Ridge/;

use URI::Encode qw( uri_encode uri_decode );
use Diary::Database;

__PACKAGE__->configure;

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

    my $session = $self->req->session
            or return;
    my $user_id = $session->{'user_id'}
            or return;
    my $user = Diary::MoCo::User->find( id => $user_id )
            or return;
    return $user;
}

sub encode_uri_path_param {
    my ( $str ) = @_;
    # コロンとアットマークとピリオドとスラッシュを @XX 形式に変換する
    encode_atenc( $str );
    # さらに, 使用できない文字をパーセントエンコードする
    $str = uri_encode( $str, 1 );

    return $str;
}

sub encode_atenc {
    my ( $str ) = @_;
    $str =~ s/@/\@40/g;
    $str =~ s/:/\@3A/g;
    $str =~ s/\./\@2E/g;
    $str =~ s|/|\@2F|g;
    return $str;
}

sub decode_uri_path_param {
    my ( $str ) = @_;
    # パーセントエンコードをデコード
    $str = uri_decode( $str );
    # @XX 形式のものを元に戻す
    decode_atenc( $str );

    return $str;
}

sub decode_atenc {
    my ( $str ) = @_;
    $str =~ s/@([a-fA-F0-9]{2})/chr($1)/eg;
    return $str;
}


1;
