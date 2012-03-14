package Diary;
use strict;
use warnings;
use base qw/Ridge/;

use Diary::Database;

__PACKAGE__->configure;

sub truncate_db {
    for ( qw(user entry) ) {
        Diary::Database->execute( "TRUNCATE TABLE $_" );
    }
}

###
# ログイン中のユーザーを返す.
# ログインしてない場合は undef を返す
sub user {
    my $self = shift;

    my $session = $self->req->session
            or return;
    my $user_id = $session->{'user_id'}
            or return;
    my $user = Diary::MoCo::User->find( id => $user_id )
            or return;
    return $user;
}

# ------------------
#  出力用エスケープ
# ------------------

###
# XXX Templates のフィルターにする
# HTML 内にテキストとして出力する文字を, HTML として解釈され内容にエスケープ
sub esc_html {
    my $self = shift;
    my ( $str ) = @_;

    $str =~ s/&/&amp;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    $str;
}

###
# XXX Templates のフィルターにする
# 改行を br タグに
sub conv_lf_to_br_tag {
    my $self = shift;
    my ( $str ) = @_;

    $str =~ s/\n/<br>/g;
    $str;
}

1;
