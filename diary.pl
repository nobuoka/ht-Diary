#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib", glob "$FindBin::Bin/modules/*/lib";

# ソースコード中の文字列および標準入出力, コマンドライン引数のエンコーディング
use Encode::Locale;
use encoding "UTF-8", STDOUT => "console_out", STDIN => "console_in";
Encode::Locale::decode_argv();

# 出力テスト
print "あいうえお\n";
warn  "警告！\n";

# コマンドライン引数
my $command = shift @ARGV;
print length $command, "\n";

exit 0;
