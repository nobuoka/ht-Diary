package Diary::Config;
use strict;
use warnings;
use Ridge::Config;
use base qw/Ridge::Config/;
use Path::Class qw/file/;
use URI;

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

my %path_param_name = (
    'article' => 'article_id',
    'user'    => 'user_name' ,
);
sub uri_filter {
    my $uri = shift;
    my $path = $uri->path;
    my @comps = split( m{/}, $path, -1 );
    my @new_comps = ();
    foreach my $comp ( @comps ) {
        my ( $b, $i, $c ) = _path_component_filter( $comp );
        if ( my $k = $path_param_name{$b} ) {
            $uri->param( $k, $i );
        } else {
            # TODO: 不明なパラメータ
        }
        push @new_comps, ( defined $c ) ? ( $b . '.' . $c ) : $b;
    }
    $uri->path( join '/', @new_comps );
    return $uri;
}

###
# path の構成要素 (スラッシュで囲まれた部分) を, 
# base:id;cmd 形式で認識して ( base, id, cmd ) のリストで返す
# id 部, cmd 部は, 存在しない場合は undef になる
sub _path_component_filter {
    my ( $path_component ) = @_;
    # 空文字列の場合そのまま終了
    return ( $path_component, undef, undef ) if $path_component eq '';

    # セミコロン (; - \x3B) で区切られた部分を取り出す
    my ( $t   , $cmd ) = split /%3B/, $path_component, 2;
    # コロン (: - \x3A) で区切られた部分を取り出す
    my ( $base, $id  ) = split /%3A/, $t, 2;
    return ( $base, $id, $cmd );
}

1;
