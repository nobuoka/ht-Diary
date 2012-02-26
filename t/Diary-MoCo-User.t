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
use Test::Exception;

use t::Diary;
use Diary::MoCo::User;

sub startup : Test(startup => 2) {
    my $self = shift;
    use_ok 'Diary::MoCo::User';
    t::Diary->truncate_db;

    # ユーザー作成
    ok 
        $self->{'user'} = Diary::MoCo::User->create( 
            name => 'test_user_1', editor_cmd => 'vi', encoding => 'UTF-8' ), 
        'create user';
}

# 記事作成のテスト
sub add_article : Test(11) {
    my $self = shift;
    my $user = $self->{'user'};

    # articles は空
    is_deeply 
        $user->articles->to_a, [];

    # 
    my @article_sources = (
        [ '日記タイトル', '日記の本文です。'],
        [ '他のタイトル', "改行も\nあるよ"  ],
        [ '',             ''                ], # 空文字列
    );
    foreach my $src_ref ( @article_sources ) {
        my $title = $src_ref->[0];
        my $body  = $src_ref->[1];
        my $article = $user->create_article( $title, $body ); 
        isa_ok $article, 'Diary::MoCo::Article';
        is $article->title, $title;
        is $article->body,  $body;
    }

    is_deeply
        [ sort @{$user->articles->map( sub { $_->title } )->to_a} ],
        [ sort ( map { $_->[0] } @article_sources ) ];
}

# 記事作成の失敗のテスト
sub fail_to_add : Test(6) {
    my $self = shift;
    my $user = $self->{'user'};

    throws_ok { $user->create_article(            ) } qr/invalid argument/, 'no argument';
    throws_ok { $user->create_article( ''         ) } qr/invalid argument/, 'one argument';
    throws_ok { $user->create_article( '', '', '' ) } qr/invalid argument/, 'three argument';

    throws_ok { $user->create_article( undef, undef ) } qr/invalid argument/, 'undef';
    throws_ok { $user->create_article( undef, ''    ) } qr/invalid argument/, 'undef';
    throws_ok { $user->create_article( '',    undef ) } qr/invalid argument/, 'undef';
}

# 記事削除のテスト
sub del_article : Test(4) {
    my $self = shift;
    my $user = $self->{'user'};

    my $article = $user->create_article( 'test', 'test' );
    ok $user->delete_article_by_id( $article->id );

    # 不正な引数
    throws_ok { $user->delete_article_by_id() } qr/invalid argument/, 'invalid argument';
    throws_ok { $user->delete_article_by_id( undef ) } qr/invalid argument/, 'invalid argument';

    # 存在しない id
    throws_ok { $user->delete_article_by_id( -1 ) } qr/not found/, 'not found';
}

sub edit_article : Test(2) {
    my $self = shift;
    my $user = $self->{'user'};

    my $new_title = 'タイトル';
    my $new_body  = '本文';
    my $article = $user->create_article( 'test', 'test' );
    $article->edit( $new_title, $new_body );

    my $a2 = $user->select_article_by_id( $article->id );
    is $a2->title, $new_title;
    is $a2->body,  $new_body ;
}

__PACKAGE__->runtests;
