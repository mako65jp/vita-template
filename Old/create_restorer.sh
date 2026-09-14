#!/bin/bash

OUTPUT_SCRIPT="restore_project.sh"
INCLUDE_BINARY=false
TARGET_DIR=""

# --- オプション解析 ---
usage() {
    echo "使い方: $0 [-b|--include-binary] [対象ディレクトリ]"
    echo "  -b, --include-binary : バイナリファイルも復元対象に含める（デフォルトはテキストのみ）"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--include-binary)
            INCLUDE_BINARY=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [ -z "$TARGET_DIR" ]; then
                TARGET_DIR="$1"
            else
                echo "エラー: 不明な引数 '$1'"
                usage
            fi
            shift
            ;;
    esac
done

TARGET_DIR="${TARGET_DIR:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "エラー: 指定されたディレクトリが存在しません: $TARGET_DIR"
    exit 1
fi

echo "解析中: $TARGET_DIR"
if [ "$INCLUDE_BINARY" = true ]; then
    echo "モード: バイナリファイルを含める"
else
    echo "モード: テキストファイルのみ（バイナリはスキップ）"
fi
echo "補正: テキストファイルの改行コードを LF に統一します"
echo "----------------------------------------"

# --- 復元スクリプトのヘッダーを作成 ---
cat << 'EOF' > "$OUTPUT_SCRIPT"
#!/bin/bash

echo "プロジェクトの復元を開始します..."

# バイナリ復元用の base64 デコードコマンド判定
if command -v base64 >/dev/null 2>&1; then
    if base64 --version 2>&1 | grep -q "GNU"; then
        B64_DECODE="base64 -d"
    else
        B64_DECODE="base64 -D"
    fi
fi

EOF

# fileコマンドの存在確認
HAS_FILE_CMD=false
if command -v file >/dev/null 2>&1; then
    HAS_FILE_CMD=true
fi

# ランダムなヒアドキュメント用デリミタ生成関数
generate_delimiter() {
    echo "EOF_$(date +%s)_$RANDOM"
}

# ファイル探索と書き出しループ
find "$TARGET_DIR" \
    \( -path "*/.git/*" \
    -o -path "*/node_modules/*" \
    -o -path "*/__pycache__/*" \
    -o -path "*/.venv/*" \
    -o -path "*/venv/*" \
    -o -path "*/dist/*" \
    -o -path "*/build/*" \
    -o -path "*/.idea/*" \
    -o -path "*/.vscode/*" \
    -o -name ".DS_Store" \
    -o -name "coverage" \
    -o -name "package-lock.json" \
    -o -name "create_restorer*.sh" \
    -o -name "$OUTPUT_SCRIPT" \) -prune \
    -o -type f -print | while read -r filepath; do

    # --- バイナリ判定 ---
    is_binary=false
    if [ "$HAS_FILE_CMD" = true ]; then
        mime_type=$(file --mime-encoding "$filepath" 2>/dev/null)
        if [[ "$mime_type" == *"binary"* ]]; then
            is_binary=true
        fi
    else
        if grep -q $'\x00' "$filepath" 2>/dev/null; then
            is_binary=true
        fi
    fi

    # スキップ処理
    if [ "$is_binary" = true ] && [ "$INCLUDE_BINARY" = false ]; then
        relpath="${filepath#$TARGET_DIR/}"
        echo "スキップ（バイナリ）: ${relpath#./}"
        continue
    fi

    relpath="${filepath#$TARGET_DIR/}"
    relpath="${relpath#./}"

    # ディレクトリ作成コード
    dir_name=$(dirname "$relpath")
    if [ "$dir_name" != "." ]; then
        echo "mkdir -p \"$dir_name\"" >> "$OUTPUT_SCRIPT"
    fi

    echo "echo \"作成: $relpath\"" >> "$OUTPUT_SCRIPT"

    # --- ファイル出力処理 ---
    if [ "$is_binary" = true ]; then
        DELIMITER="B64_RESTORE_EOF"
        echo "if [ -z \"\$B64_DECODE\" ]; then echo \"エラー: base64 コマンドが見つかりません。\"; exit 1; fi" >> "$OUTPUT_SCRIPT"
        echo "cat << '$DELIMITER' | \$B64_DECODE > \"$relpath\"" >> "$OUTPUT_SCRIPT"
        base64 "$filepath" >> "$OUTPUT_SCRIPT"
        echo "$DELIMITER" >> "$OUTPUT_SCRIPT"
    else
        DELIMITER=$(generate_delimiter)
        
        echo "cat << '$DELIMITER' > \"$relpath\"" >> "$OUTPUT_SCRIPT"
        
        # 💡 ここで改行コードを LF に自動整形（\r を除去）して出力
        tr -d '\r' < "$filepath" >> "$OUTPUT_SCRIPT"
        
        # ファイル末尾に改行がない場合のケア
        if [ -n "$(tail -c 1 "$filepath")" ]; then
            echo "" >> "$OUTPUT_SCRIPT"
        fi
        
        echo "$DELIMITER" >> "$OUTPUT_SCRIPT"
    fi

    echo "" >> "$OUTPUT_SCRIPT"
    echo "追加: $relpath"
done

# --- 復元スクリプトのフッター（改行コードをLFで揃える） ---
cat << 'EOF' >> "$OUTPUT_SCRIPT"
echo -e "\n復元が完了しました！"
EOF

# 💡 生成された restore_project.sh 自体の改行コードも LF に統一
if command -v sed >/dev/null 2>&1; then
    sed -i 's/\r$//' "$OUTPUT_SCRIPT" 2>/dev/null || sed -i '' 's/\r$//' "$OUTPUT_SCRIPT" 2>/dev/null
fi

chmod +x "$OUTPUT_SCRIPT"

echo "----------------------------------------"
echo "成功: 復元スクリプト '$OUTPUT_SCRIPT' を生成しました。"
