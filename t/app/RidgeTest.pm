use strict;
use warnings;
use utf8;

use Ridge::Test 'Diary';

package t::app::RidgeTest;

$t::app::RidgeTest::session = {};

package Ridge::Test;
{
    no warnings 'redefine';
*Ridge::Test::request = sub {
    my ($req) = @_;
    my $callpkg = caller(1);
    my $res;
    my $app;
    {
        no strict 'refs';
        my $app_tmp = \&{"$callpkg\::_APP"}; # これは Ridge::Test の import メソッド内で作られるメソッド
        $app = sub {
            my $env = shift;
            my $session_hash = ( $env->{'psgix.session'} ||= {} );
            foreach ( keys %{$t::app::RidgeTest::session} ) {
                $session_hash->{$_} = $t::app::RidgeTest::session->{$_};
            }
            #$session_hash->{'user_id'} = '1';
            $app_tmp->( $env );
        };
    };
    test_psgi $app, sub {
        my $cb = shift;
        $res = $cb->($req);
    };
    $res;
};
}

1;
