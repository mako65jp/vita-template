#!/bin/bash

OUTPUT_SCRIPT="restore_project.bat"

cat << 'EOF_BAT' > "$OUTPUT_SCRIPT"
@echo off
chcp 65001 >nul
echo プロジェクトの復元を開始します...
echo.
EOF_BAT

find . -type f \
    ! -path "*/.git/*" \
    ! -path "*/node_modules/*" \
    ! -path "*/__pycache__/*" \
    ! -path "*/.venv/*" \
    ! -path "*/venv/*" \
    ! -path "*/dist/*" \
    ! -path "*/build/*" \
    ! -path "*/.idea/*" \
    ! -path "*/.vscode/*" \
    ! -name ".DS_Store" \
    ! -name "package-lock.json" \
    ! -name "make_bat.sh" \
    ! -name "create_restorer_bat.sh" \
    ! -name "$OUTPUT_SCRIPT" | while read -r filepath; do

    cleanpath="${filepath#./}"
    win_relpath=$(echo "$cleanpath" | tr '/' '\\')
    win_dirname=$(dirname "$cleanpath")

    if [ "$win_dirname" != "." ]; then
        win_dirpath=$(echo "$win_dirname" | tr '/' '\\')
        echo "if not exist \"$win_dirpath\" mkdir \"$win_dirpath\"" >> "$OUTPUT_SCRIPT"
    fi

    echo "echo 作成: $win_relpath" >> "$OUTPUT_SCRIPT"

    b64_data=$(base64 "$cleanpath" | tr -d '\r\n')
    echo "powershell -Command \"[System.IO.File]::WriteAllBytes('$win_relpath', [System.Convert]::FromBase64String('$b64_data'))\"" >> "$OUTPUT_SCRIPT"
    echo "" >> "$OUTPUT_SCRIPT"
done

cat << 'EOF_BAT' >> "$OUTPUT_SCRIPT"
echo.
echo 復元が完了しました！
pause
EOF_BAT

if command -v unix2dos >/dev/null 2>&1; then
    unix2dos "$OUTPUT_SCRIPT" >/dev/null 2>&1
elif command -v sed >/dev/null 2>&1; then
    sed -i 's/$/\r/' "$OUTPUT_SCRIPT" 2>/dev/null || sed -i '' 's/$/\r/' "$OUTPUT_SCRIPT" 2>/dev/null
fi
