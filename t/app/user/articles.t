package t::Diary::app::user::articles;
use strict;
use warnings;
use utf8;
use base qw(Test::Class);
# /user:{user_name}/articles のテスト

use lib 'lib';
use lib '.', 'lib', 'modules/DBIx-MoCo/lib';
use lib '.', 'lib', 'modules/Ridge/lib';

use t::Diary;
use Test::More qw/no_plan/;
use HTTP::Status;
use t::app::RidgeTest;
use Diary::MoCo::User;

###
# このテスト全体の初期化
sub startup : Test(startup) {
    my $self = shift;
    #use_ok 'Diary::MoCo::User';
    #use_ok 'Diary::MoCo::Article';
}

sub setup : Test(setup => 2) {
    my $self = shift;
    t::Diary->truncate_db;
    # ユーザー作成
    ok
        $self->{'user'} = Diary::MoCo::User->create( name => 'test_user_1' ),
        'create user';
    ok
        $self->{'user2'} = Diary::MoCo::User->create( name => 'test_user_2' ),
        'create user';
}

sub _access {
    is get('/user:test_user_1/articles')->code, RC_OK;
    is get('/user:test_user_1/articles?page=1')->code, RC_NOT_FOUND;
    is get('/user:test_user_2/articles')->code, RC_OK;
    is get('/user:test_user_3/articles')->code, RC_NOT_FOUND;
}

sub access : Test(8) {
    my $self = shift;
    _access();
    # authorized
    {
        local $t::app::RidgeTest::session = { user_id => $self->{'user'}->id };
        _access();
    }
}

sub post_and_access : Test {
    my $self = shift;

    # ログインしていない場合
    is post('/user:test_user_1/articles', [ title => 'test', body => 'blogbody' ] )->code,
       RC_UNAUTHORIZED;
    is post('/user:test_user_2/articles', [ title => 'test', body => 'blogbody' ] )->code,
       RC_UNAUTHORIZED;

    # authorized
    {
        local $t::app::RidgeTest::session = { user_id => $self->{'user'}->id };

        is post('/user:test_user_1/articles', [ title => 'test', body => 'blogbody' ] )->code,
           RC_SEE_OTHER;
        is post('/user:test_user_2/articles', [ title => 'test', body => 'blogbody' ] )->code,
           RC_FORBIDDEN;
        is get('/user:test_user_1/articles?page=1')->code, RC_OK;
    }
}

__PACKAGE__->runtests;
