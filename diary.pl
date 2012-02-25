#!/usr/bin/env perl

use strict;
use warnings;

use File::Temp; # 日記の内容を編集する際の一時ファイル
use Fcntl qw( :flock ); # ファイルロックの定数
use Pod::Usage;

# パスの追加
use FindBin;
use lib "$FindBin::Bin/lib", glob "$FindBin::Bin/modules/*/lib";

use Diary::MoCo::User;

# ソースコード中の文字列および標準入出力, コマンドライン引数のエンコーディング
use Encode::Locale;
use encoding "UTF-8", STDOUT => "console_out", STDIN => "console_in";
binmode STDERR, ":encoding(console_out)";
Encode::Locale::decode_argv();

# DB の設定ファイルの位置
my $dbconfpath = "$FindBin::Bin/conf/db_for_production.conf";

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
if ( !-f $dbconfpath ) {
    print STDERR '接続先 DB の設定ファイルが存在しません. ' . "\n"
                    . 'はじめに initdb.pl を使用して接続先 DB の設定を行ってください.' . "\n";
    exit -1;
}
Diary::Database->load_db_config( $dbconfpath );

# コマンドライン引数
#my $command = shift @ARGV;
#print length $command, "\n";
if ( @ARGV == 0 ) {
    pod2usage({ -exitval => 1, -msg => 'コマンドを指定してください' });
}
my $command = shift @ARGV;

my $handler = $HANDLERS{ $command }
    or pod2usage({ -exitval => 1, -msg => "コマンド $command は理解できません" });

# 処理の実行
$handler->( @ARGV );

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
    print $fh_dialy_body $old_text;
    flock $fh_dialy_body, LOCK_UN;

    # テキストエディタを開いてユーザーに編集させる
    system( $editor_cmd, $fh_dialy_body->filename ) == 0
        or die "failed to execute $editor_cmd";

    # 編集後の内容を得る
    flock $fh_dialy_body, LOCK_SH;
    $fh_dialy_body->seek( 0, SEEK_SET );
    my $new_text = do { local $/; <$fh_dialy_body> };
    flock $fh_dialy_body, LOCK_UN;
    $fh_dialy_body->close();

    return $new_text; 
}


###
# ユーザーオブジェクトを取得
# 
sub get_user {
    #my $uid = $>;
    my $user_name = $ENV{'USER'};
    my $user = Diary::MoCo::User->find( name => $user_name )
        or die "can't find you on database. please do userconf command at first.";
    return $user;
}

###
# 日記エントリー一覧の表示
#
sub list_diary {
    #my () = @_;

    my $user = get_user();
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
    if( @_ != 1 ) {
        die 'add command requires 1 argument (article_title)';
    }
    my ( $article_title ) = @_;

    my $user = get_user();
    #die 'url required' if not defined $url;

    my $article_body = let_user_input_text( $user->editor_cmd, '' );
    my $article = $user->create_article( $article_title, $article_body );
    print '[SUCCESS] wrote new article (id: ', $article->id, ') : ', $article->title, "\n";
}

###
# 既存日記エントリーの編集
#
sub edit_diary {
    if ( @_ < 1 ) {
        die 'edit command requires 1 argument (article_id)';
    }
    my ( $article_id, $article_title ) = @_;

    my $user = get_user();
    #die 'url required' if not defined $url;
    my $article = $user->select_article_by_id( $article_id )
        or die "article id=$article_id not found";

    my $new_article_body = let_user_input_text( $user->editor_cmd, $article->body );
    # TODO: title の変更
    $article->edit( $article_title, $new_article_body );
    print '[SUCCESS] edited article (id: ', $article->id, ') : ', $article->title, "\n";
}

###
# 既存日記エントリーの削除
#
sub delete_diary {
    my ( $article_id ) = @_;
    #die 'delete command requires 1 argument (article_id)' if not defined $article_id;

    my $user = get_user();

    $user->delete_article_by_id( $article_id )
        or die "failed to delete article (id=$article_id)";
    print '[SUCCESS] deleted ', "\n";
}

###
# ユーザーを登録
#
sub conf_user {
    if( @_ != 2 ) {
        die 'userconf command requires 2 arguments (editor_cmd, encoding)';
    }
    my ( $editor_cmd, $encoding ) = @_;

    #my $uid = $>; # 実効 UID
    my $user_name = $ENV{'USER'};
    my $user = Diary::MoCo::User->find( name => $user_name );
    # 既に DB に存在する場合
    if ( $user ) {
        $user->update(
            name       => $user_name,
            editor_cmd => $editor_cmd,
            encoding   => $encoding,
        );
    }
    # DB に存在しない場合
    else {
        Diary::MoCo::User->create(
            name       => $user_name,
            editor_cmd => $editor_cmd,
            encoding   => $encoding,
        );
    }
    print '[SUCCESS]', "\n";
}

sub show_help {
    pod2usage( 0 );
}

__END__

=head1 NAME

dialy.pl

=head1 SYNOPSIS

  dialy.pl add      article_titile
  dialy.pl edit     article_id [ new_article_title ]
  dialy.pl list
  dialy.pl delete   article_id
  dialy.pl userconf editor_cmd encoding
  dialy.pl --help

=head1 COMMANDS

=over 8

=item B<add>

新しい日記記事を作成します. 
add の引数として日記のタイトルを与える必要があります.
このコマンドが実行されると userconf 
コマンドで指定したテキストエディタが起動されますので, 
そこに日記の本文を記述してください. 

日記記事の作成後, 作成した日記記事の id が表示されます. 

=item B<edit>

指定した id の日記記事を編集します. 
タイトルを変更する場合は, 日記記事の id 
に続けて新しい記事のタイトルを記述してください. 
このコマンドが実行されると userconf 
コマンドで指定したテキストエディタが起動されますので, 
そこで日記の本文を修正してください. 

=item B<list>

あなたが書いた日記記事の一覧を表示します. 
日記記事は, そのタイトルと id のみが表示されます. 

=item B<delete>

指定した id の日記記事を削除します.

=item B<userconf>

add コマンドや edit コマンドが実行された際に起動されるテキストエディタと, 
そのテキストエディタで編集するファイルのエンコーディングを指定します. 
また, ユーザー登録がされていない場合は, このコマンドによってユーザー登録を
行いますので, 最初にこのコマンドを実行してください. 

=back

=cut
