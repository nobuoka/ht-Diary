use Ridge::Test 'Diary';

package Ridge::Test;
*Ridge::Test::request = sub {
    my ($req) = @_;
    my $callpkg = caller(1);
    my $res;
    my $app;
    {
        no strict 'refs';
        $app_tmp = \&{"$callpkg\::_APP"}; # これは Ridge::Test の import メソッド内で作られるメソッド
        $app = sub {
            my $env = shift;
            my $session_hash = ( $env->{'psgix.session'} ||= {} );
            $session_hash->{'user_id'} = '1';
            $app_tmp->( $env );
        };
    };
    test_psgi $app, sub {
        my $cb = shift;
        $res = $cb->($req);
    };
    $res;
};

1;

__END__

package Ridge::Test;
use strict;
use warnings;
use Ridge::Test 'Diary';

sub request {
    my ($req) = @_;
    my $callpkg = caller(1);
    my $res;
    my $app;
    {
        no strict 'refs';
        $app = \&{"$callpkg\::_APP"};
    };
    test_psgi $app, sub {
        my $cb = shift;
        $res = $cb->($req);
    };
    $res;
}

1;

__END__

sub import {
    my ($class, $namespace, @args) = @_;
    my $callpkg = scalar caller;
    $namespace or croak "Usage: use Ridge::Test 'MyApp'";
    $namespace->require or die $@;

    {
        no strict 'refs';
        *{"$callpkg\::_APP"} = sub {
            my $env = shift;
            $namespace->process($env, {});
        };
    };
    my %args = @_;
    CLASS->host($args{host}) if $args{host};
    CLASS->port($args{port} || empty_port());

    for my $func (@EXPORT) {
        no strict 'refs';
        *{"$callpkg\::$func"} = \&$func;
    }
}

sub _root {
    sprintf('http://%s:%d/', CLASS->host, CLASS->port)
}

sub get {
    my ($path, @params) = @_;
    request(GET $path, @params);
}

sub post {
    my ($path, @params) = @_;
    request(POST $path, @params);
}

sub request {
    my ($req) = @_;
    my $callpkg = caller(1);
    my $res;
    my $app;
    {
        no strict 'refs';
        $app = \&{"$callpkg\::_APP"};
    };
    test_psgi $app, sub {
        my $cb = shift;
        $res = $cb->($req);
    };
    $res;
}


sub HTTP::Response::status_code_is {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($self, $expect) = @_;
    is $self->code, $expect;
}

sub HTTP::Response::header_is {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($self, $header, $expect) = @_;
    is $self->headers->header($header), $expect;
}

sub HTTP::Response::body_is {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($self, $expect) = @_;
    is $self->content, $expect;
}

sub HTTP::Response::body_like {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($self, $regex) = @_;
    like $self->content, $regex;
}

sub HTTP::Response::header_like {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($self, $header, $regex) = @_;
    like $self->headers->header($header), $regex;
}

1;
