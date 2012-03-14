#!perl
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
use Ridge::Test 'Diary';

###
# このテスト全体の初期化
sub startup : Test(startup => 0) {
    my $self = shift;
    #use_ok 'Diary::MoCo::User';
    #use_ok 'Diary::MoCo::Article';
    #t::Diary->truncate_db;
}

sub setup : Test(setup => 0 ) {
    my $self = shift;
    # ユーザー作成
    #ok 
    #    $self->{'user'} = Diary::MoCo::User->create( 
    #        name => 'test_user_1' ), 
    #    'create user';
}


sub access : Test(1) {
    my $self = shift;
    is get('/')->code, RC_OK;
}

__PACKAGE__->runtests;
