#!/usr/bin/env bash
set -e

# 出力先のディレクトリ指定
TARGET_DIR="my-monorepo2"

echo "=== 新しいフォルダ構造への移行（完全版）を開始します ==="
echo "--> 出力先: ${TARGET_DIR}"

# 1. 出力先ディレクトリの作成と、プロジェクト全体の完全コピー（成果物等は除外）
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

echo "--> プロジェクト全体をバックアップ・コピー中..."
rsync -av . "$TARGET_DIR" \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='dist' \
  --exclude='.next' \
  --exclude="$TARGET_DIR" > /dev/null

cd "$TARGET_DIR"

# 2. 指定された新しいトップレベル構造のディレクトリを確実に作成
mkdir -p apps features plugins shared
# mkdir -p apps features plugins shared/server shared/client shared/errors shared/schemas

# 3. 既存の packages/ や古い構成のファイルを新しい構造へ正しくマージ・移動
# ※もし既存の packages/ がある場合の中身を丁寧に振り分けます
if [ -d "packages" ]; then
  echo "--> 既存の packages/ 内のモジュールを新しい階層へ移動中..."
  
  [ -d "packages/features" ] && cp -rn packages/features/* features/ 2>/dev/null || true
  [ -d "packages/plugins" ] && cp -rn packages/plugins/* plugins/ 2>/dev/null || true
  [ -d "packages/core" ] && cp -rn packages/core/* shared/ 2>/dev/null || true

  [ -d "packages/shared/server" ] && cp -rn packages/shared/server/* shared/server/ 2>/dev/null || true
  [ -d "packages/shared/client" ] && cp -rn packages/shared/client/* shared/client/ 2>/dev/null || true
  [ -d "packages/shared/errors" ] && cp -rn packages/shared/errors/* shared/errors/ 2>/dev/null || true
  [ -d "packages/shared/schemas" ] && cp -rn packages/shared/schemas/* shared/schemas/ 2>/dev/null || true

  rm -rf packages
fi

# 4. 全ソースコードおよび設定ファイル内の import パス・エイリアスの書き換え
echo "--> コード内のパス参照（import / alias）を新構造へ更新中..."
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.json" \) | while read -r file; do
  # 旧エイリアス・旧パスの置換
  sed -i.bak 's|@packages/features/|@features/|g' "$file"
  sed -i.bak 's|@packages/plugins/|@plugins/|g' "$file"
  sed -i.bak 's|@packages/shared/|@shared/|g' "$file"
  sed -i.bak 's|@packages/|@shared/|g' "$file"
  
  sed -i.bak 's|packages/features/|features/|g' "$file"
  sed -i.bak 's|packages/plugins/|plugins/|g' "$file"
  sed -i.bak 's|packages/shared/|shared/|g' "$file"
  sed -i.bak 's|packages/|shared/|g' "$file"
  
  rm -f "$file.bak"
done

echo "=== すべてのファイルの再配置とパス更新が完了しました ==="
echo "構築場所: ./${TARGET_DIR}"
