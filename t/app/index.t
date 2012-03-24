package t::Diary::app::index;
use strict;
use warnings;
use utf8;
use base qw(Test::Class);
# /index のテスト

use lib 'lib';
use lib '.', 'lib', 'modules/DBIx-MoCo/lib';
use lib '.', 'lib', 'modules/Ridge/lib';

use t::Diary;
use Test::More qw/no_plan/;
use HTTP::Status;
#use Ridge::Test 'Diary';
use t::app::RidgeTest;
use Diary::MoCo::User;

###
# このテスト全体の初期化
sub startup : Test(startup) {
    my $self = shift;
    #use_ok 'Diary::MoCo::User';
    #use_ok 'Diary::MoCo::Article';
}

sub setup : Test(setup => 1) {
    my $self = shift;
    t::Diary->truncate_db;
    # ユーザー作成
    ok
        $self->{'user'} = Diary::MoCo::User->create( name => 'test_user_1' ),
        'create user';
}


sub access : Test(2) {
    my $self = shift;
    is get('/')->code, RC_OK;
    is get('/user:test_user_1/articles')->code, RC_OK;
}

__PACKAGE__->runtests;
