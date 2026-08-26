#!/bin/bash

RECURSIVE=false
SHOW_PATH_ONLY=false
EXCLUDE_PATTERN=""

# オプション解析
while getopts "rRlL-e:" opt; do
    case "$opt" in
        r|R) RECURSIVE=true ;;
        l|L) SHOW_PATH_ONLY=true ;;
        e)   EXCLUDE_PATTERN="$OPTARG" ;;
        *)   echo "使用方法: $0 [-r] [-l] [-e 除外パターン] <ファイル|フォルダ|ワイルドカード...>" ; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -eq 0 ]; then
    echo "使用方法: $0 [-r] [-l] [-e 除外パターン] <ファイル|フォルダ|ワイルドカード...>"
    exit 1
fi

print_file() {
    local file="$1"
    if [ "$SHOW_PATH_ONLY" = true ]; then
        echo "$file"
    else
        echo "$file :"
        cat "$file"
        echo ""
    fi
}

# 除外判定関数
is_excluded() {
    local path="$1"
    local filename
    filename=$(basename "$path")

    # 常時除外したいフォルダ名のリスト
    local exclude_dirs=("node_modules" ".git" "dist" "build" "coverage" ".vscode")

    # リスト内のフォルダがパスに含まれているかチェック
    for dir in "${exclude_dirs[@]}"; do
        if [[ "$path" == */"$dir"/* ]] || [[ "$filename" == "$dir" ]]; then
            return 0 # 除外対象
        fi
    done
    
    # ユーザー指定の除外パターン（-e オプション）のチェック
    if [ -n "$EXCLUDE_PATTERN" ]; then
        if [[ "$filename" == $EXCLUDE_PATTERN ]] || [[ "$path" == *$EXCLUDE_PATTERN* ]]; then
            return 0 # 除外対象
        fi
    fi
    return 1 # 除外対象外
}

for target in "$@"; do
    if [ "$RECURSIVE" = true ]; then
        # ==========================================
        # -r 指定時：カレントフォルダ(.)を含め再帰検索
        # ==========================================
        if [ -d "$target" ]; then
            search_dir="$target"
            pattern=""
        else
            search_dir="."
            pattern=$(basename "$target")
        fi

        if [ -n "$pattern" ]; then
            find_cmd=(find "$search_dir" -type f -name "$pattern")
        else
            find_cmd=(find "$search_dir" -type f)
        fi

        found_any=false      # find でファイルが見つかったか
        printed_any=false    # 除外を抜けて実際に出力されたか

        while read -r file; do
            [ -z "$file" ] && continue
            found_any=true
            if ! is_excluded "$file"; then
                print_file "$file"
                printed_any=true
            fi
        done < <("${find_cmd[@]}" 2>/dev/null)

        # そもそもファイルが存在しない場合のみ警告を表示
        if [ "$found_any" = false ]; then
            echo "警告: '$target' に一致するファイルが見つかりません。" >&2
        fi

    else
        # ==========================================
        # -r なし：指定されたパスのみを直接処理
        # ==========================================
        if [ -f "$target" ]; then
            if ! is_excluded "$target"; then
                print_file "$target"
            fi
        elif [ -d "$target" ]; then
            found_any=false
            while read -r file; do
                [ -z "$file" ] && continue
                found_any=true
                if ! is_excluded "$file"; then
                    print_file "$file"
                fi
            done < <(find "$target" -type f 2>/dev/null)

            if [ "$found_any" = false ]; then
                echo "警告: フォルダ '$target' 内にファイルが見つかりません。" >&2
            fi
        else
            echo "警告: '$target' に一致するファイルやフォルダが見つかりません。" >&2
        fi
    fi
done
