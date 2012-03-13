#!perl
use strict;
use warnings;

use lib '.', 'lib', 'modules/DBIx-MoCo/lib';
use lib '.', 'lib', 'modules/Ridge/lib';

use t::Diary;
use Test::More qw/no_plan/;
use HTTP::Status;
use Ridge::Test 'Diary';


is get('/')->code, RC_OK;
print get('/')->message;

1;
