package Diary::OAuthConf;
use strict;
use warnings;
use utf8;
# OAuth 認証に用いる consumer key, consumer secret を
# 記述した設定ファイルのインターフェイスクラス

use IO::File;
use Fcntl qw( :flock ); # ファイルロックの定数
use JSON::XS;

### Class methods ###

###
# 設定ファイルを読み込み, 
sub read_oauth_config {
    my $class = shift;
    my ( $file_path ) = @_;

    my $fh = IO::File->new( $file_path, '<' );
    flock $fh, LOCK_SH;
    my @lines = $fh->getlines();
    flock $fh, LOCK_UN;
    $fh->close();

    my $json = JSON::XS::decode_json( join( '', @lines ) );
    return ( $json->{'consumer_key'}, $json->{'consumer_secret'} );
}

1;
