#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp; # 日記の内容を編集する際の一時ファイル
use Fcntl qw( :flock ); # ファイルロックの定数

# パスの追加
use FindBin;
use lib "$FindBin::Bin/lib", glob "$FindBin::Bin/modules/*/lib";

use Diary::MoCo::User;

# ソースコード中の文字列および標準入出力, コマンドライン引数のエンコーディング
use Encode::Locale;
use encoding "UTF-8", STDOUT => "console_out", STDIN => "console_in";
Encode::Locale::decode_argv();

# DB の設定ファイルの位置
my $dbconfpath = "$FindBin::Bin/conf/db.conf";

# 処理内容
my %HANDLERS = (
    add    => \&add_diary,
    list   => \&list_diary,
    edit   => \&edit_diary,
    delete => \&delete_diary,
);



Diary::Database->load_db_config( $dbconfpath );

# コマンドライン引数
#my $command = shift @ARGV;
#print length $command, "\n";
my $command = shift @ARGV || 'list';

my $handler = $HANDLERS{ $command };
    #or pod2usage;

my $user = 
    Diary::MoCo::User->find( name => $ENV{USER} ) 
    || Diary::MoCo::User->create( name => $ENV{USER} );
$handler->( $user, @ARGV );

Diary::Database->execute( 'TRUNCATE TABLE user' );
my $user1 = Diary::MoCo::User->create( name => 'test_user' );
my $user2 = Diary::MoCo::User->create( name => '日本語ユーザー名' );

my $users = Diary::MoCo::User->search();
$users->each( sub {
  print $_->name, "\n";
} );

print '__end__', "\n";

exit 0;


###
# 既存の日記の内容をユーザーに編集させる
#
sub let_user_input_text {
    my ( $editor_cmd, $old_text, $file_encoding ) = @_;
    $file_encoding ||= 'UTF-8';

    my $fh_dialy_body = File::Temp->new();
    binmode $fh_dialy_body, ":encoding($file_encoding)";

    # ファイルに書き込み
    flock $fh_dialy_body, LOCK_EX;
    print $fh_dialy_body $old_text, "\n";
    flock $fh_dialy_body, LOCK_UN;

    # テキストエディタを開いてユーザーに編集させる
    system( $editor_cmd, $fh_dialy_body->filename ) == 0
        or die 'fail...';

    # 編集後の内容を得る
    flock $fh_dialy_body, LOCK_SH;
    $fh_dialy_body->seek( 0, SEEK_SET );
    my @new_text_lines = <$fh_dialy_body>;
    flock $fh_dialy_body, LOCK_UN;
    $fh_dialy_body->close();

    return join( '', @new_text_lines );
}

###
# 日記エントリー一覧の表示
#
sub list_diary {
    my ( $user ) = @_;

    printf " *** %s's articles ***\n", $user->name;

    my $articles = $user->articles;
    foreach my $article ( @$articles ) {
        print $article->title, ' (id: ', $article->id, ')', "\n";
    }
}

###
# 日記エントリーの新規追加
#
sub add_diary {
    my ( $user, $article_title, $editor_cmd ) = @_;

    #die 'url required' if not defined $url;

    my $article_body = let_user_input_text( $editor_cmd, '' );
    my $article = $user->add_article(
        title => $article_title,
        body  => $article_body,
    );
    print 'wrote new article (id: ', $article->id, ') : ', $article->title, "\n";
}

###
# 既存日記エントリーの編集
#
sub edit_diary {
    my ( $user, $article_id, $editor_cmd, $article_title ) = @_;

    #die 'url required' if not defined $url;
    my $article = Diary::MoCo::Article->find( id => $article_id )
        or die "article id=$article_id not found";

    my $new_article_body = let_user_input_text( $editor_cmd, $article->body );
    # TODO: title の変更
    $article->update_body( $new_article_body );
    print 'edited article (id: ', $article->id, ') : ', $article->title, "\n";
}

###
# 既存日記エントリーの削除
#
sub delete_diary {
    my ( $user, $article_id ) = @_;

    die 'article_id required' if not defined $article_id;

    Diary::MoCo::User->delete_article_by_id( $article_id )
        or die "article id=$article_id not found";
    #my $bookmark = $user->delete_bookmark($entry);
    #if ($bookmark) {
    #    print 'deleted ', $bookmark->as_string, "\n";
    #}
}
