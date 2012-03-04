package Diary::Config;
use strict;
use warnings;
use base qw/Ridge::Config/;
use Path::Class qw/file/;

my $root = file(__FILE__)->dir->parent->parent->parent;

__PACKAGE__->setup({
    root          => __PACKAGE__->find_root,
    namespace     => 'Diary',
    charset       => 'utf-8',
    ignore_config => 1,
    static_path   => [
        '^/images\/',
        '^/js\/',
        '^/css\/',
        '^/style\/',
        '^/favicon\.ico',
    ],
    URI => {
        use_lite => 1,
        filter   => \&uri_filter,
    },

    ## Application specific configuration
    app_config => {
        default => {
            uri => URI->new('http://local.hatena.ne.jp:3000/'),
        },
    }
});

sub uri_filter {
    my $uri = shift;
    my $path = $uri->path;
    if ( $path =~ m{\A/user%3A([^/?]+)/articles([.]|/|\z)} ) {
        $uri->path( '/articles' . $2 );
        $uri->param( user_name => $1 );
    }
    elsif ( $path =~ m{\A/user%3A([^/?]+)/article%3A([^/?]+)([.]|/|\z)} ) {
        $uri->path( '/article' . $3 );
        $uri->param( user_name  => $1 );
        $uri->param( article_id => $2 );
    }
    $uri;
}

1;
