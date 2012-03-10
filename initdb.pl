#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use IO::Prompt;
use IO::Pipe;
use File::Temp; # 日記の内容を編集する際の一時ファイル
use Fcntl qw( :flock ); # ファイルロックの定数

# パスの追加
use FindBin;
use lib "$FindBin::Bin/lib", glob "$FindBin::Bin/modules/*/lib";

use Diary::DBConf;
use Diary::MoCo::User;

# ソースコード中の文字列および標準入出力, コマンドライン引数のエンコーディング
use Encode::Locale;
use encoding "UTF-8", STDOUT => "console_out", STDIN => "console_in";
Encode::Locale::decode_argv();

# DB の設定ファイルの位置
my $dbconfpath_for_prod = "$FindBin::Bin/config/db_for_production.conf";
my $dbconfpath_for_test = "$FindBin::Bin/config/db_for_test.conf";

print "this process initialize mysql database for diary.\n";
my $target_env = prompt 'which envionment do you want to initialize? ', "\n"
       . '  (1: production env., 2: test env., 3: both env., 0: quit):'
       , -requires => { 'Must be 1, 2, 3 or 0: ' => qr/\A[0123]\z/xms };
exit 0 if ( $target_env == '0' );
my $mysql_username = prompt 'Enter a user name for mysql: ';
my $mysql_password = prompt 'Enter a password for mysql: ', -echo => '*';

# 本番環境
if ( $target_env == 1 || $target_env == 3 ) {
    init_db( 'production env.', $dbconfpath_for_prod );
}

# テスト環境
if ( $target_env == 2 || $target_env == 3 ) {
    init_db( 'test env.', $dbconfpath_for_test );
}

exit 0;

sub init_db {
    my ( $target_name, $conf_file_path ) = @_;

    print '###', "\n";
    print '# start initializing db for ', $target_name, "\n";
    print '###', "\n";

    my $mysql_dbname = prompt 'Enter a database name for ', $target_name, ': ';
    system( 'mysql', "--user=$mysql_username"
            , "--password=$mysql_password", '-e', qq{DROP DATABASE IF EXISTS $mysql_dbname} ) == 0
        or die "failed to drop database";
    system( 'mysql', "--user=$mysql_username"
            , "--password=$mysql_password", '-e', qq{CREATE DATABASE $mysql_dbname} ) == 0
        or die "failed to create database";
    #system( 'mysql', "--user=$mysql_username"
    #        , "--password=$mysql_password", $mysql_dbname
    #        , '-e', qq{SOURCE $FindBin::Bin/db/schema.sql} ) == 0
    #    or die "failed to load scheme.sql";
    my $pipe = IO::Pipe->new();
    $pipe->writer( 'mysql', "-u$mysql_username", "-p$mysql_password", $mysql_dbname );
    my $fh = IO::File->new( "$FindBin::Bin/db/schema.sql", 'r' )
        or die "faild to open db/schema.sql file";
    while ( my $line = <$fh> ) {
        print {$pipe} $line;
    }
    $fh->close();
    $pipe->close();

    my $dbconf = Diary::DBConf->new( $conf_file_path, 0 );
    $dbconf->set_dsn( "dbi:mysql:dbname=$mysql_dbname" );
    $dbconf->set_username( $mysql_username );
    $dbconf->set_password( $mysql_password );
    $dbconf->save();

    print '[SUCCESS]', "\n";
}

__END__

# 処理内容
my %HANDLERS = (
    add      => \&add_diary,
    list     => \&list_diary,
    edit     => \&edit_diary,
    delete   => \&delete_diary,
    userconf => \&conf_user,
    '--help' => \&show_help,
);


# Database に関する設定を読み込み
Diary::Database->load_db_config( $dbconfpath );

# コマンドライン引数
#my $command = shift @ARGV;
#print length $command, "\n";
my $command = shift @ARGV || '--help';

my $handler = $HANDLERS{ $command };
    #or pod2usage;

# ユーザーオブジェクトの取得 (必要ならばデータベースに登録)
#my $user = Diary::MoCo::User->find( name => $ENV{USER} );
#|| Diary::MoCo::User->create( name => $ENV{USER} );

# 処理の実行
$handler->( @ARGV );

#Diary::Database->execute( 'TRUNCATE TABLE user' );
#my $user1 = Diary::MoCo::User->create( name => 'test_user' );
#my $user2 = Diary::MoCo::User->create( name => '日本語ユーザー名' );

#my $users = Diary::MoCo::User->search();
#$users->each( sub {
#  print $_->name, "\n";
#} );

#print '__end__', "\n";

exit 0;
