package t::Diary::MoCo::UserHatena;
use strict;
use warnings;
use utf8;
use base qw(Test::Class);
# Diary::MoCo::UserHatena のテスト用クラス

use Test::More;
use Test::Exception;

use lib '.', 'lib', 'modules/DBIx-MoCo/lib';
use t::Diary;
use Diary::MoCo::UserHatena;

# run before every test 
sub setup : Test(setup => 3) {
    my $self = shift;
    use_ok 'Diary::MoCo::UserHatena';
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

__PACKAGE__->runtests;
