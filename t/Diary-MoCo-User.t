package t::Diary::MoCo::User;
use strict;
use warnings;
use utf8;
use base qw(Test::Class);
# Diary::MoCo::User のテスト用クラス

use Test::More;
use Test::Exception;

use lib '.', 'lib', 'modules/DBIx-MoCo/lib';
use t::Diary;
use Diary::MoCo::User;

# run before every test 
sub setup : Test(setup => 3) {
    my $self = shift;
    use_ok 'Diary::MoCo::User';
    t::Diary->truncate_db;

    # ユーザー作成
    ok 
        $self->{'user'} = Diary::MoCo::User->create( 
            name => 'test_user_1' ), 
        'create user';
    ok 
        $self->{'user2'} = Diary::MoCo::User->create( 
            name => 'test_user_2' ), 
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

sub paged_articles : Test(20) {
    my $self = shift;
    my $user = $self->{'user'};

    # articles は空
    is_deeply 
        $user->articles->to_a, [];

    # 
    my @article_sources = (
        [ '1', '日記の本文です。'],
        [ '2', "改行も\nあるよ"  ],
        [ '3', "改行も\nあるよ"  ],
        [ '4', "改行も\nあるよ"  ],
        [ '5', "改行も\nあるよ"  ],
        [ '6', "改行も\nあるよ"  ],
        [ '7', "改行も\nあるよ"  ],
        [ '8', "改行も\nあるよ"  ],
        [ '9', "改行も\nあるよ"  ],
    );
    foreach my $src_ref ( @article_sources ) {
        my $title = $src_ref->[0];
        my $body  = $src_ref->[1];
        my $article = $user->create_article( $title, $body ); 
    }

    is_deeply
        $user->paged_articles( 1, 2 )->map( sub { $_->title } )->to_a,
        [ '9', '8' ];
    is_deeply
        $user->paged_articles( 1, 17 )->map( sub { $_->title } )->to_a,
        [ '9', '8', '7', '6', '5', '4', '3', '2', '1' ];
    is_deeply
        $user->paged_articles( 3, 2 )->map( sub { $_->title } )->to_a,
        [ '5', '4' ];

    throws_ok { $user->paged_articles( 0, 2 ) } qr/invalid argument/, 'zero';
}

# 記事数テスト
sub count_articles : Test(8) {
    my $self = shift;
    my $user1 = $self->{'user'};
    my $user2 = $self->{'user2'};

    foreach my $u ( $user1, $user2 ) {
        # 
        is $u->num_articles, 0;
        my @article_sources = (
            [ '日記タイトル', '日記の本文です。'],
            [ '他のタイトル', "改行も\nあるよ"  ],
            [ '',             ''                ], # 空文字列
        );
        foreach my $i ( 0..$#article_sources ) {
            my $title = $article_sources[$i]->[0];
            my $body  = $article_sources[$i]->[1];
            $u->create_article( $title, $body );
            is $u->num_articles, $i + 1;
        }
    }
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

__PACKAGE__->runtests;
