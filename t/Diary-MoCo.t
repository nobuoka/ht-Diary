package t::Diary::MoCo;
use strict;
use warnings;
use base qw(Test::Class);

use lib '.', 'lib', 'modules/DBIx-MoCo/lib';

use Test::More;

use t::Diary;
use Diary::MoCo;

sub startup : Test(startup => 1) {
    use_ok 'Diary::MoCo';
}

__PACKAGE__->runtests;
