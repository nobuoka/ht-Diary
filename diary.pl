#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib", glob "$FindBin::Bin/modules/*/lib";

# ソースコード中の文字列および標準入出力, コマンドライン引数のエンコーディング
use Encode::Locale;
use encoding "UTF-8", STDOUT => "console_out", STDIN => "console_in";
Encode::Locale::decode_argv();

# 出力テスト
print "あいうえお\n";
warn  "警告！\n";

# コマンドライン引数
#my $command = shift @ARGV;
#print length $command, "\n";

# DB の設定ファイルの位置
my $dbconfpath = "$FindBin::Bin/conf/db.conf";

#print $dbconfpath, "\n";
#use IO::File;
#my $dbconffile = IO::File->new( $dbconfpath, '<' );
#my @lines = $dbconffile->getlines();
#chomp( @lines );
#foreach( @lines ) {
#  print "::", $_, "\n";
#}
Diary::Database->load_db_config( $dbconfpath );

use Diary::MoCo::User;
Diary::Database->execute( 'TRUNCATE TABLE user' );
my $user1 = Diary::MoCo::User->create( name => 'test_user' );
my $user2 = Diary::MoCo::User->create( name => '日本語ユーザー名' );

my $users = Diary::MoCo::User->search();
$users->each( sub {
  print $_->name, "\n";
} );

###
# 既存の日記の内容をユーザーに編集させる
#
use File::Temp;
use Fcntl qw( :flock );
my $fh_dialy_body = File::Temp->new();
binmode $fh_dialy_body, ':encoding(UTF-8)';

# ファイルに書き込み
flock $fh_dialy_body, LOCK_EX;
print $fh_dialy_body '既存ファイルの内容', "\n";
flock $fh_dialy_body, LOCK_UN;

# テキストエディタを開いてユーザーに編集させる
system( '/usr/bin/vim', $fh_dialy_body->filename ) == 0
    or die 'fail...';

# 編集後の内容を得る
flock $fh_dialy_body, LOCK_SH;
$fh_dialy_body->seek( 0, SEEK_SET );
my @new_dialy_body_lines = <$fh_dialy_body>;
flock $fh_dialy_body, LOCK_UN;
$fh_dialy_body->close();

foreach my $line ( @new_dialy_body_lines ) {
    print $line;
}

print '__end__', "\n";

exit 0;
