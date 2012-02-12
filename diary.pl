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
my $command = shift @ARGV;
print length $command, "\n";

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

exit 0;
