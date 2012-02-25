###
# Diary::MoCo::User のテスト用クラス
# 
package t::Diary::MoCo::User;
use base 'Test::Class';

use strict;
use warnings;
use utf8;

# パスの追加
use lib '.', 'lib', 'modules/DBIx-MoCo/lib';

use Test::More;

use t::Diary;
use Diary::MoCo::User;

sub startup : Test(startup => 1) {
    use_ok 'Diary::MoCo::User';
    t::Diary->truncate_db;
}

sub add_article : Test(5) {
    # ユーザー作成
    ok 
        my $user = Diary::MoCo::User->create( 
            name => 'test_user_1', editor_cmd => 'vi', encoding => 'UTF-8' ), 
        'create user';

    # articles は空
    is_deeply 
        $user->articles->to_a, [];

    # 
    my $title = '日記タイトル';
    my $body  = "日記の本文です。\n\n改行も含みます。";
    my $article = $user->create_article( $title, $body ); 

    isa_ok $article, 'Diary::MoCo::Article';
    is $article->title, $title;
    is $article->body,  $body;


=begin
    is_deeply
        $user->bookmarks->map(sub { $_->entry->url })->to_a,
        [ 'http://www.example.com/' ],
        '$user->bookmarks';
=cut
}

__PACKAGE__->runtests;
