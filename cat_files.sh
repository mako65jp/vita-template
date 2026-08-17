#!/bin/bash

# 引数が指定されていない場合は使い方を表示して終了
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <ファイル|フォルダ|ワイルドカード...>"
    exit 1
fi

# ワイルドカードに一致するファイルがない場合に、パターン文字列がそのまま残るのを防ぐ
shopt -s nullglob

for target in "$@"; do
    if [ -f "$target" ]; then
        # 対象がファイルの場合
        echo "$target :"
        cat "$target"
        echo ""
    elif [ -d "$target" ]; then
        # 対象がディレクトリの場合、配下のファイルを再帰的に出力
        find "$target" -type f | while read -r file; do
            echo "$file :"
            cat "$file"
            echo ""
        done
    else
        echo "警告: '$target' に一致するファイルやフォルダが見つかりません。" >&2
    fi
done
