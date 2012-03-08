###
# Diary::Config 内の URI フィルターに関するテスト
# 
package t::Diary::Config::uri_filter;
use base 'Test::Class';

use strict;
use warnings;
use utf8;

# パスの追加
use lib '.', 'lib', 'modules/DBIx-MoCo/lib', 'modules/Ridge/lib';

use Test::More;
use Test::Exception;

use t::Diary;
use Diary::Config;

sub startup : Test(startup => 1) {
    my $self = shift;
    use_ok 'Diary::Config';
}

# URI のパス部品 (スラッシュで区切られた部分) を処理する関数のテスト
sub path_component_filter : Test(4) {
    my $self = shift;

    my %path_components = (
        # 単純な値
        'article'              => [ 'article', undef, undef    ],
        # パス中にパラメータを含む
        'article%3A232'        => [ 'article', '232', undef    ],
        # パス中にコマンドを含む
        'article%3Bdelete'       => [ 'article', undef, 'delete' ],
        # パス中にパラメータもコマンドも含む
        'article%3A232%3Bdelete' => [ 'article', '232', 'delete' ],
    );

    # articles は空
    foreach my $comp ( keys %path_components ) {
        my @comp_arr = Diary::Config::_path_component_filter( $comp );
        is_deeply
            [ @comp_arr ],
            $path_components{$comp};
    }
}

__PACKAGE__->runtests;
