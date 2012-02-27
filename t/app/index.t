#!perl
use strict;
use warnings;
use Test::More qw/no_plan/;
use HTTP::Status;
use Ridge::Test 'Diary';

is get('/index')->code, RC_OK;

1;
