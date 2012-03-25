package Diary::DBConf;
use strict;
use warnings;
use utf8;
# 日記のデータベースに接続する際の mysql ユーザー名, パスワード, 
# 接続先 DB 名を記述した設定ファイルのインターフェイスクラス

use IO::File;


### Class methods ###

###
# インスタンスを生成する
#   Diary::DBConf->new( $file_path [, $error_if_file_not_exist ] )
#
# @arg $file_path 設定ファイルのパス
# @arg $error_if_file_not_exist 
#               指定されたパスのファイルが存在しない場合にエラーにするかどうか.
#               デフォルトは 1 (例外発生させる)
sub new {
    my $pkg = shift;
    my ( $file_path, $error_if_fne ) = @_;
    if ( !defined $error_if_fne ) { $error_if_fne = 1; }

    if ( !-f $file_path && $error_if_fne ) {
        die "指定されたファイル $file_path は存在しません"
    }

    my $self = {
        'file_path' => $file_path,
    };
    bless $self, $pkg;

    if ( -f $file_path ) {
        $self->_load_config_file();
    }
    return $self;
}

### Instance methods ###

sub file_path {
    my $self = shift;
    return $self->{'file_path'};
}

sub file_exist {
    my $self = shift;
    return -f $self->{'file_path'};
}

sub dsn {
    my $self = shift;
    return $self->{'dsn'};
}

sub username {
    my $self = shift;
    return $self->{'username'};
}

sub password {
    my $self = shift;
    return $self->{'password'};
}

sub set_dsn {
    my $self = shift;
    my ( $dsn ) = @_;
    $self->{'dsn'} = $dsn;
    return 1;
}

sub set_username {
    my $self = shift;
    my ( $un ) = @_;
    $self->{'username'} = $un;
    return 1;
}

sub set_password {
    my $self = shift;
    my ( $pw ) = @_;
    $self->{'password'} = $pw;
    return 1;
}

###
# 設定ファイルに保存
#
sub save {
    my $self = shift;
    my ( $dsn, $un, $pw ) = ( $self->dsn, $self->username, $self->password );

    if ( !defined $dsn || !defined $un || !defined $pw ) {
        die '設定されていない項目があります';
    }

my $conf_text =<<"END_OF_CONF";
# dsn
$dsn
# username
$un
# password
$pw
END_OF_CONF

    my $path = $self->file_path;
    my $f = IO::File->new( $self->file_path, 'w' )
        or die "failed to open file $path";
    print {$f} $conf_text;
    $f->close();

    return 1;
}

###
# 設定ファイルを読み込み, 
sub _load_config_file {
    my $self = shift;

    #print $dbconfpath, "\n";
    my $fh = IO::File->new( $self->file_path, '<' );
    my @lines = $fh->getlines();
    chomp( @lines );
    # 設定ファイルのコメント行を取り除く
    @lines = grep( !/^#/, @lines );
    $fh->close();

    $self->{'dsn'}      = $lines[0];
    $self->{'username'} = $lines[1];
    $self->{'password'} = $lines[2];
    return 1;
}

1;
