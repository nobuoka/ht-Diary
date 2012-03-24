package t::Diary::MoCo::Article;
use strict;
use warnings;
use utf8;
use base qw(Test::Class);
# Diary::MoCo::Article のテスト用クラス

use Test::More;
use Test::Exception;

use lib '.', 'lib', 'modules/DBIx-MoCo/lib';
use t::Diary;
use Diary::MoCo::User;
use Diary::MoCo::Article;

sub startup : Test(startup => 3) {
    my $self = shift;
    use_ok 'Diary::MoCo::User';
    use_ok 'Diary::MoCo::Article';
    t::Diary->truncate_db;

    # ユーザー作成
    ok 
        $self->{'user'} = Diary::MoCo::User->create( 
            name => 'test_user_1' ), 
        'create user';
}

# 記事編集のテスト
sub edit_article2 : Test(9) {
    my $self = shift;
    my $user = $self->{'user'};

    my @article_sources = (
        [ '日記タイトル', '日記の本文です。'],
        [ '他のタイトル', "改行も\nあるよ"  ],
        [ '',             ''                ], # 空文字列
    );
    my @new_article_sources = (
        [ '新日記タイトル', '日記の本文です。'],
        [ undef,            ''                ],
        [ 'testll',         '新しく'          ], # 空文字列
    );
    foreach my $i ( 0..$#article_sources ) {
        my $src_ref     = $article_sources[$i];
        my $new_src_ref = $new_article_sources[$i];
        my $title     = $src_ref->[0];
        my $body      = $src_ref->[1];
        my $new_title = $new_src_ref->[0];
        my $new_body  = $new_src_ref->[1];
        my $article = $user->create_article( $title, $body ); 
        $article->edit( $new_title, $new_body ); 
        is $article->title, ( defined $new_title ? $new_title : $title );
        is $article->body,  $new_body;
        is $article->user->id, $user->id;
    }

}

# 記事編集のテスト
sub edit_article : Test(7) {
    my $self = shift;
    my $user = $self->{'user'};

    my $new_title = 'タイトル';
    my $new_body  = '本文';
    my $article = $user->create_article( 'test', 'test' );
    $article->edit( $new_title, $new_body );

    $article = $user->select_article_by_id( $article->id );
    is $article->title, $new_title;
    is $article->body,  $new_body ;

    my $a2 = $user->select_article_by_id( $article->id );
    is $a2->title, $new_title;
    is $a2->body,  $new_body ;

    # 引数チェックのテスト
    throws_ok { $article->edit(       ) } qr/invalid argument/, 'no argument';
    throws_ok { $article->edit( undef ) } qr/invalid argument/;
    throws_ok { $article->edit( ''    ) } qr/invalid argument/;
}

__PACKAGE__->runtests;
