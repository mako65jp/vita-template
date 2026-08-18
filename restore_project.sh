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

echo "作成: package.json"
cat << 'EOF_1787016562_32652' > "package.json"
{
  "name": "devcontainer-monorepo",
  "private": true,
  "type": "module",
  "workspaces": [
    "apps/*",
    "packages/*",
    "packages/plugins/*",
    "packages/features/*",
    "packages/ui/*"
  ],
  "scripts": {
    "start": "concurrently \"npm run dev:api\" \"npm run dev:web\"",
    "dev": "npm start",
    "dev:api": "npm --workspace=apps/api run dev",
    "dev:web": "npm --workspace=apps/web run dev",
    "build": "npm run build --workspaces --if-present",
    "test": "vitest run --watch --no-cache",
    "db:push": "npm run db:push --workspaces --if-present",
    "db:push:test": "npm run db:push:test --workspaces --if-present",
    "db:push:all": "npm run db:push:all --workspaces --if-present",
    "db:seed": "tsx packages/core/src/db/seed.ts",
    "coverage": "vitest run --coverage"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^6.0.5",
    "@vitest/coverage-v8": "^4.1.10",
    "concurrently": "^8.2.2",
    "drizzle-kit": "^0.31.10",
    "typescript": "^5.3.3",
    "vite": "^8.2.0",
    "vitest": "^4.1.10"
  },
  "dependencies": {
    "@hono/node-server": "^2.0.5",
    "drizzle-orm": "^0.45.2"
  }
}
EOF_1787016562_32652

echo "作成: cat_files.sh"
cat << 'EOF_1787016562_2897' > "cat_files.sh"
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
EOF_1787016562_2897

echo "作成: .gitignore"
cat << 'EOF_1787016562_13315' > ".gitignore"
### Node
# Dependencies
node_modules/

# Logs
*.log

# Runtime data
*.pid
*.pid.lock

# Coverage
coverage/
*.lcov
.nyc_output

# Build output
dist/
build/Release

# TypeScript cache
*.tsbuildinfo

# Framework build output and caches
.cache
.parcel-cache
.next
out/
.nuxt

# dotenv environment variable files
.env
.env.local
.env.*.local

# npm cache directory
.npm
*.tgz

# yarn v2
.yarn/cache
.yarn/unplugged
.yarn/install-state.gz
.pnp.*

### macOS
# Finder metadata
.DS_Store

# Thumbnails
._*

# Custom folder icons
Icon

# Volume root files
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

### Windows
# Windows thumbnail cache files
Thumbs.db

# Folder config file
[Dd]esktop.ini

# Recycle Bin used on file shares
$RECYCLE.BIN/

# Windows shortcuts
*.lnk

### Linux
# Backup files
*~

# Temporary files from deleted open files
.fuse_hidden*

# KDE directory preferences
.directory

# Linux trash folder
.Trash-*

# NFS temporary files
.nfs*

### VS Code
# VSCode settings (keep shared configuration)
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# Local History for Visual Studio Code
.history/

# Built Visual Studio Code Extensions
*.vsix
EOF_1787016562_13315

echo "作成: plan.md"
cat << 'EOF_1787016562_30821' > "plan.md"
# 📋 拡張候補一覧表（最新版）

### 凡例

* ✅ **完了:** 機能要件およびテストがすべて実装・通過済み（ビルド確認完了）
* ⏳ **未実装:** まだ手をつけていない状態
* ⏸️ **保留:** 応用拡張機能のため、基本画面・業務機能サンプル完成後に着手

---

| 機能領域 | 機能名 | 機能概要 | 主な担当レイヤー / パッケージ | 状況 | 導入メリット・意図 |
| --- | --- | --- | --- | --- | --- |
| **1. ユーザー管理（管理者用基盤）** | **ロール・権限の変更** | ユーザーごとのロール（`user` / `admin` 等）の割り当て・変更 | `apps/api` / `apps/web` | ✅ **完了** | アクセス制御（RBAC）の実運用を可能にする |
|  | **アカウント無効化・削除** | システム利用停止（ステータス変更）や物理/論理削除 | `apps/api` / `packages/core` | ✅ **完了** | 退職・不要アカウントのセキュリティ保護 |
| **2. アクセス制御・認可基盤** | **画面・コンポーネントガード** | ユーザーのロールに応じたメニュー表示切替や操作ボタンの非表示制御 | `packages/ui` / `apps/web` | ✅ **完了** | フロントエンドでの不正操作防止と表示制御の共通化 |
|  | **権限エラー画面 (403 Forbidden)** | 権限のないページに直接アクセスした際の専用エラー画面 | `apps/web` | ✅ **完了** | ユーザーへの適切なエラー通知と遷移誘導 |
| **3. 汎用 UI コンポーネント群** | **データテーブルコンポーネント** | 検索・ソート・ページネーション機能を備えた一覧テーブル | `packages/ui` | ⏳ **未実装** | データ一覧画面の開発スピード向上 |
|  | **モーダル・ダイアログ** | 確認メッセージ（削除確認等）や入力フォーム用オーバーレイ | `packages/ui` | ⏳ **未実装** | 操作時の対話 UI の統一化 |
|  | **フォーム制御・バリデーション基盤** | React Hook Form と Zod を連携した入力エラー表示の統一仕組み | `packages/ui` / `apps/web` | ⏳ **未実装** | フォーム開発の効率化とバリデーション表現の平準化 |
| **4. 運用・セキュリティ・エラー処理** | **監査ログ (Audit Log)** | 誰が・いつ・何をしたか（ログイン、データ更新、削除等）の操作記録 | `apps/api` / `packages/core` | ⏳ **未実装** | 障害追跡・セキュリティ監査の実現 |
|  | **自動ログアウト処理** | トークン期限切れ（401）検知時の自動ログアウトおよびリダイレクト | `apps/web` | ⏳ **未実装** | セッション切断時の不具合防止と体験向上 |
|  | **標準エラー画面 (404 / 500)** | 不存在 URL アクセスやシステム例外発生時のフォールバック画面 | `apps/web` | ⏳ **未実装** | 未定義エラーによる画面不調の防止 |
| **5. 通知・アナウンス基盤** | **システム内通知** | ヘッダーのベルアイコン等での個別通知および既読管理 | `apps/api` / `apps/web` | ⏳ **未実装** | ユーザーへの処理結果や状態変更の即時伝達 |
|  | **お知らせ・アナウンス管理** | 管理者から全ユーザー/特定ロール宛へのメンテ情報等の配信 | `apps/api` / `apps/web` | ⏳ **未実装** | 運営からユーザーへの情報共有 |
| **6. ファイル・メディア管理** | **汎用ファイルアップロード UI** | ドラッグ＆ドロップ対応の画像・ドキュメントアップロード部品 | `packages/ui` | ⏳ **未実装** | ファイル取り扱い画面の共通化 |
|  | **S3 / クラウドストレージ API** | バックエンドからのストレージ保存および署名付き URL 発行 | `packages/core` / `apps/api` | ⏳ **未実装** | 安全なファイル保存・参照基盤の確立 |
| **7. 非同期処理・タスク基盤** | **バックグラウンドジョブ実行** | CSV 一括処理等の重い処理の非同期実行と進捗表示 | `apps/api` / `packages/core` | ⏳ **未実装** | レスポンス遅延の防止と非同期処理可視化 |
|  | **定期タスク (Cron Job)** | バックアップや定期処理の自動実行 | `apps/api` | ⏳ **未実装** | 運用自動化基盤の確立 |
| **8. 組織・マルチテナント** | **組織 (テナント)・チーム管理** | 企業・部署単位でのデータアクセス範囲の完全分離 | `packages/core` / `apps/api` | ⏳ **未実装** | B2B / SaaS 型アプリへの対応力強化 |
| **9. 多言語対応 (i18n)** | **多言語切り替え** | 日本語 / 英語等の表示切り替えおよび言語リソース管理 | `apps/web` / `packages/ui` | ⏳ **未実装** | グローバル利用への拡張性確保 |

---
EOF_1787016562_30821

mkdir -p "dev"
echo "作成: dev/seed-dev-user.ts"
cat << 'EOF_1787016562_12326' > "dev/seed-dev-user.ts"
import { db, users } from '@app/core/server';
import { hashPassword } from '@app/plugins-auth-local';

async function main() {
    const email = 'mako65jp@gmail.com';
    const password = '1234'; // お好みのパスワード

    // もし core 内にハッシュ関数があれば使い、無ければ使っているライブラリでハッシュ化
    const hashedPassword = await hashPassword(password);

    await db.insert(users)
        .values({
            email,
            passwordHash: hashedPassword,
            name: '開発ユーザー',
        })
        .onConflictDoNothing();

    console.log(`✅ User created: ${email}`);
    process.exit(0);
}

main().catch((err) => {
    console.error('❌ Failed:', err);
    process.exit(1);
});
EOF_1787016562_12326

mkdir -p ".devcontainer/scripts"
echo "作成: .devcontainer/scripts/init-test-db.sh"
cat << 'EOF_1787016562_11002' > ".devcontainer/scripts/init-test-db.sh"
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE $POSTGRES_DB_TEST;
EOSQL
EOF_1787016562_11002

mkdir -p ".devcontainer"
echo "作成: .devcontainer/Dockerfile"
cat << 'EOF_1787016562_12350' > ".devcontainer/Dockerfile"
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone
    
EOF_1787016562_12350

mkdir -p ".devcontainer"
echo "作成: .devcontainer/devcontainer.json"
cat << 'EOF_1787016562_23096' > ".devcontainer/devcontainer.json"
{
  "name": "Monorepo DevContainer with DB",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace",
  "customizations": {
    "vscode": {
      "settings": {
        "js/ts.tsdk.path": "node_modules/typescript/lib",
        "editor.formatOnSave": true,
        "vitest.enable": true
      },
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "vitest.explorer"
      ]
    }
  },
  "forwardPorts": [
    3000,
    3001,
    5432
  ],
  "updateContentCommand": "sudo chown -R node:node /workspace && npm install"
}
EOF_1787016562_23096

mkdir -p ".devcontainer"
echo "作成: .devcontainer/docker-compose.yml"
cat << 'EOF_1787016562_21592' > ".devcontainer/docker-compose.yml"

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ..:/workspace:cached
      - /workspace/node_modules
      - /workspace/apps/api/node_modules
      - /workspace/apps/web/node_modules
      - /workspace/packages/core/node_modules
      - /workspace/packages/plugins/auth-local/node_modules
      - /workspace/packages/plugins/auth-ad/node_modules
      - /workspace/packages/features/sample/node_modules
    command: /bin/sh -c "while sleep 1000; do :; done"
    ports:
      - "${VITE_PORT:-3000}:3000"
      - "${PORT:-3001}:3001"
    env_file:
      - ../.env
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: app_db
      POSTGRES_DB_TEST: app_db_test
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./scripts/init-test-db.sh:/docker-entrypoint-initdb.d/init-multiple-databases.sh
      # 起動時に app_db_test も自動作成するスクリプトをマウント

volumes:
  postgres-data:
EOF_1787016562_21592

echo "作成: tsconfig.json"
cat << 'EOF_1787016562_14353' > "tsconfig.json"
{
    "compilerOptions": {
        "target": "ES2022",
        "module": "ESNext",
        "moduleResolution": "bundler",
        "allowImportingTsExtensions": true,
        "noEmit": true,
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true,
        "resolveJsonModule": true,
        "isolatedModules": true,
        "baseUrl": ".",
        "paths": {
            "@app/core": [
                "packages/core/src/index.ts"
            ],
            "@app/core/*": [
                "packages/core/src/*"
            ],
            "@app/plugins/*": [
                "packages/plugins/*"
            ],
            "@app/features/*": [
                "packages/features/*"
            ],
            "@app/ui": [
                "packages/ui/src/index.ts"
            ],
            "@app/ui/*": [
                "packages/ui/src/*"
            ]
        }
    },
    "exclude": [
        "node_modules",
        "dist"
    ]
}
EOF_1787016562_14353

echo "作成: vitest.config.ts"
cat << 'EOF_1787016562_19810' > "vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        reporters: ['tree'],

        // パッケージのディレクトリパスを指定（設定ファイルのパスではなくディレクトリを指定するのが正しい仕様）
        projects: [
            'apps/api',
            'apps/web',
            'packages/core',
            'packages/ui',
            'packages/features/*',
        ],
        exclude: ['node_modules', 'dist', '.next', 'coverage'],
        coverage: {
            provider: 'v8',
            include: ['**/*.{ts,tsx}'],
            exclude: ['dev/**/*', 'test/**/*'],
        },
    },
});
EOF_1787016562_19810

mkdir -p "packages/ui"
echo "作成: packages/ui/package.json"
cat << 'EOF_1787016562_4420' > "packages/ui/package.json"
{
  "name": "@app/ui",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts",
    "./components/*": "./src/components/*.tsx",
    "./lib/*": "./src/lib/*.ts"
  },
  "scripts": {
    "typecheck": "tsc --noEmit"
  },
  "peerDependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "dependencies": {
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "lucide-react": "^1.16.0",
    "sonner": "^2.0.7",
    "tailwind-merge": "^3.0.2"
  },
  "devDependencies": {
    "@testing-library/user-event": "^14.6.3",
    "@types/react": "^18.2.55",
    "@types/react-dom": "^18.2.19",
    "typescript": "^5.3.3"
  }
}
EOF_1787016562_4420

mkdir -p "packages/ui"
echo "作成: packages/ui/tsconfig.json"
cat << 'EOF_1787016562_9748' > "packages/ui/tsconfig.json"
{
    "extends": "../../tsconfig.json",
    "compilerOptions": {
        "jsx": "react-jsx",
        "lib": [
            "ES2022",
            "DOM",
            "DOM.Iterable"
        ],
        "types": [
            "vite/client",
            "@testing-library/jest-dom"
        ]
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1787016562_9748

mkdir -p "packages/ui"
echo "作成: packages/ui/vitest.config.ts"
cat << 'EOF_1787016562_16306' > "packages/ui/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
        alias: {
            '@app/core': path.resolve(import.meta.dirname, '../../packages/core/src'),
        },
    },
    test: {
        globals: true,
        environment: 'jsdom',
        setupFiles: ['./src/test/setup.ts'],
    },
});
EOF_1787016562_16306

mkdir -p "packages/ui/src"
echo "作成: packages/ui/src/index.ts"
cat << 'EOF_1787016562_30257' > "packages/ui/src/index.ts"
export * from './lib/utils';
export * from './components/button';
export * from './components/layout';
export * from './components/toaster';

export { clientEnvSchema, clientEnv } from '@app/core/config/env'
export type { ClientEnv } from '@app/core/config/env'
EOF_1787016562_30257

mkdir -p "packages/ui/src/test"
echo "作成: packages/ui/src/test/setup.ts"
cat << 'EOF_1787016562_26068' > "packages/ui/src/test/setup.ts"
import '@testing-library/jest-dom';
EOF_1787016562_26068

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/button.tsx"
cat << 'EOF_1787016562_14598' > "packages/ui/src/components/button.tsx"
import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '../lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 px-4 py-2',
  {
    variants: {
      variant: {
        default: 'bg-blue-600 text-white hover:bg-blue-700',
        outline: 'border border-gray-300 bg-transparent hover:bg-gray-100 text-gray-900',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3 text-xs',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
  VariantProps<typeof buttonVariants> { }

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);
Button.displayName = 'Button';
EOF_1787016562_14598

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/toaster.tsx"
cat << 'EOF_1787016562_19809' > "packages/ui/src/components/toaster.tsx"
import { Toaster as SonnerToaster, toast } from 'sonner';

export function Toaster() {
    return (
        <SonnerToaster
            position="top-right"
            toastOptions={{
                classNames: {
                    toast: 'group toast group-[.toaster]:bg-white group-[.toaster]:text-gray-900 group-[.toaster]:border-gray-200 group-[.toaster]:shadow-lg',
                    description: 'group-[.toast]:text-gray-500',
                    actionButton: 'group-[.toast]:bg-blue-600 group-[.toast]:text-white',
                    cancelButton: 'group-[.toast]:bg-gray-100 group-[.toast]:text-gray-500',
                },
            }}
        />
    );
}

// RFC 9457 エラーレスポンス用インターフェース
export interface ProblemDetails {
    type?: string;
    title?: string;
    status?: number;
    detail?: string;
    instance?: string;
    [key: string]: unknown;
}

// エラー通知用ヘルパー関数
export function showErrorToast(error: unknown) {
    if (typeof error === 'object' && error !== null && 'detail' in error) {
        const pd = error as ProblemDetails;
        toast.error(pd.title || 'エラーが発生しました', {
            description: pd.detail || '予期せぬエラーが発生しました。',
        });
    } else if (error instanceof Error) {
        toast.error('エラーが発生しました', {
            description: error.message,
        });
    } else {
        toast.error('エラーが発生しました', {
            description: '通信エラーまたは予期せぬエラーです。',
        });
    }
}

export { toast };
EOF_1787016562_19809

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/button.test.tsx"
cat << 'EOF_1787016562_30918' > "packages/ui/src/components/button.test.tsx"
import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import userEvent from '@testing-library/user-event';
import { Button } from './button';

describe('Button Component', () => {
    it('子要素（テキスト）が正しくレンダリングされること', () => {
        render(<Button>テストボタン</Button>);
        expect(screen.getByRole('button', { name: 'テストボタン' })).toBeInTheDocument();
    });

    it('クリックイベントが発火すること', async () => {
        const handleClick = vi.fn();
        render(<Button onClick={handleClick}>クリック</Button>);

        await userEvent.click(screen.getByRole('button', { name: 'クリック' }));
        expect(handleClick).toHaveBeenCalledTimes(1);
    });

    it('disabled 属性が設定されている場合、クリックイベントが発火しないこと', async () => {
        const handleClick = vi.fn();
        render(<Button disabled onClick={handleClick}>無効ボタン</Button>);

        const button = screen.getByRole('button', { name: '無効ボタン' });
        expect(button).toBeDisabled();

        await userEvent.click(button);
        expect(handleClick).not.toHaveBeenCalled();
    });
});
EOF_1787016562_30918

mkdir -p "packages/ui/src/components/layout"
echo "作成: packages/ui/src/components/layout/index.ts"
cat << 'EOF_1787016562_32479' > "packages/ui/src/components/layout/index.ts"
export * from './AppLayout';
export * from './SidebarNav';
EOF_1787016562_32479

mkdir -p "packages/ui/src/components/layout"
echo "作成: packages/ui/src/components/layout/AppLayout.tsx"
cat << 'EOF_1787016562_11282' > "packages/ui/src/components/layout/AppLayout.tsx"
import * as React from 'react';
import { cn } from '../../lib/utils';

interface LayoutProps {
    children: React.ReactNode;
    sidebar?: React.ReactNode;
    header?: React.ReactNode;
    className?: string;
}

export function AppLayout({ children, sidebar, header, className }: LayoutProps) {
    const [isMobileOpen, setIsMobileOpen] = React.useState(false);

    return (
        <div className="flex min-h-screen flex-col bg-gray-50 text-gray-900">
            {/* Header */}
            {header && (
                <header className="sticky top-0 z-40 border-b border-gray-200 bg-white/80 backdrop-blur">
                    <div className="flex items-center justify-between px-4">
                        {sidebar && (
                            <button
                                type="button"
                                onClick={() => setIsMobileOpen(!isMobileOpen)}
                                className="mr-2 rounded-md p-2 text-gray-600 hover:bg-gray-100 md:hidden"
                                aria-label="Toggle Menu"
                            >
                                <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                                </svg>
                            </button>
                        )}
                        <div className="flex-1">{header}</div>
                    </div>
                </header>
            )}

            <div className="flex flex-1 relative">
                {/* Desktop Sidebar */}
                {sidebar && (
                    <aside className="w-64 shrink-0 border-r border-gray-200 bg-white p-4 hidden md:block">
                        {sidebar}
                    </aside>
                )}

                {/* Mobile Drawer (Overlay Sidebar) */}
                {sidebar && isMobileOpen && (
                    <>
                        <div
                            className="fixed inset-0 z-50 bg-black/50 md:hidden"
                            onClick={() => setIsMobileOpen(false)}
                        />
                        <aside className="fixed inset-y-0 left-0 z-50 w-64 border-r border-gray-200 bg-white p-4 shadow-xl md:hidden">
                            <div className="flex justify-end mb-2">
                                <button
                                    type="button"
                                    onClick={() => setIsMobileOpen(false)}
                                    className="rounded-md p-1 text-gray-500 hover:bg-gray-100"
                                    aria-label="Close Menu"
                                >
                                    <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                    </svg>
                                </button>
                            </div>
                            <div onClick={() => setIsMobileOpen(false)}>
                                {sidebar}
                            </div>
                        </aside>
                    </>
                )}

                {/* Main Content */}
                <main className={cn('flex-1 p-6 max-w-7xl mx-auto w-full', className)}>
                    {children}
                </main>
            </div>
        </div>
    );
}

export interface HeaderContentProps {
    title: string;
    children?: React.ReactNode;
}

export function HeaderContent({ title, children }: HeaderContentProps) {
    return (
        <div className="flex h-16 items-center justify-between px-2 md:px-6">
            <h1 className="text-lg md:text-xl font-bold tracking-tight text-gray-900">{title}</h1>
            <div className="flex items-center gap-4">
                {children ?? <span className="text-sm text-gray-500">Dev App</span>}
            </div>
        </div>
    );
}
EOF_1787016562_11282

mkdir -p "packages/ui/src/components/layout"
echo "作成: packages/ui/src/components/layout/SidebarNav.tsx"
cat << 'EOF_1787016562_27501' > "packages/ui/src/components/layout/SidebarNav.tsx"
import * as React from 'react';
import { cn } from '../../lib/utils';

export interface SidebarNavItem {
    label: string;
    href: string;
    active?: boolean;
    onClick?: (e: React.MouseEvent<HTMLAnchorElement>) => void;
}

export function SidebarNav({ items }: { items: SidebarNavItem[] }) {
    return (
        <nav className="flex flex-col gap-1">
            {items.map((item, index) => (
                <a
                    key={`${item.label}-${item.href}-${index}`}
                    href={item.href}
                    onClick={item.onClick}
                    className={cn(
                        'flex items-center rounded-md px-3 py-2 text-sm font-medium transition-colors',
                        item.active
                            ? 'bg-blue-50 text-blue-700 font-semibold'
                            : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                    )}
                >
                    {item.label}
                </a>
            ))}
        </nav>
    );
}
EOF_1787016562_27501

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/layout.test.tsx"
cat << 'EOF_1787016562_16690' > "packages/ui/src/components/layout.test.tsx"
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { AppLayout, HeaderContent, SidebarNav } from './layout';

describe('AppLayout Component', () => {
    it('メインコンテンツ（children）が正しく描画されること', () => {
        render(
            <AppLayout>
                <div data-testid="test-content">メインコンテンツ</div>
            </AppLayout>
        );

        expect(screen.getByTestId('test-content')).toBeInTheDocument();
    });

    it('Header と Sidebar が指定された場合、正しく描画されること', () => {
        render(
            <AppLayout
                header={<HeaderContent title="テストヘッダー" />}
                sidebar={<SidebarNav items={[{ label: 'メニュー1', href: '#' }]} />}
            >
                <div>コンテンツ</div>
            </AppLayout>
        );

        expect(screen.getByRole('heading', { name: 'テストヘッダー' })).toBeInTheDocument();
        expect(screen.getAllByRole('link', { name: 'メニュー1' })[0]).toBeInTheDocument();
    });

    it('モバイル表示時にメニューボタンのトグルでドロワーが開閉すること', () => {
        render(
            <AppLayout
                header={<HeaderContent title="テストヘッダー" />}
                sidebar={<SidebarNav items={[{ label: 'メニュー1', href: '#' }]} />}
            >
                <div>コンテンツ</div>
            </AppLayout>
        );

        const toggleButton = screen.getByRole('button', { name: 'Toggle Menu' });
        expect(toggleButton).toBeInTheDocument();

        // トグルボタン押下でドロワー内の要素が開く
        fireEvent.click(toggleButton);
        expect(screen.getByRole('button', { name: 'Close Menu' })).toBeInTheDocument();
    });

    it('HeaderContent に children が指定された場合、正しく描画されること', () => {
        render(
            <HeaderContent title="テストヘッダー">
                <button>カスタムボタン</button>
            </HeaderContent>
        );

        expect(screen.getByRole('button', { name: 'カスタムボタン' })).toBeInTheDocument();
    });

    it('SidebarNav で active フラグが立っている要素にアクティブスタイルが適用されること', () => {
        const navItems = [
            { label: 'アクティブ項目', href: '#1', active: true },
            { label: '通常項目', href: '#2', active: false },
        ];

        render(<SidebarNav items={navItems} />);

        const activeLink = screen.getByRole('link', { name: 'アクティブ項目' });
        const normalLink = screen.getByRole('link', { name: '通常項目' });

        expect(activeLink).toHaveClass('bg-blue-50');
        expect(normalLink).not.toHaveClass('bg-blue-50');
    });
});
EOF_1787016562_16690

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/toaster.test.tsx"
cat << 'EOF_1787016562_235' > "packages/ui/src/components/toaster.test.tsx"
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { toast, showErrorToast } from './toaster';

// sonner の toast 関数をモック化
vi.mock('sonner', async () => {
  const actual = await vi.importActual('sonner');
  return {
    ...actual,
    toast: {
      error: vi.fn(),
      success: vi.fn(),
    },
  };
});

describe('showErrorToast Utility', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('RFC 9457 形式 (ProblemDetails) のエラーオブジェクトを受け取った場合、title と detail を表示すること', () => {
    const problemDetails = {
      type: 'https://example.com/errors/invalid',
      title: 'バリデーションエラー',
      status: 400,
      detail: '入力値が不適切です。',
    };

    showErrorToast(problemDetails);

    expect(toast.error).toHaveBeenCalledWith('バリデーションエラー', {
      description: '入力値が不適切です。',
    });
  });

  it('Standard Error オブジェクトを受け取った場合、message を表示すること', () => {
    const error = new Error('ネットワーク接続に失敗しました');

    showErrorToast(error);

    expect(toast.error).toHaveBeenCalledWith('エラーが発生しました', {
      description: 'ネットワーク接続に失敗しました',
    });
  });

  it('不明なエラータイプ（文字列や null 等）を受け取った場合、デフォルトのエラーメッセージを表示すること', () => {
    showErrorToast('Unknown Error String');

    expect(toast.error).toHaveBeenCalledWith('エラーが発生しました', {
      description: '通信エラーまたは予期せぬエラーです。',
    });
  });
});
EOF_1787016562_235

mkdir -p "packages/ui/src/lib"
echo "作成: packages/ui/src/lib/utils.ts"
cat << 'EOF_1787016562_3600' > "packages/ui/src/lib/utils.ts"
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
EOF_1787016562_3600

mkdir -p "packages/plugins/auth-ad"
echo "作成: packages/plugins/auth-ad/package.json"
cat << 'EOF_1787016562_1745' > "packages/plugins/auth-ad/package.json"
{
  "name": "@app/plugins-auth-ad",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1787016562_1745

mkdir -p "packages/plugins/auth-ad/src"
echo "作成: packages/plugins/auth-ad/src/index.ts"
cat << 'EOF_1787016562_7285' > "packages/plugins/auth-ad/src/index.ts"
import { AuthPlugin } from '@app/core/auth/auth-registry';

export class ActiveDirectoryAuthPlugin implements AuthPlugin {
  name = 'ad';

  async authenticate(credentials: any) {
    const { username, password } = credentials;
    if (username === 'ad_user' && password === 'domain_pass') {
      return { id: '100', name: 'AD Domain User' };
    }
    throw new Error('Active Directory authentication failed');
  }
}
EOF_1787016562_7285

mkdir -p "packages/plugins/auth-local"
echo "作成: packages/plugins/auth-local/package.json"
cat << 'EOF_1787016562_12288' > "packages/plugins/auth-local/package.json"
{
  "name": "@app/plugins-auth-local",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "dependencies": {
    "bcryptjs": "^3.0.3",
    "jose": "^6.2.8"
  },
  "devDependencies": {
    "@types/bcryptjs": "^2.4.6"
  }
}
EOF_1787016562_12288

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/index.ts"
cat << 'EOF_1787016562_7060' > "packages/plugins/auth-local/src/index.ts"
import { AuthPlugin } from '@app/core/auth/auth-registry';

export class LocalAuthPlugin implements AuthPlugin {
  name = 'local';

  async authenticate(credentials: any) {
    const { username, password } = credentials;
    if (username === 'admin' && password === 'password') {
      return { id: '1', name: 'Local Admin' };
    }
    throw new Error('Invalid local credentials');
  }
}

export * from './auth-utils';
EOF_1787016562_7060

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/auth-utils.ts"
cat << 'EOF_1787016562_16429' > "packages/plugins/auth-local/src/auth-utils.ts"
import bcrypt from 'bcryptjs';
import { SignJWT, jwtVerify } from 'jose';

// ----------------------------------------------------
// 1. パスワードハッシュ化 & 照合処理
// ----------------------------------------------------

/**
 * 平文パスワードをハッシュ化します
 */
export async function hashPassword(password: string): Promise<string> {
    const saltRounds = 10;
    return await bcrypt.hash(password, saltRounds);
}

/**
 * 平文パスワードとハッシュ値を照合します
 */
export async function verifyPassword(password: string, hash: string): Promise<boolean> {
    return await bcrypt.compare(password, hash);
}

// ----------------------------------------------------
// 2. JWT 発行 & 検証処理
// ----------------------------------------------------

/**
 * Payload を受け取り、署名済み JWT を生成します
 */
export async function signJwt(
    payload: Record<string, unknown>,
    secret: string,
    expiresIn: string = '2h'
): Promise<string> {
    const secretKey = new TextEncoder().encode(secret);

    return await new SignJWT(payload)
        .setProtectedHeader({ alg: 'HS256' })
        .setIssuedAt()
        .setExpirationTime(expiresIn)
        .sign(secretKey);
}

/**
 * JWT を検証し、デコードされた Payload を返します。
 * 不正または改ざんされたトークンの場合は null を返します。
 */
export async function verifyJwt<T = Record<string, unknown>>(
    token: string,
    secret: string
): Promise<T | null> {
    try {
        const secretKey = new TextEncoder().encode(secret);
        const { payload } = await jwtVerify(token, secretKey);
        return payload as T;
    } catch {
        // トークンが不正、改ざんされている、または有効期限切れの場合
        return null;
    }
}
EOF_1787016562_16429

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/auth-utils.test.ts"
cat << 'EOF_1787016562_27398' > "packages/plugins/auth-local/src/auth-utils.test.ts"
import { describe, it, expect } from 'vitest';
import { hashPassword, verifyPassword, signJwt, verifyJwt } from './auth-utils';

describe('Auth Utilities (Step 4.1)', () => {
    // ----------------------------------------------------
    // 1. パスワードハッシュ化・照合テスト
    // ----------------------------------------------------
    describe('Password Hashing', () => {
        it('平文パスワードを正しくハッシュ化し、検証できること', async () => {
            const rawPassword = 'mySecurePassword123';
            const hashedPassword = await hashPassword(rawPassword);

            // 平文とハッシュ値が異なっていること
            expect(hashedPassword).not.toBe(rawPassword);

            // 正しいパスワードの照合
            const isValid = await verifyPassword(rawPassword, hashedPassword);
            expect(isValid).toBe(true);
        });

        it('誤ったパスワードの場合は検証に失敗すること', async () => {
            const rawPassword = 'mySecurePassword123';
            const wrongPassword = 'WrongPassword456';
            const hashedPassword = await hashPassword(rawPassword);

            const isValid = await verifyPassword(wrongPassword, hashedPassword);
            expect(isValid).toBe(false);
        });
    });

    // ----------------------------------------------------
    // 2. JWT 発行・検証テスト
    // ----------------------------------------------------
    describe('JWT Operations', () => {
        const mockPayload = { userId: 'user-123', role: 'admin' };
        const secret = 'test-secret-key-at-least-32-chars-long';

        it('Payload から JWT を発行し、正しくデコード・検証できること', async () => {
            const token = await signJwt(mockPayload, secret);
            expect(typeof token).toBe('string');
            expect(token.length).toBeGreaterThan(0);

            const decoded = await verifyJwt(token, secret);
            expect(decoded).toMatchObject(mockPayload);
        });

        it('不正なシークレットキーや改ざんされたトークンは検証失敗（null または例外）になること', async () => {
            const token = await signJwt(mockPayload, secret);
            const wrongSecret = 'wrong-secret-key-32-chars-xxxxxx';

            // 異なるシークレットキーでの検証失敗
            const decodedWithWrongSecret = await verifyJwt(token, wrongSecret);
            expect(decodedWithWrongSecret).toBeNull();

            // 改ざんされたトークンでの検証失敗
            const tamperedToken = token + 'invalid';
            const decodedTampered = await verifyJwt(tamperedToken, secret);
            expect(decodedTampered).toBeNull();
        });
    });
});
EOF_1787016562_27398

mkdir -p "packages/core"
echo "作成: packages/core/package.json"
cat << 'EOF_1787016562_7121' > "packages/core/package.json"
{
  "name": "@app/core",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts",
    "./server": "./src/server.ts",
    "./db": "./src/db/index.ts",
    "./registry/hono-auto-loader": "./src/registry/hono-auto-loader.ts",
    "./config/env": "./src/config/env.ts"
  },
  "scripts": {
    "db:push": "drizzle-kit push",
    "db:push:test": "drizzle-kit push --config=drizzle-test.config.ts",
    "db:push:all": "npm run db:push && npm run db:push:test"
  },
  "dependencies": {
    "drizzle-orm": "^0.45.2",
    "glob": "^13.0.6",
    "hono": "^4.0.0",
    "postgres": "^3.4.9",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/node": "^26.1.2",
    "drizzle-kit": "^0.31.10"
  }
}
EOF_1787016562_7121

mkdir -p "packages/core"
echo "作成: packages/core/drizzle-test.config.ts"
cat << 'EOF_1787016562_31519' > "packages/core/drizzle-test.config.ts"
import { defineConfig } from 'drizzle-kit';
import { env } from './src/config/env';

export default defineConfig({
    schema: './src/db/schema/index.ts',
    out: './drizzle',
    dialect: 'postgresql',
    dbCredentials: {
        url: env.TEST_DATABASE_URL,
    },
});
EOF_1787016562_31519

mkdir -p "packages/core"
echo "作成: packages/core/tsconfig.json"
cat << 'EOF_1787016562_27795' > "packages/core/tsconfig.json"
{
    "extends": "../../tsconfig.json",
    "compilerOptions": {
        "lib": [
            "ES2022"
        ],
        "types": [
            "node"
        ]
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1787016562_27795

mkdir -p "packages/core"
echo "作成: packages/core/vitest.config.ts"
cat << 'EOF_1787016562_24069' > "packages/core/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true
    },
    test: {
        globals: true,
        globalSetup: ['./src/test/global-setup.ts'],    // ① テスト前に自動で db:push:test
        setupFiles: ['./src/test/setup.ts'],            // ② 各テスト実行前にテーブルデータを全消去
        fileParallelism: false,                         // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
    },
});
EOF_1787016562_24069

mkdir -p "packages/core/src/registry"
echo "作成: packages/core/src/registry/hono-auto-loader.test.ts"
cat << 'EOF_1787016562_29616' > "packages/core/src/registry/hono-auto-loader.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { db, plugins as pluginsTable, loadFeatureModules } from '../server';
import { PluginRegistry } from '../index';

describe('hono-auto-loader', () => {
    const dummyPluginId = 'test-dummy-plugin';

    beforeEach(() => {
        const dummyApp = new Hono();
        dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));

        PluginRegistry.register({
            id: dummyPluginId,
            name: 'テスト用プラグイン',
            routes: dummyApp,
            navItems: [{ label: 'テスト', path: '/test' }],
        });
    });

    it('DBで有効(enabled: true)のプラグインのみ API ルートがマウントされること', async () => {
        await db.insert(pluginsTable).values({
            id: dummyPluginId,
            name: 'テスト用プラグイン',
            enabled: true,
        }).onConflictDoUpdate({
            target: pluginsTable.id,
            set: { enabled: true },
        });

        const app = new Hono();
        await loadFeatureModules(app, 'packages/features/*/src/server.ts');

        const res = await app.request(`/api/${dummyPluginId}/hello`);
        expect(res.status).toBe(200);
    });

    it('DBで無効(enabled: false)のプラグインはマウントされず 404 になること', async () => {
        await db.insert(pluginsTable).values({
            id: dummyPluginId,
            name: 'テスト用プラグイン',
            enabled: false,
        }).onConflictDoUpdate({
            target: pluginsTable.id,
            set: { enabled: false },
        });

        const app = new Hono();
        await loadFeatureModules(app, 'packages/features/*/src/index.ts');

        const res = await app.request(`/api/${dummyPluginId}/hello`);
        expect(res.status).toBe(404);
    });
});
EOF_1787016562_29616

mkdir -p "packages/core/src/registry"
echo "作成: packages/core/src/registry/hono-auto-loader.ts"
cat << 'EOF_1787016562_19766' > "packages/core/src/registry/hono-auto-loader.ts"
import { Hono } from 'hono';
import { glob } from 'glob';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { db } from '../db';
import { plugins as pluginsTable } from '../db/schema';
import { PluginRegistry } from '../plugins/registry';

//
// packages/features/*/src/index.ts から機能モジュールを自動読み込みし、
// DB 上で有効（enabled: true）なプラグインのみを Hono アプリへマウントする関数
//
export async function loadFeatureModules(app: Hono, pattern: string) {
    const files = await glob(pattern);

    // 1. 各機能モジュールを動的インポート
    // (各モジュールの内部で PluginRegistry.register() が実行される)
    for (const file of files) {
        const absolutePath = path.resolve(file);
        const moduleUrl = pathToFileURL(absolutePath).href;
        await import(moduleUrl);
    }

    // 2. DB から登録済みプラグインの有効/無効ステータスを取得
    let dbPluginsMap = new Map<string, boolean>();
    try {
        const dbPlugins = await db.select().from(pluginsTable);
        dbPlugins.forEach((p) => dbPluginsMap.set(p.id, p.enabled));
    } catch (error) {
        console.warn('[Auto-Loader] DB query failed or table not found. Defaulting all plugins to enabled.');
    }

    // 3. レジストリに登録されたプラグインをチェックし、有効なもののみマウント
    for (const plugin of PluginRegistry.getAll()) {
        // DB に未登録の場合はデフォルトで有効 (true) と判定
        const isEnabled = dbPluginsMap.has(plugin.id)
            ? dbPluginsMap.get(plugin.id)
            : true;

        if (isEnabled) {
            // API パス: /api/{plugin-id} 配下にマウント
            app.route(`/api/${plugin.id}`, plugin.routes);
            console.log(`[Auto-Loader] ✅ Loaded & Mounted Plugin: ${plugin.id}`);
        } else {
            console.log(`[Auto-Loader] ⏸️ Skipped Disabled Plugin: ${plugin.id}`);
        }
    }
}
EOF_1787016562_19766

mkdir -p "packages/core/src"
echo "作成: packages/core/src/index.ts"
cat << 'EOF_1787016562_6694' > "packages/core/src/index.ts"
// 共通環境（Node.js / Browser 両方）で安全に使用できるモジュールのみをエクスポート

// エラー定義 (AppError, ValidationError, UnauthorizedError 等)
export * from './errors';

// 環境変数スキーマ・型 (Zod Schema)
export * from './config/env';

export * from './config/constants';

// DB スキーマ定義（型参照用）
export * from './db/schema';

// プラグインレジストリ・マニフェスト（共通機能）
export * from './plugins/registry';

export * from './auth/auth-registry';
EOF_1787016562_6694

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/constants.ts"
cat << 'EOF_1787016562_12372' > "packages/core/src/config/constants.ts"
export const AUTH_TOKEN_KEY = 'auth_token';
EOF_1787016562_12372

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.test.ts"
cat << 'EOF_1787016562_28628' > "packages/core/src/config/env.test.ts"
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { clientEnvSchema, serverEnvSchema, formatEnvForLog, ServerEnv, ClientEnv } from './env';

// 💡 テスト専用の検証用ヘルパー関数
function parseServerEnv(targetEnv: Record<string, string | undefined>): ServerEnv {
    const result = serverEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        throw new Error(`[Server] 環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

function parseClientEnv(targetEnv: Record<string, string | undefined>): ClientEnv {
    const result = clientEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        throw new Error(`[Client] 環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

describe('packages/core/src/config/env', () => {
    const originalEnv = process.env;

    beforeEach(() => {
        process.env = { ...originalEnv };
    });

    afterEach(() => {
        process.env = originalEnv;
    });

    // テストで使用する最小限の有効な環境変数セット
    const validMockServerEnv = {
        DATABASE_URL: 'postgresql://user:pass@localhost:5432/mydb',
        TEST_DATABASE_URL: 'postgresql://user:pass@localhost:5432/mydb_test',
        JWT_SECRET: 'super-secret-jwt-key-with-at-least-32-chars!',
    };

    describe('serverEnvSchema', () => {
        it('必須のサーバー環境変数が揃っている場合、デフォルト値および動的補完値を含めて正しく検証できること', () => {
            const result = parseServerEnv(validMockServerEnv);

            // デフォルト値の検証
            expect(result.NODE_ENV).toBe('development');
            expect(result.PORT).toBe(3001);

            // PORT(3001) からの動的補完 URL の検証
            expect(result.API_BASE_URL).toBe('http://localhost:3001');
        });

        it('PORT を変更した場合、API_BASE_URL にポート番号が動的に反映されること', () => {
            const customEnv = {
                ...validMockServerEnv,
                PORT: '4000',
            };

            const result = parseServerEnv(customEnv);

            expect(result.PORT).toBe(4000);
            expect(result.API_BASE_URL).toBe('http://localhost:4000');
        });

        it('API_BASE_URL が明示的に指定されている場合、自動補完より優先されること', () => {
            const customEnv = {
                ...validMockServerEnv,
                PORT: '5000',
                API_BASE_URL: 'https://api.example.com',
            };

            const result = parseServerEnv(customEnv);

            expect(result.API_BASE_URL).toBe('https://api.example.com');
        });

        it('PORT に文字列の数値が渡された場合、number 型に変換されること', () => {
            const customEnv = {
                ...validMockServerEnv,
                PORT: '8080',
            };

            const result = parseServerEnv(customEnv);

            expect(result.PORT).toBe(8080);
            expect(typeof result.PORT).toBe('number');
        });

        it('DATABASE_URL が無効な URL の場合、例外がスローされること', () => {
            const invalidEnv = {
                ...validMockServerEnv,
                DATABASE_URL: 'invalid-url-format',
            };

            expect(() => parseServerEnv(invalidEnv)).toThrow('[Server] 環境変数の検証に失敗しました');
        });

        it('JWT_SECRET が 32 文字未満の場合、例外がスローされること', () => {
            const invalidEnv = {
                ...validMockServerEnv,
                JWT_SECRET: 'short-secret', // 32文字未満
            };

            expect(() => parseServerEnv(invalidEnv)).toThrow('[Server] 環境変数の検証に失敗しました');
        });
    });

    describe('clientEnvSchema', () => {
        it('デフォルト値および PORT に応じた VITE_API_TARGET_URL の補完が正しく機能すること', () => {
            const result = parseClientEnv({});

            expect(result.VITE_PORT).toBe(3000);
            expect(result.VITE_APP_TITLE).toBe('My App');
            expect(result.VITE_API_TARGET_URL).toBe('http://127.0.0.1:3001');
        });

        it('PORT を指定した場合、VITE_API_TARGET_URL のポートに正しく反映されること', () => {
            const result = parseClientEnv({ PORT: '4000' });

            expect(result.VITE_API_TARGET_URL).toBe('http://127.0.0.1:4000');
        });

        it('VITE_API_TARGET_URL が明示的に指定されている場合、自動補完より優先されること', () => {
            const result = parseClientEnv({
                PORT: '5000',
                VITE_API_TARGET_URL: 'https://proxy.example.com',
            });

            expect(result.VITE_API_TARGET_URL).toBe('https://proxy.example.com');
        });

        it('VITE_PORT に文字列の数値が渡された場合、number 型に変換されること', () => {
            const result = parseClientEnv({ VITE_PORT: '8081' });

            expect(result.VITE_PORT).toBe(8081);
            expect(typeof result.VITE_PORT).toBe('number');
        });
    });

    describe('formatEnvForLog', () => {
        it('DATABASE_URL や JWT_SECRET などの機密情報がマスクされること', () => {
            const mockParsedServerEnv: ServerEnv = {
                NODE_ENV: 'development',
                PORT: 3001,
                API_BASE_URL: 'http://localhost:3001',
                DATABASE_URL: 'postgresql://postgres:my-secret-password@localhost:5432/app_db',
                TEST_DATABASE_URL: 'postgresql://postgres:test-password@localhost:5432/app_db_test',
                JWT_SECRET: 'super-secret-jwt-key-with-at-least-32-chars!',
            };

            const formatted = formatEnvForLog(mockParsedServerEnv);

            // マスクされているかの検証
            expect(formatted).not.toContain('my-secret-password');
            expect(formatted).not.toContain('test-password');
            expect(formatted).not.toContain('super-secret-jwt-key-with-at-least-32-chars!');

            expect(formatted).toContain('postgresql://postgres:***@localhost:5432/app_db');
            expect(formatted).toContain('postgresql://postgres:***@localhost:5432/app_db_test');
            expect(formatted).toContain('"JWT_SECRET": "***"');
        });
    });
});
EOF_1787016562_28628

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.ts"
cat << 'EOF_1787016562_6476' > "packages/core/src/config/env.ts"
import { z } from 'zod';

// ==========================================
// 0. 環境非依存の型宣言・補助定義
// ==========================================

// Node.js process のグローバル型宣言（DOM環境における型欠落防止）
declare const process: {
    env?: Record<string, string>;
} | undefined;

// アプリケーション全体で統一して使用するポートのデフォルト定数
export const DEFAULT_BACKEND_PORT = 3001;
export const DEFAULT_FRONTEND_PORT = 3000;

// ==========================================
// 1. スキーマの分離定義
// ==========================================

/** フロントエンド用スキーマ (Vite / Browser) */
export const clientEnvSchema = z
    .object({
        // バックエンドポート番号（VITE_API_TARGET_URL の補完計算用）
        PORT: z.coerce.number().int().positive().default(DEFAULT_BACKEND_PORT),
        // フロントエンド開発サーバー用ポート
        VITE_PORT: z.coerce.number().int().positive({ message: 'VITE_PORT は正の整数である必要があります' })
            .default(DEFAULT_FRONTEND_PORT),
        VITE_API_TARGET_URL: z.string().url({ message: 'VITE_API_TARGET_URL は有効なURL形式である必要があります' })
            .optional(),
        VITE_APP_TITLE: z.string()
            .default('My App'),
    })
    .transform((data) => ({
        VITE_PORT: data.VITE_PORT,
        // PORT の指定を反映して VITE_API_TARGET_URL を動的に補完生成
        VITE_API_TARGET_URL: data.VITE_API_TARGET_URL ?? `http://127.0.0.1:${data.PORT}`,
        VITE_APP_TITLE: data.VITE_APP_TITLE,
    }));

/** バックエンド用スキーマ (Node.js Server) */
export const serverEnvSchema = z
    .object({
        NODE_ENV: z.enum(['development', 'test', 'production'])
            .default('development'),
        PORT: z.coerce.number().int().positive({ message: 'PORT は正の整数である必要があります' })
            .default(DEFAULT_BACKEND_PORT),
        API_BASE_URL: z.string().url()
            .optional(),
        CORS_ORIGIN: z.string()
            .optional(),
        DATABASE_URL: z.string().url({ message: 'DATABASE_URL は有効なURL形式である必要があります' })
            .optional(),
        TEST_DATABASE_URL: z.string().url({ message: 'TEST_DATABASE_URL は有効なURL形式である必要があります' })
            .optional(),

        // サーバー側では必須（optional 化の妥協は不要）
        JWT_SECRET: z.string().min(32, { message: 'JWT_SECRET は32文字以上である必要があります' }),
    })
    .superRefine((data, ctx) => {
        if (data.NODE_ENV === 'production') {
            if (!data.DATABASE_URL) {
                ctx.addIssue({
                    code: z.ZodIssueCode.custom,
                    path: ['DATABASE_URL'],
                    message: '本番環境では DATABASE_URL の指定が必須です',
                });
            }
        }
    })
    .transform((data) => ({
        ...data,
        API_BASE_URL: data.API_BASE_URL ?? `http://localhost:${data.PORT}`,
        CORS_ORIGIN: data.CORS_ORIGIN ?? `http://localhost:${DEFAULT_FRONTEND_PORT}`,
        DATABASE_URL: data.DATABASE_URL
            ?? (data.NODE_ENV !== 'production' ? 'postgresql://postgres:postgres@db:5432/app_db' : ''),
        TEST_DATABASE_URL: data.TEST_DATABASE_URL
            ?? (data.NODE_ENV !== 'production' ? 'postgresql://postgres:postgres@db:5432/app_db_test' : ''),
    }));

export type ClientEnv = z.infer<typeof clientEnvSchema>;
export type ServerEnv = z.infer<typeof serverEnvSchema>;

// ==========================================
// 2. 環境別の安全な評価・生成処理
// ==========================================

/** クライアント環境変数のパース (Vite 環境) */
function getClientEnv(): ClientEnv {
    const metaEnv = typeof import.meta !== 'undefined' ? (import.meta as { env?: Record<string, string> }).env : undefined;
    const targetEnv =
        metaEnv
            ? metaEnv : typeof process !== 'undefined' && process.env
                ? process.env : {};

    const result = clientEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        console.error('❌ [Client] 無効な環境変数があります:\n', formattedErrors);
        throw new Error(`[Client] 環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

/** サーバー環境変数のパース (Node.js 環境) */
function getServerEnv(): ServerEnv {
    const targetEnv = typeof process !== 'undefined' && process.env ? process.env : {};

    //    // テスト実行時 (NODE_ENV === 'test') の安全フォールバック処理
    //    if (targetEnv.NODE_ENV === 'test') {
    //        const fallbackResult = serverEnvSchema.safeParse({
    //            ...targetEnv,
    //            JWT_SECRET: targetEnv.JWT_SECRET ?? '12345678901234567890123456789012',
    //        });
    //        if (fallbackResult.success) return fallbackResult.data;
    //    }

    const result = serverEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        console.error('❌ [Server] 無効な環境変数があります:\n', formattedErrors);
        throw new Error(`[Server] 環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

// ==========================================
// 3. 外部公開用オブジェクト (Export)
// ==========================================

export const isTest = typeof process !== 'undefined' && process.env && (process.env.NODE_ENV === 'test' || Boolean(process.env.VITEST));
export const isServer = typeof globalThis !== 'undefined' && !('document' in globalThis);

/** フロントエンド用環境変数 (App.tsx などから参照) */
export const clientEnv: ClientEnv = getClientEnv();

/** バックエンド用環境変数 (サーバーコードのみから参照) */
export const env: ServerEnv = (isServer || isTest)
    ? getServerEnv()
    : (new Proxy({} as ServerEnv, {
        get() {
            throw new Error('❌ [Security Alert] フロントエンド（ブラウザ）からサーバー環境変数 (env) を参照することはできません。');
        },
    }));

// ==========================================
// 4. ログ出力用整形関数
// ==========================================
export function formatEnvForLog(targetEnv: ServerEnv = env): string {
    const maskedEnv = { ...targetEnv };

    if (maskedEnv.DATABASE_URL) {
        maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL
            .replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    }
    if (maskedEnv.TEST_DATABASE_URL) {
        maskedEnv.TEST_DATABASE_URL = maskedEnv.TEST_DATABASE_URL
            .replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    }
    if (maskedEnv.JWT_SECRET) {
        maskedEnv.JWT_SECRET = '***';
    }

    return JSON.stringify(maskedEnv, null, 2);
}
EOF_1787016562_6476

mkdir -p "packages/core/src"
echo "作成: packages/core/src/server.ts"
cat << 'EOF_1787016562_29835' > "packages/core/src/server.ts"
// Node.js (apps/api) 専用モジュールの集約エクスポート
// export * from './auth/auth-registry';
export * from './registry/hono-auto-loader';
export * from './db';
EOF_1787016562_29835

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/index.ts"
cat << 'EOF_1787016562_7461' > "packages/core/src/db/index.ts"
import { drizzle } from 'drizzle-orm/postgres-js';

import postgres from 'postgres';
import * as schema from './schema';
import { env, isTest } from '../config/env';

// 必要な接続のみを 1 つだけ生成
const dbUrl = isTest ? env.TEST_DATABASE_URL : env.DATABASE_URL;
export const activeQueryClient = postgres(dbUrl);
export const db = drizzle(activeQueryClient, { schema });

// // 開発用（本番用）PostgreSQL 接続クライアントの作成
// const queryClient = postgres(env.DATABASE_URL);
// export const dev_db = drizzle(queryClient, { schema });

// // テスト用PostgreSQL 接続クライアントの作成
// const queryTestClient = postgres(env.TEST_DATABASE_URL);
// export const test_db = drizzle(queryTestClient, { schema });

// // テスト用と開発用（本番用）の接続クライアント動的に選択
// export const db = isTest ? test_db : dev_db;

// // テスト終了時などにコネクションを安全に破棄するためのクライアント
// export const activeQueryClient = isTest ? queryTestClient : queryClient;

// 1. スキーマオブジェクト全体を export (drizzleConfig や drizzle(client, { schema }) 用)
export { schema };

// 2. 個別のテーブルも直接 import { users, plugins } から使えるように re-export
export * from './schema';
EOF_1787016562_7461

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/seed.ts"
cat << 'EOF_1787016562_12854' > "packages/core/src/db/seed.ts"
import { db, users } from './index';
import { hashPassword } from '@app/plugins-auth-local';
import { eq } from 'drizzle-orm';

export async function seed() {
    console.log('🌱 開発用データを投入中...');

    const adminEmail = 'admin@example.com';
    const [existing] = await db.select().from(users).where(eq(users.email, adminEmail));

    if (!existing) {
        const passwordHash = await hashPassword('password123');
        await db.insert(users).values({
            name: '管理者ユーザー',
            email: adminEmail,
            passwordHash,
            role: 'admin',
            isActive: true,
        });
        console.log('✅ 管理者ユーザーを作成しました: admin@example.com / password123');
    } else {
        console.log('ℹ️ 管理者ユーザーは既に存在します');
    }
}

seed().catch((err) => {
    console.error('❌ シード処理に失敗しました:', err);
    process.exit(1);
});
EOF_1787016562_12854

mkdir -p "packages/core/src/db/schema"
echo "作成: packages/core/src/db/schema/index.ts"
cat << 'EOF_1787016562_19590' > "packages/core/src/db/schema/index.ts"
// packages/core/src/db/schema/index.ts
export * from './users';
export * from './plugins';
EOF_1787016562_19590

mkdir -p "packages/core/src/db/schema"
echo "作成: packages/core/src/db/schema/plugins.test.ts"
cat << 'EOF_1787016562_5017' > "packages/core/src/db/schema/plugins.test.ts"
import { describe, it, expect, afterAll, beforeEach } from 'vitest';
import { db, activeQueryClient } from '../../server';
import { plugins } from './plugins';
import { eq } from 'drizzle-orm';

describe('Plugins DB Integration Tests', () => {
    afterAll(async () => {
        // テスト終了後に DB コネクションを破棄
        await activeQueryClient.end();
    });

    beforeEach(async () => {
        // テストごとに plugins テーブルをクリーンアップ
        await db.delete(plugins);
    });

    it('プラグイン情報を正常に挿入および取得できること', async () => {
        const newPlugin = {
            id: 'test-feature',
            name: 'テスト機能',
            description: 'テスト用の説明文です',
            enabled: true,
        };

        const [inserted] = await db.insert(plugins).values(newPlugin).returning();

        expect(inserted.id).toBe(newPlugin.id);
        expect(inserted.name).toBe(newPlugin.name);
        expect(inserted.description).toBe(newPlugin.description);
        expect(inserted.enabled).toBe(true); // デフォルト値の検証
        expect(inserted.updatedAt).toBeInstanceOf(Date);

        // IDで検索して同一データが取得できるか検証
        const [found] = await db.select().from(plugins).where(eq(plugins.id, inserted.id));
        expect(found).toBeDefined();
        expect(found.name).toBe(newPlugin.name);
    });

    it('プラグインの有効/無効 (enabled) ステータスを更新できること', async () => {
        const targetPlugin = {
            id: 'user-management',
            name: 'ユーザー管理機能',
            enabled: true,
        };

        await db.insert(plugins).values(targetPlugin);

        // 有効状態を false (無効) に更新
        const [updated] = await db
            .update(plugins)
            .set({ enabled: false })
            .where(eq(plugins.id, targetPlugin.id))
            .returning();

        expect(updated.enabled).toBe(false);

        // DB上でも変更が反映されているか確認
        const [found] = await db.select().from(plugins).where(eq(plugins.id, targetPlugin.id));
        expect(found.enabled).toBe(false);
    });

    it('主キー (id) の重複時にエラーが発生すること', async () => {
        const pluginPayload = {
            id: 'duplicate-plugin',
            name: '重複テスト',
        };

        await db.insert(plugins).values(pluginPayload);

        // 同じ ID で再挿入を試みると例外が発生すること
        await expect(
            db.insert(plugins).values({
                ...pluginPayload,
                name: '重複テスト2',
            })
        ).rejects.toThrow();
    });
});
EOF_1787016562_5017

mkdir -p "packages/core/src/db/schema"
echo "作成: packages/core/src/db/schema/plugins.ts"
cat << 'EOF_1787016562_24221' > "packages/core/src/db/schema/plugins.ts"
import { boolean, pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

// プラグイン管理テーブル
export const plugins = pgTable('plugins', {
    id: text('id').primaryKey(), // 例: 'user-management'
    name: text('name').notNull(), // 表示名: 'ユーザー管理'
    description: text('description'), // 説明
    enabled: boolean('enabled').default(true).notNull(), // 有効/無効フラグ
    updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

import { InferSelectModel, InferInsertModel } from 'drizzle-orm';

export type Plugin = InferSelectModel<typeof plugins>;
export type NewPlugin = InferInsertModel<typeof plugins>;
EOF_1787016562_24221

mkdir -p "packages/core/src/db/schema"
echo "作成: packages/core/src/db/schema/users.ts"
cat << 'EOF_1787016562_648' > "packages/core/src/db/schema/users.ts"
import { boolean, pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';
import { InferSelectModel, InferInsertModel } from 'drizzle-orm';

export const users = pgTable('users', {
    id: serial('id').primaryKey(),
    name: text('name').notNull(),
    email: text('email').notNull().unique(),
    passwordHash: text('password_hash').notNull(),
    role: text('role').notNull().default('user'),
    isActive: boolean('is_active').notNull().default(true),
    createdAt: timestamp('created_at').defaultNow().notNull(),
});

export type User = InferSelectModel<typeof users>;
export type NewUser = InferInsertModel<typeof users>;
EOF_1787016562_648

mkdir -p "packages/core/src/db/schema"
echo "作成: packages/core/src/db/schema/users.test.ts"
cat << 'EOF_1787016562_7527' > "packages/core/src/db/schema/users.test.ts"
import { describe, it, expect, afterAll, beforeEach } from 'vitest';
import { db, activeQueryClient } from '../../server';
import { users } from './users';
import { eq } from 'drizzle-orm';

describe('Users DB Integration Tests', () => {
    afterAll(async () => {
        // テスト終了後に PostgreSQL 接続をシャットダウン
        await activeQueryClient.end();
    });

    beforeEach(async () => {
        // テストごとに users テーブルをクリーンアップ
        await db.delete(users);
    });

    it('ユーザーを正常に挿入および取得できること', async () => {
        const newUser = {
            name: 'テストユーザー',
            email: 'test@example.com',
            passwordHash: '$2a$10$hashedpasswordexample',
        };

        const [inserted] = await db.insert(users).values(newUser).returning();

        expect(inserted.id).toBeDefined();
        expect(inserted.name).toBe(newUser.name);
        expect(inserted.email).toBe(newUser.email);
        expect(inserted.role).toBe('user'); // デフォルト値の検証
        expect(inserted.isActive).toBe(true); // デフォルト値(isActive: true)の検証（追加）
        expect(inserted.createdAt).toBeInstanceOf(Date);

        // IDで検索して同一データが取得できるか
        const [found] = await db.select().from(users).where(eq(users.id, inserted.id));
        expect(found).toBeDefined();
        expect(found.email).toBe(newUser.email);
    });

    it('ユーザーの有効/無効 (isActive) ステータスを更新できること', async () => {
        const newUser = {
            name: 'ステータステストユーザー',
            email: 'status@example.com',
            passwordHash: 'hash',
        };

        const [inserted] = await db.insert(users).values(newUser).returning();
        expect(inserted.isActive).toBe(true);

        // アカウントを無効化 (false)
        const [disabled] = await db
            .update(users)
            .set({ isActive: false })
            .where(eq(users.id, inserted.id))
            .returning();

        expect(disabled.isActive).toBe(false);

        // DB上でも変更が反映されているか確認
        const [found] = await db.select().from(users).where(eq(users.id, inserted.id));
        expect(found.isActive).toBe(false);
    });

    it('同じ email のユーザーを挿入した場合、エラーが発生すること（Unique制約）', async () => {
        const userPayload = {
            name: 'ユーザー1',
            email: 'duplicate@example.com',
            passwordHash: 'hash123',
        };

        await db.insert(users).values(userPayload);

        // 同じ email で挿入を試みると例外が発生すること
        await expect(
            db.insert(users).values({
                ...userPayload,
                name: 'ユーザー2',
            })
        ).rejects.toThrow();
    });
});
EOF_1787016562_7527

mkdir -p "packages/core/src/auth"
echo "作成: packages/core/src/auth/auth-registry.ts"
cat << 'EOF_1787016562_30903' > "packages/core/src/auth/auth-registry.ts"
export interface AuthPlugin {
  name: string;
  authenticate(credentials: any): Promise<{ id: string; name: string }>;
}

export class AuthRegistry {
  private static strategies = new Map<string, AuthPlugin>();

  static register(plugin: AuthPlugin) {
    this.strategies.set(plugin.name, plugin);
    console.log(`[AuthRegistry] Registered strategy: ${plugin.name}`);
  }

  static async authenticate(strategy: string, credentials: any) {
    const plugin = this.strategies.get(strategy);
    if (!plugin) {
      throw new Error(`Authentication strategy '${strategy}' not found.`);
    }
    return plugin.authenticate(credentials);
  }
}
EOF_1787016562_30903

mkdir -p "packages/core/src/plugins"
echo "作成: packages/core/src/plugins/registry.ts"
cat << 'EOF_1787016562_26352' > "packages/core/src/plugins/registry.ts"
// packages/core/src/plugins/registry.ts
import { Hono } from 'hono';

export interface PluginManifest {
    id: string;            // 一意キー (例: 'user-management')
    name: string;          // 表示名
    description?: string;  // 説明
    routes: Hono;          // プラグインが提供する Hono ルーター
    navItems?: Array<{     // フロントエンド表示用メニュー情報
        label: string;
        path: string;
        icon?: string;
    }>;
}

export class PluginRegistry {
    private static plugins = new Map<string, PluginManifest>();

    static register(plugin: PluginManifest) {
        this.plugins.set(plugin.id, plugin);
    }

    static get(id: string): PluginManifest | undefined {
        return this.plugins.get(id);
    }

    static getAll(): PluginManifest[] {
        return Array.from(this.plugins.values());
    }
}
EOF_1787016562_26352

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/unauthorized-error.ts"
cat << 'EOF_1787016562_13129' > "packages/core/src/errors/unauthorized-error.ts"
import { AppError } from './app-error';

export class UnauthorizedError extends AppError {
    constructor(message = 'Authentication token is missing or invalid') {
        super(401, 'unauthorized', 'Unauthorized', message);
    }
}
EOF_1787016562_13129

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/index.ts"
cat << 'EOF_1787016562_14922' > "packages/core/src/errors/index.ts"
export * from './types';
export * from './app-error';
export * from './bad-request-error';
export * from './not-found-error';
export * from './internal-server-error';
export * from './validation-error';
export * from './unauthorized-error';
export * from './forbidden-error';
EOF_1787016562_14922

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/app-error.ts"
cat << 'EOF_1787016562_20135' > "packages/core/src/errors/app-error.ts"
export class AppError extends Error {
    constructor(
        public readonly status: number,
        public readonly code: string,
        public readonly title: string,
        message: string
    ) {
        super(message);
        this.name = 'AppError';
    }
}
EOF_1787016562_20135

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/bad-request-error.ts"
cat << 'EOF_1787016562_26517' > "packages/core/src/errors/bad-request-error.ts"
import { AppError } from './app-error';

export class BadRequestError extends AppError {
    constructor(message = 'The request was invalid or cannot be served') {
        super(400, 'bad-request', 'Bad Request', message);
    }
}
EOF_1787016562_26517

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/types.ts"
cat << 'EOF_1787016562_24130' > "packages/core/src/errors/types.ts"
export interface InvalidParam {
    name: string;
    reason: string;
}

export interface ProblemDetails {
    type: string;
    title: string;
    status: number;
    detail: string;
    instance: string;
    invalidParams?: InvalidParam[];
}
EOF_1787016562_24130

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/forbidden-error.ts"
cat << 'EOF_1787016562_149' > "packages/core/src/errors/forbidden-error.ts"
import { AppError } from './app-error';

export class ForbiddenError extends AppError {
    constructor(message = 'You do not have permission to access this resource') {
        super(403, 'forbidden', 'Forbidden', message);
    }
}
EOF_1787016562_149

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/validation-error.ts"
cat << 'EOF_1787016562_24171' > "packages/core/src/errors/validation-error.ts"
import { AppError } from './app-error';
import type { InvalidParam } from './types';

export class ValidationError extends AppError {
    constructor(
        public readonly invalidParams: InvalidParam[],
        message = 'Validation failed for the request payload'
    ) {
        super(400, 'validation-error', 'Bad Request', message);
    }
}
EOF_1787016562_24171

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/not-found-error.ts"
cat << 'EOF_1787016562_28304' > "packages/core/src/errors/not-found-error.ts"
import { AppError } from './app-error';

export class NotFoundError extends AppError {
    constructor(message = 'The requested resource was not found') {
        super(404, 'not-found', 'Not Found', message);
    }
}
EOF_1787016562_28304

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/internal-server-error.ts"
cat << 'EOF_1787016562_15214' > "packages/core/src/errors/internal-server-error.ts"
import { AppError } from './app-error';

export class InternalServerError extends AppError {
    constructor(message = 'An unexpected error occurred') {
        super(500, 'internal-server-error', 'Internal Server Error', message);
    }
}
EOF_1787016562_15214

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/setup.ts"
cat << 'EOF_1787016562_1190' > "packages/core/src/test/setup.ts"
import { beforeEach } from 'vitest';
import { db } from '../server'; // テスト用DBに接続しているDrizzleインスタンス
import { sql } from 'drizzle-orm';
import '@testing-library/jest-dom';

beforeEach(async () => {
    // 全テーブルのデータをクリーンアップ（例: public スキーマ内の全テーブルを TRUNCATE）
    await db.execute(sql`
    DO $$ DECLARE
        r RECORD;
    BEGIN
        FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
            EXECUTE 'TRUNCATE TABLE ' || quote_ident(r.tablename) || ' CASCADE;';
        END LOOP;
    END $$;
  `);
});
EOF_1787016562_1190

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/global-setup.ts"
cat << 'EOF_1787016562_4966' > "packages/core/src/test/global-setup.ts"
import { execSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// import.meta.url から安全にパスを抽出
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function setup() {
    console.log('\n🔄 テスト用データベースに最新のスキーマを反映中...');

    // packages/core のルートディレクトリパスを解決
    const corePackageDir = path.resolve(__dirname, '../../');
    const configPath = path.resolve(corePackageDir, 'drizzle-test.config.ts');

    try {
        execSync(`npx drizzle-kit push --config="${configPath}"`, {
            cwd: corePackageDir,
            stdio: 'inherit',
            env: {
                ...process.env, // 親プロセスの環境変数を引き継ぐ
            },
        });
        console.log('✅ テスト用データベースの準備完了!\n');
    } catch (error) {
        console.error('❌ テスト用データベースへのスキーマ反映に失敗しました:', error);
        throw error;
    }
}
EOF_1787016562_4966

mkdir -p "packages/core"
echo "作成: packages/core/drizzle.config.ts"
cat << 'EOF_1787016562_10359' > "packages/core/drizzle.config.ts"
import { defineConfig } from 'drizzle-kit';
import { env } from './src/config/env';

export default defineConfig({
    schema: './src/db/schema/index.ts',
    out: './drizzle',
    dialect: 'postgresql',
    dbCredentials: {
        url: env.DATABASE_URL,
    },
});
EOF_1787016562_10359

mkdir -p "packages/features/sample"
echo "作成: packages/features/sample/package.json"
cat << 'EOF_1787016562_19267' > "packages/features/sample/package.json"
{
  "name": "@app/features-sample",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1787016562_19267

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.ts"
cat << 'EOF_1787016562_26848' > "packages/features/sample/src/index.ts"
import { Hono } from 'hono';

export default function createSampleFeature() {
  const app = new Hono();

  app.get('/sample', (c) => {
    return c.json({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });

  return app;
}
EOF_1787016562_26848

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.test.ts"
cat << 'EOF_1787016562_24423' > "packages/features/sample/src/index.test.ts"
import { describe, it, expect } from 'vitest';
import createSampleFeature from './index';

describe('Sample Feature Module', () => {
  const app = createSampleFeature();

  it('GET /sample は正常メッセージを返すこと', async () => {
    const res = await app.request('/sample');
    expect(res.status).toBe(200);

    const body = await res.json();
    expect(body).toEqual({
      message: 'Hello from Auto-Loaded Sample Feature in DevContainer!',
    });
  });
});
EOF_1787016562_24423

mkdir -p "packages/features/user-management"
echo "作成: packages/features/user-management/package.json"
cat << 'EOF_1787016562_29750' > "packages/features/user-management/package.json"
{
    "name": "@app/features/user-management",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "main": "./src/index.ts",
    "exports": {
        ".": "./src/index.ts",
        "./ui": "./src/components/UserManagementTable.tsx"
    },
    "scripts": {
        "test": "vitest run"
    },
    "dependencies": {
        "@app/ui": "*",
        "react": "^18.2.0",
        "react-dom": "^18.2.0"
    },
    "devDependencies": {
        "@tailwindcss/vite": "^4.0.0",
        "@testing-library/jest-dom": "^6.9.1",
        "@testing-library/react": "^16.3.2",
        "@types/react": "^18.2.55",
        "@types/react-dom": "^18.2.19",
        "@vitejs/plugin-react": "^6.0.5",
        "jsdom": "^29.1.1",
        "tailwindcss": "^4.0.0",
        "typescript": "^5.3.3"
    }
}
EOF_1787016562_29750

mkdir -p "packages/features/user-management"
echo "作成: packages/features/user-management/tsconfig.json"
cat << 'EOF_1787016562_30894' > "packages/features/user-management/tsconfig.json"
{
    "extends": "../../../tsconfig.json",
    "compilerOptions": {
        "jsx": "react-jsx",
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1787016562_30894

mkdir -p "packages/features/user-management"
echo "作成: packages/features/user-management/vitest.config.ts"
cat << 'EOF_1787016562_10725' > "packages/features/user-management/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true
    },
    test: {
        globals: true,
        environment: 'jsdom',
        globalSetup: ['./src/test/global-setup.ts'],    // ① テスト前に自動で db:push:test
        setupFiles: ['./src/test/setup.ts'],            // ② 各テスト実行前にテーブルデータを全消去
        fileParallelism: false,                         // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
    },
});
EOF_1787016562_10725

mkdir -p "packages/features/user-management/src"
echo "作成: packages/features/user-management/src/index.ts"
cat << 'EOF_1787016562_8483' > "packages/features/user-management/src/index.ts"
import { PluginRegistry } from '@app/core';
import { userRoutes } from './routes';

export { UserManagementTable } from './components/UserManagementTable';

PluginRegistry.register({
    id: 'user-management',
    name: 'ユーザー管理機能',
    description: 'ユーザー一覧の表示、ロール変更およびアカウント有効/無効の管理を行います',
    routes: userRoutes,
    navItems: [
        {
            label: 'ユーザー管理',
            path: '/admin/users',
            icon: 'users',
        },
    ],
});
EOF_1787016562_8483

mkdir -p "packages/features/user-management/src"
echo "作成: packages/features/user-management/src/routes.test.ts"
cat << 'EOF_1787016562_31703' > "packages/features/user-management/src/routes.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { db, users } from '@app/core/server';
import { userRoutes } from './routes';

describe('User Management Plugin API', () => {
    const app = new Hono();
    app.route('/', userRoutes);

    beforeEach(async () => {
        await db.delete(users);

        await db.insert(users).values([
            {
                id: 1,
                name: '管理者',
                email: 'admin@example.com',
                passwordHash: 'hashed',
                role: 'admin',
                isActive: true,
            },
            {
                id: 2,
                name: '一般ユーザー',
                email: 'user@example.com',
                passwordHash: 'hashed',
                role: 'user',
                isActive: true,
            },
        ]);
    });

    it('GET / - ユーザー一覧を取得できること', async () => {
        const res = await app.request('/');
        expect(res.status).toBe(200);

        const body = await res.json();
        expect(body.users.length).toBe(2);
    });

    it('POST / - 新規ユーザーを追加できること', async () => {
        const res = await app.request('/', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                name: '新規プラグインユーザー',
                email: 'plugin_new@example.com',
                role: 'user',
            }),
        });

        expect(res.status).toBe(201);
        const body = await res.json();
        expect(body.user.email).toBe('plugin_new@example.com');
    });

    it('PATCH /:id/role - ユーザーのロールを変更できること', async () => {
        const res = await app.request('/2/role', {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ role: 'admin' }),
        });

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body.user.role).toBe('admin');
    });

    it('PATCH /:id/status - アカウント有効/無効を切り替えられること', async () => {
        const res = await app.request('/2/status', {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ isActive: false }),
        });

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body.user.isActive).toBe(false);
    });

    it('DELETE /:id - ユーザーを削除できること', async () => {
        const res = await app.request('/2', {
            method: 'DELETE',
        });

        expect(res.status).toBe(200);
    });
});

// import { describe, it, expect, beforeEach } from 'vitest';
// import { Hono } from 'hono';
// import { db, users } from '@app/core/server';
// import { userRoutes } from './routes';

// describe('User Management Plugin API', () => {
//     const app = new Hono();
//     app.route('/', userRoutes);

//     beforeEach(async () => {
//         await db.delete(users);

//         await db.insert(users).values({
//             name: 'Test User',
//             email: 'test@example.com',
//             passwordHash: 'hashed',
//             role: 'user',
//             isActive: true,
//         });
//     });

//     it('GET / - ユーザー一覧を取得できること', async () => {
//         const res = await app.request('/');
//         expect(res.status).toBe(200);

//         const body = await res.json();
//         expect(body.users).toBeDefined();
//         expect(Array.isArray(body.users)).toBe(true);
//         expect(body.users.length).toBeGreaterThan(0);
//         expect(body.users[0].isActive).toBeDefined();
//     });

//     it('PATCH /:id/role - ユーザーのロールを変更できること', async () => {
//         const userListRes = await app.request('/');
//         const { users } = await userListRes.json();
//         const targetUser = users[0];

//         const res = await app.request(`/${targetUser.id}/role`, {
//             method: 'PATCH',
//             headers: { 'Content-Type': 'application/json' },
//             body: JSON.stringify({ role: 'admin' }),
//         });

//         expect(res.status).toBe(200);
//         const body = await res.json();
//         expect(body.user.role).toBe('admin');
//     });

//     it('PATCH /:id/status - ユーザーのアカウント有効/無効を切り替えられること', async () => {
//         const userListRes = await app.request('/');
//         const { users } = await userListRes.json();
//         const targetUser = users[0];

//         const res = await app.request(`/${targetUser.id}/status`, {
//             method: 'PATCH',
//             headers: { 'Content-Type': 'application/json' },
//             body: JSON.stringify({ isActive: false }),
//         });

//         expect(res.status).toBe(200);
//         const body = await res.json();
//         expect(body.user.isActive).toBe(false);
//     });
// });
EOF_1787016562_31703

mkdir -p "packages/features/user-management/src/api"
echo "作成: packages/features/user-management/src/api/user-management-api.ts"
cat << 'EOF_1787016562_7904' > "packages/features/user-management/src/api/user-management-api.ts"
export interface User {
    id: number;
    name: string;
    email: string;
    role: 'admin' | 'user';
    isActive: boolean;
    createdAt?: string;
}

export interface CreateUserInput {
    name: string;
    email: string;
    role: 'admin' | 'user';
}

export const fetchUsers = async (apiBaseUrl: string): Promise<User[]> => {
    const res = await fetch(apiBaseUrl);
    if (!res.ok) throw new Error('ユーザー一覧の取得に失敗しました');
    const data = await res.json();
    return data.users;
};

export const createUser = async (apiBaseUrl: string, input: CreateUserInput): Promise<User> => {
    const res = await fetch(apiBaseUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
    });
    if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.detail || errorData.message || 'ユーザーの作成に失敗しました');
    }
    const data = await res.json();
    return data.user;
};

export const updateUserStatus = async (apiBaseUrl: string, id: number, isActive: boolean): Promise<User> => {
    const res = await fetch(`${apiBaseUrl}/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isActive }),
    });
    if (!res.ok) throw new Error('ステータスの更新に失敗しました');
    const data = await res.json();
    return data.user;
};

export const updateUserRole = async (apiBaseUrl: string, id: number, role: 'admin' | 'user'): Promise<User> => {
    const res = await fetch(`${apiBaseUrl}/${id}/role`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ role }),
    });
    if (!res.ok) throw new Error('ロールの更新に失敗しました');
    const data = await res.json();
    return data.user;
};
EOF_1787016562_7904

mkdir -p "packages/features/user-management/src"
echo "作成: packages/features/user-management/src/routes.ts"
cat << 'EOF_1787016562_28316' > "packages/features/user-management/src/routes.ts"
import { Hono } from 'hono';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { db, users as usersTable } from '@app/core/server';
import { ValidationError, BadRequestError, NotFoundError } from '@app/core';
import { hashPassword } from '@app/plugins-auth-local';
import { eq } from 'drizzle-orm';

export const userRoutes = new Hono();

// ログインユーザー ID の取得ヘルパー
function getCurrentUserId(c: any): number | null {
    const user = c.get('user');
    if (!user) return null;
    const rawId = user.sub ?? user.id;
    return rawId ? Number(rawId) : null;
}

// 1. ユーザー一覧取得
userRoutes.get('/', async (c) => {
    const userList = await db.select({
        id: usersTable.id,
        name: usersTable.name,
        email: usersTable.email,
        role: usersTable.role,
        isActive: usersTable.isActive,
        createdAt: usersTable.createdAt,
    }).from(usersTable);

    return c.json({ users: userList });
});

// 2. ユーザー新規追加
const createUserSchema = z.object({
    name: z.string().min(1, '名前は必須です'),
    email: z.string().email('有効なメールアドレスを入力してください'),
    role: z.enum(['admin', 'user']),
});

userRoutes.post(
    '/',
    zValidator('json', createUserSchema, (result) => {
        if (!result.success) {
            const invalidParams = result.error.issues.map((issue) => ({
                name: issue.path.join('.'),
                reason: issue.message,
            }));
            throw new ValidationError(invalidParams);
        }
    }),
    async (c) => {
        const body = c.req.valid('json');

        const [existingUser] = await db.select().from(usersTable).where(eq(usersTable.email, body.email));
        if (existingUser) {
            throw new BadRequestError('指定されたメールアドレスは既に登録されています');
        }

        const defaultPassword = `InitPass_${Math.random().toString(36).slice(-8)}`;
        const passwordHash = await hashPassword(defaultPassword);

        const [newUser] = await db.insert(usersTable).values({
            name: body.name,
            email: body.email,
            passwordHash,
            role: body.role,
            isActive: true,
        }).returning({
            id: usersTable.id,
            name: usersTable.name,
            email: usersTable.email,
            role: usersTable.role,
            isActive: usersTable.isActive,
            createdAt: usersTable.createdAt,
        });

        return c.json({ user: newUser }, 201);
    }
);

// 3. ロール変更
const updateRoleSchema = z.object({
    role: z.enum(['user', 'admin']),
});

userRoutes.patch(
    '/:id/role',
    zValidator('json', updateRoleSchema),
    async (c) => {
        const id = Number(c.req.param('id'));
        const currentUserId = getCurrentUserId(c);
        const { role } = c.req.valid('json');

        if (currentUserId === id && role !== 'admin') {
            throw new BadRequestError('自分自身の管理者権限を変更することはできません');
        }

        const updatedUsers = await db
            .update(usersTable)
            .set({ role })
            .where(eq(usersTable.id, id))
            .returning({
                id: usersTable.id,
                name: usersTable.name,
                email: usersTable.email,
                role: usersTable.role,
                isActive: usersTable.isActive,
            });

        if (updatedUsers.length === 0) {
            throw new NotFoundError('ユーザーが見つかりません');
        }

        return c.json({ user: updatedUsers[0] });
    }
);

// 4. アカウント有効化/無効化
const updateStatusSchema = z.object({
    isActive: z.boolean(),
});

userRoutes.patch(
    '/:id/status',
    zValidator('json', updateStatusSchema),
    async (c) => {
        const id = Number(c.req.param('id'));
        const currentUserId = getCurrentUserId(c);
        const { isActive } = c.req.valid('json');

        if (currentUserId === id && isActive === false) {
            throw new BadRequestError('自分自身のアカウントを無効化することはできません');
        }

        const updatedUsers = await db
            .update(usersTable)
            .set({ isActive })
            .where(eq(usersTable.id, id))
            .returning({
                id: usersTable.id,
                name: usersTable.name,
                email: usersTable.email,
                role: usersTable.role,
                isActive: usersTable.isActive,
            });

        if (updatedUsers.length === 0) {
            throw new NotFoundError('ユーザーが見つかりません');
        }

        return c.json({ user: updatedUsers[0] });
    }
);

// 5. ユーザー削除
userRoutes.delete('/:id', async (c) => {
    const id = Number(c.req.param('id'));
    const currentUserId = getCurrentUserId(c);

    if (currentUserId === id) {
        throw new BadRequestError('自分自身のアカウントを削除することはできません');
    }

    const deletedUsers = await db
        .delete(usersTable)
        .where(eq(usersTable.id, id))
        .returning({
            id: usersTable.id,
            name: usersTable.name,
            email: usersTable.email,
        });

    if (deletedUsers.length === 0) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ message: 'ユーザーを削除しました', user: deletedUsers[0] });
});

// import { Hono } from 'hono';
// import { z } from 'zod';
// import { zValidator } from '@hono/zod-validator';
// import { db, users as usersTable } from '@app/core/server';
// import { eq } from 'drizzle-orm';

// export const userRoutes = new Hono();

// // 1. ユーザー一覧取得
// userRoutes.get('/', async (c) => {
//     const userList = await db.select({
//         id: usersTable.id,
//         name: usersTable.name,
//         email: usersTable.email,
//         role: usersTable.role,
//         isActive: usersTable.isActive,
//         createdAt: usersTable.createdAt,
//     }).from(usersTable);

//     return c.json({ users: userList });
// });

// // 2. ロール変更
// const updateRoleSchema = z.object({
//     role: z.enum(['user', 'admin']),
// });

// userRoutes.patch(
//     '/:id/role',
//     zValidator('json', updateRoleSchema),
//     async (c) => {
//         const id = Number(c.req.param('id'));
//         const { role } = c.req.valid('json');

//         const updatedUsers = await db
//             .update(usersTable)
//             .set({ role })
//             .where(eq(usersTable.id, id))
//             .returning({
//                 id: usersTable.id,
//                 name: usersTable.name,
//                 email: usersTable.email,
//                 role: usersTable.role,
//                 isActive: usersTable.isActive,
//             });

//         if (updatedUsers.length === 0) {
//             return c.json({ message: 'User not found' }, 404);
//         }

//         return c.json({ user: updatedUsers[0] });
//     }
// );

// // 3. アカウント有効化/無効化
// const updateStatusSchema = z.object({
//     isActive: z.boolean(),
// });

// userRoutes.patch(
//     '/:id/status',
//     zValidator('json', updateStatusSchema),
//     async (c) => {
//         const id = Number(c.req.param('id'));
//         const { isActive } = c.req.valid('json');

//         const updatedUsers = await db
//             .update(usersTable)
//             .set({ isActive })
//             .where(eq(usersTable.id, id))
//             .returning({
//                 id: usersTable.id,
//                 name: usersTable.name,
//                 email: usersTable.email,
//                 role: usersTable.role,
//                 isActive: usersTable.isActive,
//             });

//         if (updatedUsers.length === 0) {
//             return c.json({ message: 'User not found' }, 404);
//         }

//         return c.json({ user: updatedUsers[0] });
//     }
// );
EOF_1787016562_28316

mkdir -p "packages/features/user-management/src/test"
echo "作成: packages/features/user-management/src/test/setup.ts"
cat << 'EOF_1787016562_24807' > "packages/features/user-management/src/test/setup.ts"
import '@testing-library/jest-dom';

// import { beforeEach } from 'vitest';
// import { db } from '@app/core/db';
// import { sql } from 'drizzle-orm';
// import '@testing-library/jest-dom';

// beforeEach(async () => {
//     // 全テーブルのデータをクリーンアップ（例: public スキーマ内の全テーブルを TRUNCATE）
//     await db.execute(sql`
//     DO $$ DECLARE
//         r RECORD;
//     BEGIN
//         FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
//             EXECUTE 'TRUNCATE TABLE ' || quote_ident(r.tablename) || ' CASCADE;';
//         END LOOP;
//     END $$;
//   `);
// });
EOF_1787016562_24807

mkdir -p "packages/features/user-management/src/test"
echo "作成: packages/features/user-management/src/test/global-setup.ts"
cat << 'EOF_1787016562_30058' > "packages/features/user-management/src/test/global-setup.ts"
import { execSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// import.meta.url から安全にパスを抽出
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function setup() {
    console.log('\n🔄 テスト用データベースに最新のスキーマを反映中...');

    // packages/core のルートディレクトリパスを解決
    const corePackageDir = path.resolve(__dirname, '../../../../core');
    const configPath = path.resolve(corePackageDir, 'drizzle-test.config.ts');

    try {
        execSync(`npx drizzle-kit push --config="${configPath}"`, {
            cwd: corePackageDir,
            stdio: 'inherit',
            env: {
                ...process.env, // 親プロセスの環境変数を引き継ぐ
            },
        });
        console.log('✅ テスト用データベースの準備完了!\n');
    } catch (error) {
        console.error('❌ テスト用データベースへのスキーマ反映に失敗しました:', error);
        throw error;
    }
}
EOF_1787016562_30058

mkdir -p "packages/features/user-management/src/components"
echo "作成: packages/features/user-management/src/components/UserManagementTable.test.tsx"
cat << 'EOF_1787016562_25058' > "packages/features/user-management/src/components/UserManagementTable.test.tsx"
import React from 'react';
import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { UserManagementTable } from './UserManagementTable';

// @app/ui のモック
vi.mock('@app/ui', () => ({
    toast: {
        success: vi.fn(),
        error: vi.fn(),
    },
    showErrorToast: vi.fn(),
}));

// @app/core のモック
vi.mock('@app/core', () => ({
    AUTH_TOKEN_KEY: 'test-auth-token',
}));

const globalFetch = vi.fn();
global.fetch = globalFetch;

describe('UserManagementTable Component', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    afterEach(() => {
        cleanup();
    });

    it('初期ロード時にユーザー一覧が取得され、正常に描画されること', async () => {
        const mockUsers = [
            {
                id: 1,
                name: 'テスト太郎',
                email: 'taro@example.com',
                role: 'user',
                isActive: true,
                createdAt: '2026-08-12T00:00:00Z',
            },
        ];

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: mockUsers }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        expect(screen.getByText('読み込み中...')).toBeInTheDocument();

        await waitFor(() => {
            expect(screen.getByText('テスト太郎')).toBeInTheDocument();
            expect(screen.getByText('taro@example.com')).toBeInTheDocument();
            expect(screen.getByText('有効')).toBeInTheDocument();
            expect(screen.getByRole('button', { name: '無効化する' })).toBeInTheDocument();
        });
    });

    it('ステータストグルボタンをクリックした際、PATCH リクエストが送信され表示が切り替わること', async () => {
        const mockUsers = [
            {
                id: 1,
                name: 'テスト太郎',
                email: 'taro@example.com',
                role: 'user',
                isActive: true,
                createdAt: '2026-08-12T00:00:00Z',
            },
        ];

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: mockUsers }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        await waitFor(() => {
            expect(screen.getByText('テスト太郎')).toBeInTheDocument();
        });

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({
                user: { ...mockUsers[0], isActive: false },
            }),
        });

        const toggleButton = screen.getByRole('button', { name: '無効化する' });
        fireEvent.click(toggleButton);

        await waitFor(() => {
            expect(globalFetch).toHaveBeenCalledWith(
                '/api/user-management/1/status',
                expect.objectContaining({
                    method: 'PATCH',
                    body: JSON.stringify({ isActive: false }),
                })
            );
        });

        await waitFor(() => {
            expect(screen.getByText('無効')).toBeInTheDocument();
            expect(screen.getByRole('button', { name: '有効化する' })).toBeInTheDocument();
        });
    });

    it('ロール変更セレクトを変更した際、PATCH リクエストが送信され表示が切り替わること', async () => {
        const mockUsers = [
            {
                id: 1,
                name: 'テスト太郎',
                email: 'taro@example.com',
                role: 'user' as const,
                isActive: true,
                createdAt: '2026-08-12T00:00:00Z',
            },
        ];

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: mockUsers }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        await waitFor(() => {
            expect(screen.getByText('テスト太郎')).toBeInTheDocument();
        });

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({
                user: { ...mockUsers[0], role: 'admin' },
            }),
        });

        const selectEl = screen.getByRole('combobox');
        fireEvent.change(selectEl, { target: { value: 'admin' } });

        await waitFor(() => {
            expect(globalFetch).toHaveBeenCalledWith(
                '/api/user-management/1/role',
                expect.objectContaining({
                    method: 'PATCH',
                    body: JSON.stringify({ role: 'admin' }),
                })
            );
        });

        await waitFor(() => {
            expect((selectEl as HTMLSelectElement).value).toBe('admin');
        });
    });

    it('「＋ ユーザー追加」ボタンでモーダルが開き、パスワードを指定して新規ユーザーをPOST登録できること', async () => {
        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: [] }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        await waitFor(() => {
            expect(screen.getByRole('button', { name: '＋ ユーザー追加' })).toBeInTheDocument();
        });

        fireEvent.click(screen.getByRole('button', { name: '＋ ユーザー追加' }));

        expect(screen.getByText('新規ユーザー追加')).toBeInTheDocument();

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({
                user: { id: 2, name: '新規ユーザー', email: 'new@example.com', role: 'user', isActive: true },
                initialPassword: 'password123',
            }),
        });

        fireEvent.change(screen.getByPlaceholderText('山田 太郎'), { target: { value: '新規ユーザー' } });
        fireEvent.change(screen.getByPlaceholderText('user@example.com'), { target: { value: 'new@example.com' } });
        fireEvent.change(screen.getByPlaceholderText('8文字以上（空欄可）'), { target: { value: 'password123' } });

        fireEvent.click(screen.getByRole('button', { name: '追加する' }));

        await waitFor(() => {
            expect(globalFetch).toHaveBeenCalledWith(
                '/api/user-management',
                expect.objectContaining({
                    method: 'POST',
                    body: JSON.stringify({
                        name: '新規ユーザー',
                        email: 'new@example.com',
                        role: 'user',
                        password: 'password123',
                    }),
                })
            );
        });

        await waitFor(() => {
            expect(screen.getByText('新規ユーザー')).toBeInTheDocument();
        });
    });

    it('削除ボタンをクリックした際、DELETE リクエストが送信され一覧から除外されること', async () => {
        vi.spyOn(window, 'confirm').mockReturnValue(true);

        const mockUsers = [
            {
                id: 1,
                name: '削除対象ユーザー',
                email: 'delete@example.com',
                role: 'user' as const,
                isActive: true,
            },
        ];

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ users: mockUsers }),
        });

        render(<UserManagementTable apiBaseUrl="/api/user-management" />);

        await waitFor(() => {
            expect(screen.getByText('削除対象ユーザー')).toBeInTheDocument();
        });

        globalFetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ message: 'ユーザーを削除しました' }),
        });

        fireEvent.click(screen.getByRole('button', { name: '削除' }));

        await waitFor(() => {
            expect(globalFetch).toHaveBeenCalledWith(
                '/api/user-management/1',
                expect.objectContaining({ method: 'DELETE' })
            );
        });

        await waitFor(() => {
            expect(screen.queryByText('削除対象ユーザー')).toBeNull();
        });
    });
});
EOF_1787016562_25058

mkdir -p "packages/features/user-management/src/components"
echo "作成: packages/features/user-management/src/components/CreateUserModal.tsx"
cat << 'EOF_1787016562_18762' > "packages/features/user-management/src/components/CreateUserModal.tsx"
import React, { useState } from 'react';

interface CreateUserModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (data: { name: string; email: string; role: 'user' | 'admin'; password?: string }) => Promise<void>;
}

export const CreateUserModal: React.FC<CreateUserModalProps> = ({ isOpen, onClose, onSubmit }) => {
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [role, setRole] = useState<'user' | 'admin'>('user');
    const [submitting, setSubmitting] = useState(false);
    const [error, setError] = useState<string | null>(null);

    if (!isOpen) return null;

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError(null);
        setSubmitting(true);

        try {
            await onSubmit({
                name,
                email,
                role,
                ...(password ? { password } : {}),
            });
            setName('');
            setEmail('');
            setPassword('');
            setRole('user');
            onClose();
        } catch (err: any) {
            setError(err.message || 'ユーザーの追加に失敗しました');
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-lg shadow-xl w-full max-w-md p-6">
                <h3 className="text-lg font-bold mb-4">新規ユーザー追加</h3>

                {error && (
                    <div className="mb-4 p-3 bg-red-50 text-red-700 text-sm rounded border border-red-200">
                        {error}
                    </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">名前</label>
                        <input
                            type="text"
                            required
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            className="w-full border rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                            placeholder="山田 太郎"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">メールアドレス</label>
                        <input
                            type="email"
                            required
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="w-full border rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                            placeholder="user@example.com"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                            パスワード <span className="text-xs text-gray-500 font-normal">（未入力時は自動生成）</span>
                        </label>
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="w-full border rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                            placeholder="8文字以上（空欄可）"
                            minLength={8}
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">権限 (Role)</label>
                        <select
                            value={role}
                            onChange={(e) => setRole(e.target.value as 'user' | 'admin')}
                            className="w-full border rounded px-3 py-2 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                        >
                            <option value="user">ユーザー (user)</option>
                            <option value="admin">管理者 (admin)</option>
                        </select>
                    </div>

                    <div className="flex justify-end gap-2 pt-4 border-t">
                        <button
                            type="button"
                            onClick={onClose}
                            disabled={submitting}
                            className="px-4 py-2 border rounded text-sm text-gray-600 hover:bg-gray-50 transition"
                        >
                            キャンセル
                        </button>
                        <button
                            type="submit"
                            disabled={submitting}
                            className="px-4 py-2 bg-blue-600 text-white rounded text-sm font-medium hover:bg-blue-700 disabled:opacity-50 transition"
                        >
                            {submitting ? '保存中...' : '追加する'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};
EOF_1787016562_18762

mkdir -p "packages/features/user-management/src/components"
echo "作成: packages/features/user-management/src/components/UserManagementTable.tsx"
cat << 'EOF_1787016562_9472' > "packages/features/user-management/src/components/UserManagementTable.tsx"
import React, { useEffect, useState } from 'react';
import { toast, showErrorToast } from '@app/ui';
import { CreateUserModal } from './CreateUserModal';
import { AUTH_TOKEN_KEY } from '@app/core';

export interface User {
    id: number;
    name: string;
    email: string;
    role: 'user' | 'admin';
    isActive: boolean;
    createdAt?: string;
}

interface UserManagementTableProps {
    apiBaseUrl?: string;
}

// 認証ヘッダーを取得するヘルパー関数 (AUTH_TOKEN_KEYを指定)
const getAuthHeaders = (): Record<string, string> => {
    const token = localStorage.getItem(AUTH_TOKEN_KEY);
    return {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
    };
};

export const UserManagementTable: React.FC<UserManagementTableProps> = ({
    apiBaseUrl = '/api/user-management',
}) => {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState<boolean>(true);
    const [error, setError] = useState<string | null>(null);
    const [isModalOpen, setIsModalOpen] = useState<boolean>(false);

    // 1. 一覧取得 (GET)
    const fetchUsers = async () => {
        try {
            setLoading(true);
            const res = await fetch(apiBaseUrl, {
                headers: getAuthHeaders(),
            });
            if (!res.ok) throw new Error('ユーザー情報の取得に失敗しました');
            const data = await res.json();
            setUsers(data.users);
            setError(null);
        } catch (err: any) {
            setError(err.message || 'エラーが発生しました');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchUsers();
    }, [apiBaseUrl]);

    // 2. 新規作成 (POST)
    const handleCreateUser = async (newUser: {
        name: string;
        email: string;
        role: 'user' | 'admin';
        password?: string;
    }) => {
        const res = await fetch(apiBaseUrl, {
            method: 'POST',
            headers: getAuthHeaders(),
            body: JSON.stringify(newUser),
        });

        const data = await res.json();

        if (!res.ok) {
            showErrorToast(data);
            throw new Error(data.detail || data.message || 'ユーザーの作成に失敗しました');
        }

        toast.success('ユーザーを追加しました', {
            description: `${data.user.name} を作成しました。初期パスワード: ${data.initialPassword}`,
        });

        setUsers((prev) => [...prev, data.user]);
    };

    // 3. ロール変更 (PATCH)
    const handleRoleChange = async (userId: number, newRole: 'user' | 'admin') => {
        try {
            const res = await fetch(`${apiBaseUrl}/${userId}/role`, {
                method: 'PATCH',
                headers: getAuthHeaders(),
                body: JSON.stringify({ role: newRole }),
            });

            const data = await res.json();
            if (!res.ok) throw new Error(data.detail || data.message || 'ロールの更新に失敗しました');

            setUsers((prev) =>
                prev.map((u) => (u.id === userId ? { ...u, role: data.user.role } : u))
            );
        } catch (err: any) {
            alert(err.message || '更新エラー');
        }
    };

    // 4. ステータス変更 (PATCH)
    const handleStatusToggle = async (userId: number, currentStatus: boolean) => {
        try {
            const res = await fetch(`${apiBaseUrl}/${userId}/status`, {
                method: 'PATCH',
                headers: getAuthHeaders(),
                body: JSON.stringify({ isActive: !currentStatus }),
            });

            const data = await res.json();
            if (!res.ok) throw new Error(data.detail || data.message || 'ステータスの更新に失敗しました');

            setUsers((prev) =>
                prev.map((u) => (u.id === userId ? { ...u, isActive: data.user.isActive } : u))
            );
        } catch (err: any) {
            alert(err.message || '更新エラー');
        }
    };

    // 5. 削除 (DELETE)
    const handleDeleteUser = async (userId: number) => {
        if (!confirm('本当にこのユーザーを削除しますか？')) return;

        try {
            const res = await fetch(`${apiBaseUrl}/${userId}`, {
                method: 'DELETE',
                headers: getAuthHeaders(),
            });

            const data = await res.json();
            if (!res.ok) {
                showErrorToast(data);
                return;
            }

            toast.success('ユーザーを削除しました');
            setUsers((prev) => prev.filter((u) => u.id !== userId));
        } catch (err: any) {
            toast.error(err.message || '削除エラーが発生しました');
        }
    };

    if (loading) return <div className="p-4">読み込み中...</div>;
    if (error) return <div className="p-4 text-red-500">エラー: {error}</div>;

    return (
        <div className="p-6 bg-white rounded-lg shadow-sm">
            <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-bold">ユーザー管理</h2>
                <button
                    onClick={() => setIsModalOpen(true)}
                    className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded hover:bg-blue-700 transition"
                >
                    ＋ ユーザー追加
                </button>
            </div>

            <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="border-b bg-gray-50 text-sm font-semibold text-gray-600">
                            <th className="p-3">ID</th>
                            <th className="p-3">名前</th>
                            <th className="p-3">メールアドレス</th>
                            <th className="p-3">権限 (Role)</th>
                            <th className="p-3">ステータス</th>
                            <th className="p-3">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        {users.map((user) => (
                            <tr key={user.id} className="border-b hover:bg-gray-50">
                                <td className="p-3 text-sm text-gray-500">{user.id}</td>
                                <td className="p-3 text-sm font-medium">{user.name}</td>
                                <td className="p-3 text-sm text-gray-600">{user.email}</td>
                                <td className="p-3 text-sm">
                                    <select
                                        value={user.role}
                                        onChange={(e) =>
                                            handleRoleChange(user.id, e.target.value as 'user' | 'admin')
                                        }
                                        className="border rounded px-2 py-1 text-sm bg-white"
                                    >
                                        <option value="user">ユーザー (user)</option>
                                        <option value="admin">管理者 (admin)</option>
                                    </select>
                                </td>
                                <td className="p-3 text-sm">
                                    <span
                                        className={`inline-block px-2 py-1 rounded text-xs font-semibold ${user.isActive
                                            ? 'bg-green-100 text-green-800'
                                            : 'bg-red-100 text-red-800'
                                            }`}
                                    >
                                        {user.isActive ? '有効' : '無効'}
                                    </span>
                                </td>
                                <td className="p-3 text-sm flex gap-2">
                                    <button
                                        onClick={() => handleStatusToggle(user.id, user.isActive)}
                                        className={`px-3 py-1 rounded text-xs text-white transition ${user.isActive
                                            ? 'bg-amber-500 hover:bg-amber-600'
                                            : 'bg-green-500 hover:bg-green-600'
                                            }`}
                                    >
                                        {user.isActive ? '無効化する' : '有効化する'}
                                    </button>
                                    <button
                                        onClick={() => handleDeleteUser(user.id)}
                                        className="px-3 py-1 bg-red-600 hover:bg-red-700 text-white text-xs rounded transition"
                                    >
                                        削除
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            <CreateUserModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onSubmit={handleCreateUser}
            />
        </div>
    );
};
EOF_1787016562_9472

echo "作成: plan-step9.md"
cat << 'EOF_1787016562_14571' > "plan-step9.md"
# 📌 Step 9: ユーザー管理機能（管理者用基盤）状況整理（最新版）

### 🎯 Step 9 のゴール

1. 管理者ロール（`admin`）を持つユーザーがログインした際、ナビゲーションから「ユーザー管理」画面にアクセスできる。
2. バックエンド API（`/api/user-management`）からユーザー一覧データを取得し、フロントエンド（`apps/web`）および独立パッケージ（`packages/features/user-management`）のテーブルコンポーネントで表示・編集・削除・ロール変更・無効化等の操作ができる。
3. 権限がない場合や直接アクセス時に適切な 403 権限エラー画面（`ForbiddenPage`）へ遷移・描画できる。

---

## 🚦 現在の進捗ステータス

| レイヤー / タスク | 内容 | ステータス | 詳細・通過内容 |
| --- | --- | --- | --- |
| **API (`apps/api`)** | `user-management.ts` の実装 | ✅ **完了** | `/api/user-management`（一覧・更新・削除・ステータス変更等）の定義および RBAC (403 制御) ミドルウェアの単体・結合テスト完了。 |
| **UI (`packages/ui`)** | Layout & `SidebarNav` 修正 | ✅ **完了** | `onClick` イベント属性の追加、コンポーネント構造（エントリポイント）の整理完了。 |
| **Feature (`packages/features/user-management`)** | テーブル UI コンポーネント | ✅ **完了** | 一覧表示、ロール変更（`admin` / `user`）、無効化・削除ボタン、ユーザー追加機能等のUIコンポーネント分離・実装完了。 |
| **Web (`apps/web`)** | Navigation & タブ切り替え / エラー制御 | ✅ **完了** | `role: 'admin'` 検出時の「ユーザー管理」表示、`currentTab` 状態遷移、および 403 権限エラー画面（`ForbiddenPage`）の描画ロジックとテスト通過。 |
| **結合連携 (`Web ↔ API`)** | API クライアント連携 & データ描画 | ✅ **完了** | `apiClient` 経由でのユーザー一覧取得・操作連動、全ビルド・型チェックおよび Vitest 単体/統合テスト全通過（Green）。 |

---

## 📝 これまでの完了内容 (Green 達成事項)

1. **バックエンド API & RBAC 認可処理**
* `/api/user-management` エンドポイントの実装完了。管理者以外のアクセスに対する 403 Forbidden 返却処理の動作検証済み。


2. **フロントエンド側の動的ナビゲーション & モジュール分離**
* `apps/web/src/App.tsx` にて `user.role === 'admin'` に応じて「ユーザー管理」メニュー項目を追加。
* テーブルコンポーネントを `packages/features/user-management` へパッケージ分離し、モジュール間の境界を定義。


3. **コンポーネント間のイベントハンドリング & 画面操作**
* `SidebarNav` に `onClick` ハンドラを適用し、SPA 内でのタブ切り替えイベントを正しくトリガーできるように修正。
* ロール変更ドロップダウン、無効化・削除ボタン、ユーザー追加モーダル等の UI 操作ロジックを実装完了。


4. **権限エラー画面 (403 Forbidden) の実装**
* `ForbiddenPage` コンポーネントおよび「ダッシュボードへ戻る」インタラクションを実装。
* 文字列部分一致テスト（`getByText(/.../)`）を含め、Vitest の単体テスト全 88 件が **Green** で通過。


5. **ビルド & 全テスト検証**
* `npm run build` による型チェック（`tsc`）通過および全体のモジュールツリーの正常性を確認。



---

## ⏭️ これから行う作業（次のアクション）

Step 9（ユーザー管理および認可基盤）が完了したため、次の機能拡張へ進みます。

1. **拡張候補機能（Step 10 以降）の選定・設計**
* **候補 A (汎用 UI):** データテーブルコンポーネント（検索・ソート・ページネーション）、汎用モーダル・ダイアログの抽象化基盤。
* **候補 B (エラー・認証):** 自動ログアウト処理（401 トークン切れ検知）や標準エラー画面 (404 / 500) の作成。
* **候補 C (その他):** 監査ログ (Audit Log) の記録基盤やシステム内通知基盤。
EOF_1787016562_14571

echo "作成: doc.md"
cat << 'EOF_1787016562_32672' > "doc.md"
## 🏗️ 構成の概要

このひな形は、**VS Code DevContainer + Docker Compose + Node.js (npm workspaces)** を採用したフルスタック・モノレポ構成です。

フロントエンド（React / Vite）とバックエンド（Hono / Node.js）を隔離されたコンテナ環境上で動作させ、DB（PostgreSQL）や共有パッケージ（認証プラグイン・Coreライブラリ）との統合開発がスムーズに行える設計になっています。

---

## 📂 ディレクトリ構成

```text
.
├── .devcontainer/
│   ├── devcontainer.json   # VS Code の DevContainer 接続・初期化設定
│   ├── docker-compose.yml  # コンテナ構成（アプリ用・DB用）
│   └── Dockerfile          # アプリ用開発コンテナのビルド定義
├── apps/
│   ├── api/                # [バックエンド] Hono API サーバー
│   └── web/                # [フロントエンド] React + Vite SPA
├── packages/
│   ├── core/               # 共通コア（DBクライアント、認証レジストリ、動的ローダー等）
│   ├── features/           # 機能モジュール (プラグイン型機能API)
│   │   └── sample/         # サンプル機能モジュール & Vitest テスト
│   └── plugins/            # 認証などの各種プラグイン
│       ├── auth-local/     # ローカルユーザー認証プラグイン
│       └── auth-ad/        # Active Directory 認証プラグイン
├── package.json            # ルートの npm workspaces 定義・統合スクリプト
├── tsconfig.json           # モノレポ全体の基本 TypeScript 設定
└── vitest.config.ts        # モノレポ全体のユニットテスト設定

```

---

## ⚙️ 各コンポーネントの仕様詳細

### 1. 🐳 DevContainer & Docker 構成

* **Dockerfile:**
* ベースイメージ: `[mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm](https://mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm)`
* 作業ディレクトリ: `/workspace`
* `node` ユーザーの `sudo` 権限確保（パスワードレス）


* **docker-compose.yml:**
* **`app` サービス (Node.js):**
* 各パッケージ（`node_modules`）をホスト環境から分離（匿名ボリューム化）し、Linux/Windows間での権限衝突やパーミッションエラー（`EACCES`）を回避。
* ポート公開: `3000` (Web UI), `3001` (API)


* **`db` サービス (PostgreSQL):**
* `postgres:15-alpine` を使用。データを永続化ボリューム（`postgres-data`）に保持。




* **devcontainer.json:**
* コンテナ起動時に `sudo chown -R node:node /workspace && npm install` を自動実行し、ファイル権限の正常化と依存関係のインストールを一括処理。
* **拡張機能自動適用:** ESLint, Prettier, Prisma, Vitest Explorer をプリセット。



---

### 2. 📘 TypeScript & パス解決の仕様

* **`.ts` 直接インポート対応:**
* `"allowImportingTsExtensions": true` および `"noEmit": true` を有効化。
* 明示的に `.ts` 拡張子を書いて `import` する運用をサポート。


* **エイリアスパス (`paths`):**
* `@app/core/*` ➡ `packages/core/src/*`
* `@app/plugins/*` ➡ `packages/plugins/*`
* `@app/features/*` ➡ `packages/features/*`
* Vite (`vite-tsconfig-paths`) および Vitest 側でも上記エイリアスを透過的に解決。



---

### 3. 🔌 アーキテクチャ＆拡張パターン

#### ① 認証プラグイン機構 (`packages/core/src/auth` & `packages/plugins/`)

* `AuthRegistry`（レジストリクラス）を共通コアに配置。
* `LocalAuthPlugin` や `ActiveDirectoryAuthPlugin` などを動的に登録し、環境変数（`AUTH_STRATEGY`）等に応じて認証ロジックを切り替え可能。

#### ② 機能モジュールの自動動的ローディング (`packages/core/src/registry/`)

* `glob` と `import()` を組み合わせた `loadFeatureModules` 関数を搭載。
* `packages/features/*/src/index.ts` 配下にある機能モジュールを検索し、API サーバー (`apps/api`) の起動時にルーティングへ自動組込み。

---

### 4. 🌐 アプリケーション & プロキシ

* **フロントエンド (`apps/web`):**
* Vite + React 構成。
* `vite.config.ts` にて、`/api` および `/sample` へのリクエストをバックエンド (`[http://127.0.0.1:3001](http://127.0.0.1:3001)`) にプロキシ。


* **バックエンド (`apps/api`):**
* Hono (`@hono/node-server`) で動作。
* `tsx watch` により、コード変更時に即座にホットリロード。



---

### 5. 🧪 テスト & 開発コマンド

* **`npm run dev`:** `concurrently` を使い、API サーバーと Web アプリを並列起動。
* **`npm test`:** ルートから全パッケージのテスト（`Vitest`）をまとめて一括実行。
EOF_1787016562_32672

mkdir -p "test"
echo "作成: test/setup.ts"
cat << 'EOF_1787016562_8149' > "test/setup.ts"
import { beforeEach } from 'vitest';
import { db } from '@app/core/server'; // テスト用DBに接続しているDrizzleインスタンス
import { sql } from 'drizzle-orm';

beforeEach(async () => {
    // 全テーブルのデータをクリーンアップ（例: public スキーマ内の全テーブルを TRUNCATE）
    await db.execute(sql`
    DO $$ DECLARE
        r RECORD;
    BEGIN
        FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
            EXECUTE 'TRUNCATE TABLE ' || quote_ident(r.tablename) || ' CASCADE;';
        END LOOP;
    END $$;
  `);
});
EOF_1787016562_8149

mkdir -p "test"
echo "作成: test/global-setup.ts"
cat << 'EOF_1787016562_6710' > "test/global-setup.ts"
import { execSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// import.meta.url から安全にパスを抽出
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function setup() {
    console.log('\n🔄 テスト用データベースに最新のスキーマを反映中...');

    // packages/core のルートディレクトリパスを解決
    const corePackageDir = path.resolve(__dirname, '../../../../core');
    const configPath = path.resolve(corePackageDir, 'drizzle-test.config.ts');

    try {
        execSync(`npx drizzle-kit push --config="${configPath}"`, {
            cwd: corePackageDir,
            stdio: 'inherit',
            env: {
                ...process.env, // 親プロセスの環境変数を引き継ぐ
            },
        });
        console.log('✅ テスト用データベースの準備完了!\n');
    } catch (error) {
        console.error('❌ テスト用データベースへのスキーマ反映に失敗しました:', error);
        throw error;
    }
}
EOF_1787016562_6710

echo "作成: SUMMRY.md"
cat << 'EOF_1787016562_31496' > "SUMMRY.md"
これまでに作成・整理してきたすべての設計と実装内容を集約した「全体版システム仕様書 (Full Specification Document)」を作成しました。
# 📘 マイアプリケーション 全体システム仕様書 (Full System Specification)

---

## 1. プロジェクト概要 & アーキテクチャ原則

本プロジェクトは、堅牢かつ拡張性の高いモダンな Web アプリケーション基盤です。テスト駆動開発 (TDD) をベースとし、ドメイン分離・統一エラーハンドリング・安全な認証機構を備えています。

### 1.1 主な技術スタック

* **Frontend:** React (Vite / SPA)
* **Backend:** Hono (TypeScript Web Framework)
* **Database & ORM:** PostgreSQL + Drizzle ORM
* **Authentication:** Local JWT (`jose`) + Bcrypt (`bcryptjs`)
* **Testing:** Vitest

### 1.2 アーキテクチャ方針

* **モノレポ構成 (pnpm/npm Workspaces):**
`apps/`（アプリケーション層）と `packages/`（共通ライブラリ層）を分離し、コードの再利用性と独立性を維持します。
* **RFC 7807 準拠のエラー表現:**
API のすべてのエラーレスポンスは `Problem Details for HTTP APIs (RFC 7807)` 形式で統一します。
* **テスト駆動開発 (TDD):**
ロジックおよび API エンドポイントの実装時は「Red (テスト作成) → Green (実装) → Refactor (リファクタリング)」のサイクルを徹底します。

---

## 2. ディレクトリ構造 & モジュール責務

```
.
├── apps/
│   ├── api/                     # Hono サーバーアプリケーション
│   │   ├── src/
│   │   │   ├── middlewares/     # 認証・共通ミドルウェア
│   │   │   │   ├── auth-middleware.ts
│   │   │   │   └── auth-middleware.test.ts
│   │   │   ├── routes/          # API ルーター
│   │   │   │   ├── auth.ts
│   │   │   │   └── auth.test.ts
│   │   │   └── index.ts
│   └── web/                     # React フロントエンド (SPA)
└── packages/
    ├── core/                    # ドメイン共通ロジック & DB 接続
    │   ├── src/
    │   │   ├── errors/          # RFC 7807 エラー定義 (AppError等)
    │   │   ├── db/              # Drizzle ORM スキーマ & クライアント
    │   │   └── index.ts
    └── auth-local/              # 認証関連の純粋ユーティリティ
        ├── src/
        │   ├── password.ts      # Bcrypt ハッシュ化・照合
        │   └── jwt.ts           # JWT 署名・検証
        └── index.ts

```

---

## 3. データベース仕様 (Database Schema)

### `users` テーブル

ユーザー認証、権限、およびプロファイル情報を一元管理します。

```typescript
// packages/core/src/db/schema.ts
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  role: text('role').notNull().default('user'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

```

| カラム名 | DB論理名 | 型 | 制約 | 説明 |
| --- | --- | --- | --- | --- |
| `id` | `id` | `serial` | PRIMARY KEY | ユーザー識別子 |
| `name` | `name` | `text` | NOT NULL | ユーザー表示名 |
| `email` | `email` | `text` | NOT NULL, UNIQUE | メールアドレス（ログインID） |
| `passwordHash` | `password_hash` | `text` | NOT NULL | Bcrypt でハッシュ化されたパスワード |
| `role` | `role` | `text` | NOT NULL, Default: `'user'` | システム権限 (`user`, `admin` 等) |
| `createdAt` | `created_at` | `timestamp` | NOT NULL, Default: `now()` | レコード作成日時 |

---

## 4. エラーハンドリング仕様 (RFC 7807)

システム内で発生する例外はすべて `@app/core` の `AppError` クラスを継承し、Hono の `app.onError` でキャッチして以下の JSON 形式に変換されます。

### エラーレスポンス基本構造

```json
{
  "type": "about:blank",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Authentication token is missing or invalid format.",
  "instance": "/api/auth/me"
}

```

### 定義済み例外クラス一覧

* **`AppError`**: 基底例外クラス（`status`, `code`, `title` を保持）
* **`ValidationError`** (400 Bad Request): 入力バリデーション失敗時
* **`UnauthorizedError`** (401 Unauthorized): 認証失敗・トークン無効時
* **`NotFoundError`** (404 Not Found): リソースが存在しない場合
* **`InternalServerError`** (500 Internal Server Error): 予期せぬシステム例外

---

## 5. API エンドポイント詳細仕様 (API Specification)

ベース URL: `/api`

### 5.1. ログイン & トークン発行

* **エンドポイント:** `POST /api/auth/login`
* **認証:** 不要
* **概要:** メールアドレスとパスワードを照合し、成功時に JWT を返却します。

#### リクエストボディ (`application/json`)

```json
{
  "email": "test@example.com",
  "password": "password123"
}

```

#### レスポンス (200 OK)

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "Test User",
    "email": "test@example.com",
    "role": "user"
  }
}

```

#### エラーレスポンス (401 Unauthorized)

```json
{
  "type": "about:blank",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Invalid credentials.",
  "instance": "/api/auth/login"
}

```

---

### 5.2. ログインユーザー情報取得

* **エンドポイント:** `GET /api/auth/me`
* **認証:** 必要 (`Authorization: Bearer <JWT>`)
* **概要:** JWT トークンを検証し、現在ログイン中のユーザー情報を取得します。

#### リクエストヘッダー

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

```

#### レスポンス (200 OK)

```json
{
  "user": {
    "id": 1,
    "email": "test@example.com",
    "role": "user"
  }
}

```

#### エラーレスポンス (401 Unauthorized)

```json
{
  "type": "about:blank",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Token is invalid or expired.",
  "instance": "/api/auth/me"
}

```

---

## 6. 認証・認可フロー & セキュリティ設計

### 6.1. 認証フロー図

```
[Client (React)]                  [API Route (/login)]            [Auth Local / DB]
       │                                  │                               │
       │── 1. POST /login ───────────────>│                               │
       │   (email, password)              │── 2. Select User by Email ───>│
       │                                  │<── User Record & Hash ────────│
       │                                  │                               │
       │                                  │── 3. Verify Password ────────>│ (bcrypt.compare)
       │                                  │── 4. Sign JWT Payload ───────>│ (jose)
       │<── 5. Token & User Data ─────────│                               │
       │                                  │                               │
       │                                  │                               │
[Client (React)]                  [Auth Middleware]              [Protected Route]
       │                                  │                               │
       │── 6. GET /me (Bearer Token) ────>│                               │
       │                                  │── 7. Verify JWT ─────────────>│
       │                                  │── 8. Set c.set('user', payload)│
       │                                  │── 9. next() ─────────────────>│
       │<── 10. User Profile ─────────────│───────────────────────────────│

```

### 6.2. セキュリティガイドライン

1. **パスワードの平文保持禁止:**
`bcryptjs` を用いて適切なコストパラメータ（ソルト）でハッシュ化された値のみを保存。
2. **無状態 (Stateless) な認証:**
署名された JWT トークンを使用し、サーバーセッションを持たずにスケーラブルに検証。
3. **安全なエラーメッセージ:**
ログイン失敗時は「ユーザーが存在しない」のか「パスワードが違う」のかを区別させず、共通して `Invalid credentials.` と返却（ユーザー存在確認攻撃の防止）。

---

## 7. 実装済みテストケース一覧

全モジュールでユニットテスト / 統合テストが整備されており、`npm test` で一括実行可能です。

* **`packages/auth-local`**
* パスワードの正常ハッシュ化および一致・不一致の判定テスト
* JWT の生成・正確なペロード抽出・期限切れ/無効署名トークンの検証テスト


* **`apps/api/src/middlewares/auth-middleware.test.ts`**
* `Authorization` ヘッダー欠落時の 401 エラー（RFC 7807 形式）テスト
* 不正トークン送信時の 401 エラーテスト
* 正しい Bearer トークン受信時にコンテキストへ `user` 情報が正常設定されるテスト


* **`apps/api/src/routes/auth.test.ts`**
* `POST /login`: 正しい資格情報でのトークン返却テスト / 誤ったパスワードでの 401 テスト
* `GET /me`: 発行された JWT を用いたプロファイル正常取得テスト



---
EOF_1787016562_31496

mkdir -p "apps/web"
echo "作成: apps/web/package.json"
cat << 'EOF_1787016562_11548' > "apps/web/package.json"
{
  "name": "@app/web",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build"
  },
  "dependencies": {
    "@app/ui": "*",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@tailwindcss/vite": "^4.0.0",
    "@testing-library/jest-dom": "^6.9.1",
    "@testing-library/react": "^16.3.2",
    "@types/react": "^18.2.55",
    "@types/react-dom": "^18.2.19",
    "@vitejs/plugin-react": "^6.0.5",
    "jsdom": "^29.1.1",
    "tailwindcss": "^4.0.0",
    "typescript": "^5.3.3"
  }
}
EOF_1787016562_11548

mkdir -p "apps/web"
echo "作成: apps/web/index.html"
cat << 'EOF_1787016562_929' > "apps/web/index.html"
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="UTF-8" />
    <title>DevContainer Vite App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF_1787016562_929

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.json"
cat << 'EOF_1787016562_14649' > "apps/web/tsconfig.json"
{
    "extends": "../../tsconfig.json",
    "compilerOptions": {
        "jsx": "react-jsx",
        "lib": [
            "ES2022",
            "DOM",
            "DOM.Iterable"
        ],
        "types": [
            "vite/client",
            "@testing-library/jest-dom"
        ]
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1787016562_14649

mkdir -p "apps/web"
echo "作成: apps/web/vitest.config.ts"
cat << 'EOF_1787016562_16899' > "apps/web/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
        alias: {
            // エイリアスを直接指定
            '@app/ui': path.resolve(import.meta.dirname, '../../packages/ui/src'),
            '@app/features/user-management': path.resolve(import.meta.dirname, '../../packages/features/user-management/src'),
        },
    },
    test: {
        globals: true,
        environment: 'jsdom',
        setupFiles: ['./src/test/setup.ts'],
    },
});
EOF_1787016562_16899

mkdir -p "apps/web/src"
echo "作成: apps/web/src/index.css"
cat << 'EOF_1787016563_15109' > "apps/web/src/index.css"
@import "tailwindcss";

/* モノレポ内の共有 UI パッケージも Tailwind のスキャン対象に指定 */
@source "../../../packages/ui/src";
EOF_1787016563_15109

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.test.tsx"
cat << 'EOF_1787016563_16178' > "apps/web/src/App.test.tsx"
import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import React from 'react';
import { App } from './App';

// useAuth のモック設定
const mockUseAuth = vi.fn();

vi.mock('./context/AuthContext', () => ({
    AuthProvider: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
    useAuth: () => mockUseAuth(),
}));

// ProtectedRoute のモック（認証チェックをスルー）
vi.mock('./components/ProtectedRoute', () => ({
    ProtectedRoute: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
}));

// UserManagementTable のモック化（インポート元パスを App.tsx と一致させる）
vi.mock('@app/features-user-management/ui', () => ({
    UserManagementTable: () => <div data-testid="user-management-table">ユーザー管理テーブル画面</div>,
}));

// @app/core/config/env の部分モック
vi.mock('@app/core/config/env', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@app/core/config/env')>();
    return {
        ...actual,
        clientEnv: {
            ...actual.clientEnv,
            VITE_APP_TITLE: 'テストアプリ',
        },
    };
});

// fetch のモック
const globalFetch = vi.fn();
(globalThis as any).fetch = globalFetch;

describe('App Component (User Management Integration)', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    afterEach(() => {
        cleanup();
    });

    it('admin ユーザーの場合、サイドナビに「ユーザー管理」が表示され、クリックすると管理画面に切り替わること', async () => {
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'admin@example.com', role: 'admin' },
            logout: vi.fn(),
        });

        render(<App />);

        // ダッシュボード見出し（h2）の初期表示確認
        expect(screen.getByRole('heading', { name: 'ダッシュボード' })).toBeDefined();

        // admin のためサイドナビに「ユーザー管理」リンクが存在すること
        const userMgmtNav = screen.getByRole('link', { name: 'ユーザー管理' });
        expect(userMgmtNav).toBeDefined();

        // クリックしてユーザー管理画面を表示
        fireEvent.click(userMgmtNav);

        await waitFor(() => {
            expect(screen.getByTestId('user-management-table')).toBeDefined();
        });
    });

    it('user（一般権限）ユーザーの場合、サイドナビに「ユーザー管理」が表示されないこと', () => {
        mockUseAuth.mockReturnValue({
            user: { id: 2, email: 'user@example.com', role: 'user' },
            logout: vi.fn(),
        });

        render(<App />);

        expect(screen.queryByRole('link', { name: 'ユーザー管理' })).toBeNull();
    });
});


// import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
// import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
// import React from 'react';
// import { App } from './App';

// // useAuth のモック設定
// const mockUseAuth = vi.fn();

// vi.mock('./context/AuthContext', () => ({
//     AuthProvider: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
//     useAuth: () => mockUseAuth(),
// }));

// // ProtectedRoute のモック（認証チェックをスルー）
// vi.mock('./components/ProtectedRoute', () => ({
//     ProtectedRoute: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
// }));

// // UserManagementTable のモック化（表示確認用）
// vi.mock('@app/features/user-management', () => ({
//     UserManagementTable: () => <div data-testid="user-management-table">ユーザー管理テーブル画面</div>,
// }));

// // @app/core/config/env の部分モック
// vi.mock('@app/core/config/env', async (importOriginal) => {
//     const actual = await importOriginal<typeof import('@app/core/config/env')>();
//     return {
//         ...actual,
//         clientEnv: {
//             ...actual.clientEnv,
//             VITE_APP_TITLE: 'テストアプリ',
//         },
//     };
// });

// // fetch のモック
// const globalFetch = vi.fn();
// global.fetch = globalFetch;

// describe('App Component (User Management Integration)', () => {
//     beforeEach(() => {
//         vi.clearAllMocks();
//     });

//     afterEach(() => {
//         cleanup();
//     });

//     it('admin ユーザーの場合、サイドナビに「ユーザー管理」が表示され、クリックすると管理画面に切り替わること', async () => {
//         mockUseAuth.mockReturnValue({
//             user: { id: 1, email: 'admin@example.com', role: 'admin' },
//             logout: vi.fn(),
//         });

//         render(<App />);

//         // ダッシュボード見出し（h2）の初期表示確認
//         expect(screen.getByRole('heading', { name: 'ダッシュボード' })).toBeDefined();

//         // admin のためサイドナビに「ユーザー管理」リンクが存在すること
//         const userMgmtNav = screen.getByRole('link', { name: 'ユーザー管理' });
//         expect(userMgmtNav).toBeDefined();

//         // クリックしてユーザー管理画面を表示
//         fireEvent.click(userMgmtNav);

//         await waitFor(() => {
//             expect(screen.getByTestId('user-management-table')).toBeDefined();
//         });
//     });

//     it('user（一般権限）ユーザーの場合、サイドナビに「ユーザー管理」が表示されないこと', () => {
//         mockUseAuth.mockReturnValue({
//             user: { id: 2, email: 'user@example.com', role: 'user' },
//             logout: vi.fn(),
//         });

//         render(<App />);

//         expect(screen.queryByRole('link', { name: 'ユーザー管理' })).toBeNull();
//     });
// });
EOF_1787016563_16178

mkdir -p "apps/web/src/test"
echo "作成: apps/web/src/test/setup.ts"
cat << 'EOF_1787016563_6099' > "apps/web/src/test/setup.ts"
import '@testing-library/jest-dom';
EOF_1787016563_6099

mkdir -p "apps/web/src"
echo "作成: apps/web/src/main.tsx"
cat << 'EOF_1787016563_19002' > "apps/web/src/main.tsx"
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF_1787016563_19002

mkdir -p "apps/web/src"
echo "作成: apps/web/src/env.test.ts"
cat << 'EOF_1787016563_5837' > "apps/web/src/env.test.ts"
import { describe, it, expect } from 'vitest';
import { clientEnv } from '@app/ui';

describe('Web Environment Variables (Pattern A)', () => {
    it('packages/core の clientEnv から正しく設定値および動的補完値が取得できること', () => {
        // VITE_APP_TITLE の検証
        expect(clientEnv.VITE_APP_TITLE).toBeDefined();
        expect(typeof clientEnv.VITE_APP_TITLE).toBe('string');

        // VITE_PORT の検証
        expect(typeof clientEnv.VITE_PORT).toBe('number');

        // VITE_API_TARGET_URL の動的補完検証
        expect(clientEnv.VITE_API_TARGET_URL).toBeDefined();
        expect(clientEnv.VITE_API_TARGET_URL).toMatch(/^http/);
    });
});
EOF_1787016563_5837

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.test.tsx"
cat << 'EOF_1787016563_27471' > "apps/web/src/context/AuthContext.test.tsx"
import { renderHook, act, waitFor } from '@testing-library/react';
import { describe, it, expect, beforeEach, vi, Mock } from 'vitest';
import { AuthProvider, useAuth } from './AuthContext';
import React from 'react';
import { apiClient, getStoredToken, setStoredToken, removeStoredToken } from '../lib/apiClient';

// apiClient のモック設定
// vi.mock('../lib/apiClient', () => ({
//     apiClient: {
//         get: vi.fn(),
//         post: vi.fn(),
//     },
//     getStoredToken: vi.fn(),
//     setStoredToken: vi.fn(),
//     removeStoredToken: vi.fn(),
// }));
// 実際の ApiError クラスをそのままモックへ引き継ぐ場合
vi.mock('../lib/apiClient', async (importOriginal) => {
    const actual = await importOriginal<typeof import('../lib/apiClient')>();
    return {
        ...actual,
        apiClient: {
            get: vi.fn(),
            post: vi.fn(),
        },
        getStoredToken: vi.fn(),
        setStoredToken: vi.fn(),
        removeStoredToken: vi.fn(),
    };
});

describe('AuthContext / useAuth (Step 7 修正版)', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
    );

    it('初期状態（トークンなし）: user/token 共に null で未認証状態であること', async () => {
        (getStoredToken as Mock).mockReturnValue(null);

        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isLoading).toBe(false);
        });

        expect(result.current.isAuthenticated).toBe(false);
        expect(result.current.user).toBeNull();
        expect(result.current.token).toBeNull();
    });

    it('初期状態（トークンあり）: /api/auth/me からユーザー情報を取得し認証状態を復元すること', async () => {
        const mockUser = { id: 1, name: 'Test User', email: 'test@example.com', role: 'user' };
        (getStoredToken as Mock).mockReturnValue('existing-token');
        (apiClient.get as Mock).mockResolvedValueOnce({ user: mockUser });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isLoading).toBe(false);
        });

        expect(apiClient.get).toHaveBeenCalledWith('/api/auth/me');
        expect(result.current.isAuthenticated).toBe(true);
        expect(result.current.user).toEqual(mockUser);
        expect(result.current.token).toBe('existing-token');
    });

    it('login: /api/auth/login を呼び出し、トークンとユーザー情報を保持すること', async () => {
        const mockUser = { id: 1, name: 'Test User', email: 'test@example.com', role: 'user' };
        const mockToken = 'mock-jwt-token';

        (apiClient.post as Mock).mockResolvedValueOnce({ token: mockToken, user: mockUser });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await act(async () => {
            await result.current.login('test@example.com', 'password123');
        });

        expect(apiClient.post).toHaveBeenCalledWith('/api/auth/login', {
            email: 'test@example.com',
            password: 'password123',
        });
        expect(setStoredToken).toHaveBeenCalledWith(mockToken);
        expect(result.current.isAuthenticated).toBe(true);
        expect(result.current.user).toEqual(mockUser);
        expect(result.current.token).toBe(mockToken);
    });

    it('logout: トークンとユーザー情報が破棄されること', async () => {
        const mockUser = { id: 1, name: 'Test User', email: 'test@example.com', role: 'user' };
        (getStoredToken as Mock).mockReturnValue('existing-token');
        (apiClient.get as Mock).mockResolvedValueOnce({ user: mockUser });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isAuthenticated).toBe(true);
        });

        act(() => {
            result.current.logout();
        });

        expect(removeStoredToken).toHaveBeenCalled();
        expect(result.current.isAuthenticated).toBe(false);
        expect(result.current.user).toBeNull();
        expect(result.current.token).toBeNull();
    });
});
EOF_1787016563_27471

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.tsx"
cat << 'EOF_1787016563_27320' > "apps/web/src/context/AuthContext.tsx"
import React, { createContext, useContext, useState, useEffect } from 'react';
import { apiClient, getStoredToken, setStoredToken, removeStoredToken, ApiError } from '../lib/apiClient';

// ユーザーオブジェクトの型定義
export interface User {
    id: number | string;
    name?: string;
    email: string;
    role: string;
}

// AuthContext の型定義
export interface AuthContextType {
    user: User | null;
    token: string | null;
    isLoading: boolean;
    isAuthenticated: boolean;
    login: (email: string, password: string) => Promise<void>;
    logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [user, setUser] = useState<User | null>(null);
    const [token, setToken] = useState<string | null>(() => getStoredToken());
    const [isLoading, setIsLoading] = useState<boolean>(true);

    // 初期化時：localStorage にトークンがあれば /api/auth/me でユーザー情報を復元
    useEffect(() => {
        const initAuth = async () => {
            const storedToken = getStoredToken();
            if (!storedToken) {
                setIsLoading(false);
                return;
            }

            try {
                const data = await apiClient.get<{ user: User }>('/api/auth/me');
                setUser(data.user);
                setToken(storedToken);
            } catch (error) {
                // 401/403 エラー（トークン無効・期限切れ）は一般的な未ログイン状態のため、静かにクリア
                const isUnauthorized = error instanceof ApiError && (error.status === 401 || error.status === 403);

                if (!isUnauthorized) {
                    // サーバー障害(500系)やネットワークエラー等のみログを出力
                    console.warn('Authentication restore failed due to network or server error:', error);
                }

                removeStoredToken();
                setToken(null);
                setUser(null);
            } finally {
                setIsLoading(false);
            }
        };

        initAuth();
    }, []);

    // ログイン処理
    const login = async (email: string, password: string) => {
        const data = await apiClient.post<{ token: string; user: User }>('/api/auth/login', {
            email,
            password,
        });

        setStoredToken(data.token);
        setToken(data.token);
        setUser(data.user);
    };

    // ログアウト処理
    const logout = () => {
        removeStoredToken();
        setToken(null);
        setUser(null);
    };

    return (
        <AuthContext.Provider
            value={{
                user,
                token,
                isLoading,
                isAuthenticated: !!user,
                login,
                logout,
            }}
        >
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = (): AuthContextType => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};

EOF_1787016563_27320

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/ProtectedRoute.test.tsx"
cat << 'EOF_1787016563_14510' > "apps/web/src/components/ProtectedRoute.test.tsx"
import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { ProtectedRoute } from './ProtectedRoute';
import * as AuthContextModule from '../context/AuthContext';

vi.mock('../context/AuthContext');

describe('ProtectedRoute', () => {
    it('ローディング中はローディングメッセージを表示する', () => {
        vi.spyOn(AuthContextModule, 'useAuth').mockReturnValue({
            user: null,
            token: null,
            isLoading: true,
            isAuthenticated: false,
            login: vi.fn(),
            logout: vi.fn(),
        });

        render(
            <ProtectedRoute>
                <div>Protected Content</div>
            </ProtectedRoute>
        );

        expect(screen.getByText('認証情報を確認中...')).toBeInTheDocument();
        expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    });

    it('未認証の場合はログインフォームを表示する', () => {
        vi.spyOn(AuthContextModule, 'useAuth').mockReturnValue({
            user: null,
            token: null,
            isLoading: false,
            isAuthenticated: false,
            login: vi.fn(),
            logout: vi.fn(),
        });

        render(
            <ProtectedRoute>
                <div>Protected Content</div>
            </ProtectedRoute>
        );

        expect(screen.getByRole('button', { name: /ログイン/i })).toBeInTheDocument();
        expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    });

    it('認証済みの場合は子要素を表示する', () => {
        vi.spyOn(AuthContextModule, 'useAuth').mockReturnValue({
            user: { id: 1, email: 'user@example.com', role: 'user' },
            token: 'valid-token',
            isLoading: false,
            isAuthenticated: true,
            login: vi.fn(),
            logout: vi.fn(),
        });

        render(
            <ProtectedRoute>
                <div>Protected Content</div>
            </ProtectedRoute>
        );

        expect(screen.getByText('Protected Content')).toBeInTheDocument();
    });
});
EOF_1787016563_14510

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/Header.tsx"
cat << 'EOF_1787016563_20393' > "apps/web/src/components/Header.tsx"
import { clientEnv } from '@app/ui';

export const Header = () => {
  return (
    <header>
      <h1>{clientEnv.VITE_APP_TITLE}</h1>
    </header>
  );
};
EOF_1787016563_20393

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/ForbiddenPage.test.tsx"
cat << 'EOF_1787016563_2389' > "apps/web/src/components/ForbiddenPage.test.tsx"
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { ForbiddenPage } from './ForbiddenPage';

describe('ForbiddenPage Component', () => {
    it('403 エラーメッセージとタイトルが正しく表示されること', () => {
        render(<ForbiddenPage onBackToDashboard={vi.fn()} />);

        expect(screen.getByText('403')).toBeInTheDocument();
        expect(screen.getByText('アクセス権限がありません')).toBeInTheDocument();
        expect(
            screen.getByText(/このページを閲覧・操作するための権限が付与されていません/)
        ).toBeInTheDocument();
    });

    it('「ダッシュボードへ戻る」ボタンを押すとコールバックが実行されること', () => {
        const handleBack = vi.fn();
        render(<ForbiddenPage onBackToDashboard={handleBack} />);

        const backButton = screen.getByRole('button', { name: 'ダッシュボードへ戻る' });
        fireEvent.click(backButton);

        expect(handleBack).toHaveBeenCalledTimes(1);
    });
});
EOF_1787016563_2389

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/ProtectedRoute.tsx"
cat << 'EOF_1787016563_23246' > "apps/web/src/components/ProtectedRoute.tsx"
import React from 'react';
import { useAuth } from '../context/AuthContext';
import { LoginForm } from './LoginForm';

interface ProtectedRouteProps {
    children: React.ReactNode;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
    const { user, isLoading } = useAuth();

    if (isLoading) {
        return (
            <div className="flex h-screen items-center justify-center">
                <p className="text-gray-500">認証情報を確認中...</p>
            </div>
        );
    }

    if (!user) {
        return (
            <div className="flex h-screen items-center justify-center bg-gray-50">
                <LoginForm />
            </div>
        );
    }

    return <>{children}</>;
};
EOF_1787016563_23246

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.tsx"
cat << 'EOF_1787016563_1984' > "apps/web/src/components/LoginForm.tsx"
import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';

interface LoginFormProps {
    onSuccess?: () => void;
}

export const LoginForm: React.FC<LoginFormProps> = ({ onSuccess }) => {
    const { login } = useAuth();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState<string | null>(null);
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError(null);
        setIsSubmitting(true);

        try {
            await login(email, password);
            if (onSuccess) {
                onSuccess();
            }
        } catch (err: any) {
            setError(err.message || 'ログインに失敗しました。');
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem', maxWidth: '300px' }}>
            <h2>ログイン</h2>
            {error && (
                <div role="alert" style={{ color: 'red', fontSize: '0.875rem' }}>
                    {error}
                </div>
            )}
            <div>
                <label htmlFor="email">メールアドレス</label>
                <input
                    id="email"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    disabled={isSubmitting}
                    style={{ width: '100%', padding: '0.5rem' }}
                />
            </div>
            <div>
                <label htmlFor="password">パスワード</label>
                <input
                    id="password"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    disabled={isSubmitting}
                    style={{ width: '100%', padding: '0.5rem' }}
                />
            </div>
            <button type="submit" disabled={isSubmitting} style={{ padding: '0.5rem 1rem', cursor: 'pointer' }}>
                {isSubmitting ? '送信中...' : 'ログイン'}
            </button>
        </form>
    );
};
EOF_1787016563_1984

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/ForbiddenPage.tsx"
cat << 'EOF_1787016563_17127' > "apps/web/src/components/ForbiddenPage.tsx"
import React from 'react';
import { Button } from '@app/ui';

interface ForbiddenPageProps {
    onBackToDashboard: () => void;
}

export const ForbiddenPage: React.FC<ForbiddenPageProps> = ({ onBackToDashboard }) => {
    return (
        <div className="flex min-h-[60vh] flex-col items-center justify-center text-center p-6">
            <div className="rounded-full bg-red-100 p-4 mb-4">
                <svg
                    className="h-12 w-12 text-red-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                >
                    <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                    />
                </svg>
            </div>

            <h1 className="text-4xl font-extrabold text-gray-900 mb-2">403</h1>
            <h2 className="text-xl font-semibold text-gray-800 mb-2">アクセス権限がありません</h2>
            <p className="text-sm text-gray-600 max-w-md mb-6">
                このページを閲覧・操作するための権限が付与されていません。管理者にお問い合わせいただくか、ダッシュボードへお戻りください。
            </p>

            <Button variant="default" onClick={onBackToDashboard}>
                ダッシュボードへ戻る
            </Button>
        </div>
    );
};
EOF_1787016563_17127

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.test.tsx"
cat << 'EOF_1787016563_8983' > "apps/web/src/components/LoginForm.test.tsx"
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import React from 'react';
import { LoginForm } from './LoginForm';
import { AuthContext, AuthContextType } from '../context/AuthContext';

describe('LoginForm Component (Step 5.2)', () => {
    const mockLogin = vi.fn();
    const mockLogout = vi.fn();

    const mockAuthContextValue: AuthContextType = {
        user: null,
        token: null,
        isLoading: false,
        isAuthenticated: false,
        login: mockLogin,
        logout: mockLogout,
    };

    const renderLoginForm = (onSuccess = vi.fn()) => {
        return render(
            <AuthContext.Provider value={mockAuthContextValue}>
                <LoginForm onSuccess={onSuccess} />
            </AuthContext.Provider>
        );
    };

    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('フォームが正しくレンダリングされること', () => {
        renderLoginForm();

        expect(screen.getByRole('heading', { name: 'ログイン' })).toBeInTheDocument();
        expect(screen.getByLabelText('メールアドレス')).toBeInTheDocument();
        expect(screen.getByLabelText('パスワード')).toBeInTheDocument();
        expect(screen.getByRole('button', { name: 'ログイン' })).toBeInTheDocument();
    });

    it('入力値を送信したとき、login 関数と onSuccess が正しく実行されること', async () => {
        const handleSuccess = vi.fn();
        mockLogin.mockResolvedValueOnce(undefined);

        renderLoginForm(handleSuccess);

        fireEvent.change(screen.getByLabelText('メールアドレス'), {
            target: { value: 'test@example.com' },
        });
        fireEvent.change(screen.getByLabelText('パスワード'), {
            target: { value: 'password123' },
        });

        fireEvent.click(screen.getByRole('button', { name: 'ログイン' }));

        await waitFor(() => {
            expect(mockLogin).toHaveBeenCalledWith('test@example.com', 'password123');
            expect(handleSuccess).toHaveBeenCalledTimes(1);
        });
    });

    it('ログイン失敗時、エラーメッセージが表示されること', async () => {
        mockLogin.mockRejectedValueOnce(new Error('メールアドレスまたはパスワードが正しくありません。'));

        renderLoginForm();

        fireEvent.change(screen.getByLabelText('メールアドレス'), {
            target: { value: 'wrong@example.com' },
        });
        fireEvent.change(screen.getByLabelText('パスワード'), {
            target: { value: 'wrongpass' },
        });

        fireEvent.click(screen.getByRole('button', { name: 'ログイン' }));

        const errorMessage = await screen.findByRole('alert');
        expect(errorMessage).toHaveTextContent('メールアドレスまたはパスワードが正しくありません。');
    });
});
EOF_1787016563_8983

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.tsx"
cat << 'EOF_1787016563_31066' > "apps/web/src/App.tsx"
import React, { useState } from 'react';
import { AppLayout, HeaderContent, SidebarNav, Button, Toaster, toast, showErrorToast } from '@app/ui';
import { clientEnv } from '@app/core/config/env';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { UserManagementTable } from '@app/features-user-management/ui';
import { ForbiddenPage } from './components/ForbiddenPage';

const DashboardContent: React.FC = () => {
    const { user, logout } = useAuth();
    const [currentTab, setCurrentTab] = useState<'dashboard' | 'users' | 'forbidden'>('dashboard');

    const navItems = [
        {
            label: 'ダッシュボード',
            href: '#',
            active: currentTab === 'dashboard',
            onClick: (e: React.MouseEvent) => {
                e.preventDefault();
                setCurrentTab('dashboard');
            },
        },
        ...(user?.role === 'admin'
            ? [
                {
                    label: 'ユーザー管理',
                    href: '#',
                    active: currentTab === 'users',
                    onClick: (e: React.MouseEvent) => {
                        e.preventDefault();
                        setCurrentTab('users');
                    },
                },
            ]
            : []),
        { label: 'プロジェクト一覧', href: '#' },
        { label: '設定', href: '#' },
    ];

    const handleSuccessToast = () => {
        toast.success('処理が完了しました', {
            description: 'データが正常に保存されました。',
        });
    };

    const handleRfcErrorToast = () => {
        const mockRfc9457Error = {
            type: 'https://example.com/errors/invalid-params',
            title: '入力項目に不備があります',
            status: 400,
            detail: 'メールアドレスの形式が正しくありません。',
            instance: '/api/v1/users',
        };

        showErrorToast(mockRfc9457Error);
    };

    const handleTriggerForbidden = () => {
        // 403 権限エラー発生時の画面テスト用動作
        setCurrentTab('forbidden');
    };

    return (
        <AppLayout
            header={
                <HeaderContent title={clientEnv.VITE_APP_TITLE}>
                    <div className="flex items-center gap-4 text-sm">
                        <span className="text-gray-600">
                            <span className="font-semibold text-gray-900">{user?.email}</span> ({user?.role})
                        </span>
                        <Button variant="outline" size="sm" onClick={logout}>
                            ログアウト
                        </Button>
                    </div>
                </HeaderContent>
            }
            sidebar={<SidebarNav items={navItems} />}
        >
            <div className="flex flex-col gap-6">
                {currentTab === 'dashboard' && (
                    <div className="flex flex-col gap-4">
                        <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
                            <h2 className="text-lg font-semibold text-gray-900 mb-2">ダッシュボード</h2>
                            <p className="text-sm text-gray-600">
                                システム概要や各種機能へのショートカットをここに表示します。
                            </p>
                        </div>

                        <div className="rounded-lg border border-dashed border-gray-300 p-4">
                            <p className="text-xs font-semibold text-gray-500 mb-2">UI 動作確認 (Debug)</p>
                            <div className="flex gap-2">
                                <Button variant="default" size="sm" onClick={handleSuccessToast}>
                                    成功 Toast を表示
                                </Button>
                                <Button variant="destructive" size="sm" onClick={handleRfcErrorToast}>
                                    RFC 9457 エラー Toast を表示
                                </Button>
                                <Button variant="outline" size="sm" onClick={handleTriggerForbidden}>
                                    403 権限エラー画面を表示
                                </Button>
                            </div>
                        </div>
                    </div>
                )}

                {currentTab === 'users' && user?.role === 'admin' && (
                    <UserManagementTable apiBaseUrl="/api/user-management" />
                )}

                {currentTab === 'forbidden' && (
                    <ForbiddenPage onBackToDashboard={() => setCurrentTab('dashboard')} />
                )}
            </div>
        </AppLayout>
    );
};

export function App() {
    return (
        <AuthProvider>
            <Toaster />
            <ProtectedRoute>
                <DashboardContent />
            </ProtectedRoute>
        </AuthProvider>
    );
}

export default App;
EOF_1787016563_31066

mkdir -p "apps/web/src/lib"
echo "作成: apps/web/src/lib/apiClient.test.ts"
cat << 'EOF_1787016563_2842' > "apps/web/src/lib/apiClient.test.ts"
// apps/web/src/lib/apiClient.test.ts
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { apiClient, ApiError } from "./apiClient";
import { AUTH_TOKEN_KEY } from '@app/core';

describe("apiClient (API クライアント)", () => {
    const originalFetch = globalThis.fetch;

    beforeEach(() => {
        localStorage.clear();
        vi.restoreAllMocks();
    });

    afterEach(() => {
        globalThis.fetch = originalFetch;
    });

    it("正常系: リクエストヘッダーに Content-Type と Authorization トークンが正しく設定されること", async () => {
        localStorage.setItem(AUTH_TOKEN_KEY, "mock-jwt-token");

        const mockResponse = { id: "1", name: "テストユーザー" };
        (globalThis as any).fetch = vi.fn().mockResolvedValue({
            ok: true,
            headers: new Headers({ "content-type": "application/json" }),
            json: async () => mockResponse,
        });

        const data = await apiClient.get<{ id: string; name: string }>("/api/me");

        expect(data).toEqual(mockResponse);

        // fetch の呼出し引数を検証
        const [url, options] = ((globalThis as any).fetch as any).mock.calls[0];
        expect(url).toContain("/api/me");
        expect(options.method).toBe("GET");

        // Headers オブジェクトから取得して検証
        const headers = options.headers as Headers;
        expect(headers.get("Content-Type")).toBe("application/json");
        expect(headers.get("Authorization")).toBe("Bearer mock-jwt-token");
    });

    it("異常系: RFC 9457 エラーレスポンスを受け取った際、ApiError をスローすること", async () => {
        const problemJson = {
            type: "about:blank",
            title: "Bad Request",
            status: 400,
            detail: "入力内容が不正です",
            instance: "/api/test",
            invalidParams: [
                { name: "email", reason: "メールアドレスの形式が正しくありません" },
            ],
        };

        (globalThis as any).fetch = vi.fn().mockResolvedValue({
            ok: false,
            status: 400,
            headers: new Headers({ "content-type": "application/problem+json" }),
            json: async () => problemJson,
        });

        try {
            await apiClient.post("/api/test", { email: "invalid" });
            expect.fail("エラーが発生しませんでした");
        } catch (error) {
            expect(error).toBeInstanceOf(ApiError);
            const apiError = error as ApiError;
            expect(apiError.status).toBe(400);
            expect(apiError.title).toBe("Bad Request");
            expect(apiError.detail).toBe("入力内容が不正です");
            expect(apiError.invalidParams).toHaveLength(1);
        }
    });

    it("異常系: 401 Unauthorized 発生時にローカルストレージのトークンが削除されること", async () => {
        localStorage.setItem(AUTH_TOKEN_KEY, "expired-token");

        (globalThis as any).fetch = vi.fn().mockResolvedValue({
            ok: false,
            status: 401,
            headers: new Headers({ "content-type": "application/problem+json" }),
            json: async () => ({
                type: "about:blank",
                title: "Unauthorized",
                status: 401,
                detail: "認証期限が切れています",
            }),
        });

        await expect(apiClient.get("/api/protected")).rejects.toThrow(ApiError);
        expect(localStorage.getItem(AUTH_TOKEN_KEY)).toBeNull();
    });
});
EOF_1787016563_2842

mkdir -p "apps/web/src/lib"
echo "作成: apps/web/src/lib/apiClient.ts"
cat << 'EOF_1787016563_1070' > "apps/web/src/lib/apiClient.ts"
// apps/web/src/lib/apiClient.ts
import { clientEnv } from "@app/ui";
import { AUTH_TOKEN_KEY } from '@app/core';

export interface InvalidParam {
    name: string;
    reason: string;
}

export class ApiError extends Error {
    public status: number;
    public title: string;
    public detail?: string;
    public instance?: string;
    public invalidParams?: InvalidParam[];

    constructor(problem: {
        title?: string;
        status?: number;
        detail?: string;
        instance?: string;
        invalidParams?: InvalidParam[];
    }) {
        super(problem.detail || problem.title || "API Error");
        this.name = "ApiError";
        this.status = problem.status || 500;
        this.title = problem.title || "エラーが発生しました";
        this.detail = problem.detail;
        this.instance = problem.instance;
        this.invalidParams = problem.invalidParams;
    }
}

export const getStoredToken = (): string | null => {
    return localStorage.getItem(AUTH_TOKEN_KEY);
};

export const setStoredToken = (token: string): void => {
    localStorage.setItem(AUTH_TOKEN_KEY, token);
};

export const removeStoredToken = (): void => {
    localStorage.removeItem(AUTH_TOKEN_KEY);
};

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const baseUrl = clientEnv.VITE_API_TARGET_URL || "";
    const url = `${baseUrl.replace(/\/$/, "")}${endpoint}`;

    const token = getStoredToken();
    const headers = new Headers(options.headers || {});

    if (!headers.has("Content-Type")) {
        headers.set("Content-Type", "application/json");
    }

    if (token) {
        headers.set("Authorization", `Bearer ${token}`);
    }

    const response = await fetch(url, {
        ...options,
        headers,
    });

    if (!response.ok) {
        if (response.status === 401) {
            removeStoredToken();
        }

        let errorData: any = {};
        try {
            errorData = await response.json();
        } catch {
            errorData = {
                title: response.statusText || "HTTP Error",
                status: response.status,
            };
        }

        throw new ApiError(errorData);
    }

    if (response.status === 204) {
        return {} as T;
    }

    return response.json();
}

export const apiClient = {
    get: <T>(endpoint: string, options?: RequestInit) =>
        request<T>(endpoint, { ...options, method: "GET" }),

    post: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
        request<T>(endpoint, {
            ...options,
            method: "POST",
            body: body ? JSON.stringify(body) : undefined,
        }),

    put: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
        request<T>(endpoint, {
            ...options,
            method: "PUT",
            body: body ? JSON.stringify(body) : undefined,
        }),

    delete: <T>(endpoint: string, options?: RequestInit) =>
        request<T>(endpoint, { ...options, method: "DELETE" }),
};
EOF_1787016563_1070

mkdir -p "apps/web"
echo "作成: apps/web/vite.config.ts"
cat << 'EOF_1787016563_30812' > "apps/web/vite.config.ts"
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import path from 'path';

export default defineConfig(({ mode }) => {
    // 環境変数が置かれているルートディレクトリのパス
    const envDir = path.resolve(import.meta.dirname, '../../');

    // Vite 組み込みの loadEnv で .env ファイルをロード
    // 第3引数を '' に指定すると VITE_ 以外の環境変数も取得可能
    const env = loadEnv(mode, envDir, '');

    const webPort = Number(env.VITE_PORT);
    const apiTarget = env.VITE_API_TARGET_URL;

    return {
        envDir,
        plugins: [react(), tailwindcss()],
        resolve: {
            tsconfigPaths: true,
            alias: {
                '@app/ui': path.resolve(import.meta.dirname, '../../packages/ui/src'),
            },
        },
        server: {
            port: webPort,
            host: true,
            proxy: {
                '/api': {
                    target: apiTarget,
                    changeOrigin: true,
                },
                '/sample': {
                    target: apiTarget,
                    changeOrigin: true,
                },
            },
        },
    };
});
EOF_1787016563_30812

mkdir -p "apps/api"
echo "作成: apps/api/package.json"
cat << 'EOF_1787016563_22969' > "apps/api/package.json"
{
  "name": "@app/api",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch --env-file=../../.env src/index.ts",
    "build": "tsc"
  },
  "dependencies": {
    "@types/node": "^26.1.2",
    "@app/core": "*",
    "@app/plugins-auth-ad": "*",
    "@app/plugins-auth-local": "*",
    "@hono/node-server": "^2.0.5",
    "hono": "^4.0.0",
    "@hono/zod-validator": "^0.9.0",
    "zod": "^4.4.3"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "tsx": "^4.7.1",
    "typescript": "^5.3.3"
  }
}
EOF_1787016563_22969

mkdir -p "apps/api"
echo "作成: apps/api/tsconfig.json"
cat << 'EOF_1787016563_26497' > "apps/api/tsconfig.json"
{
    "extends": "../../tsconfig.json",
    "compilerOptions": {
        "lib": [
            "ES2022"
        ],
        "types": [
            "node"
        ]
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1787016563_26497

mkdir -p "apps/api"
echo "作成: apps/api/vitest.config.ts"
cat << 'EOF_1787016563_4750' > "apps/api/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'node',
        fileParallelism: false,                         // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
    },
});
EOF_1787016563_4750

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.ts"
cat << 'EOF_1787016563_8940' > "apps/api/src/index.ts"
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { serve } from '@hono/node-server';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { env, isTest, formatEnvForLog } from '@app/core';
import { AppError, ProblemDetails, ValidationError } from '@app/core';
import { AuthRegistry } from '@app/core';
import { loadFeatureModules } from '@app/core/server';
import { LocalAuthPlugin } from '@app/plugins-auth-local';
import { ActiveDirectoryAuthPlugin } from '@app/plugins-auth-ad';
import { authRouter } from './routes/auth';
import { healthRouter } from './routes/health';
import { systemRouter } from './routes/system';
import { userManagementRoutes } from './routes/user-management';
import { loggerMiddleware } from './middlewares/logger';
import { authMiddleware } from './middlewares/auth-middleware';

// コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
if (!isTest) {
    console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog());
}

// 3. プラグインの登録
AuthRegistry.register(new LocalAuthPlugin());
AuthRegistry.register(new ActiveDirectoryAuthPlugin());

const app = new Hono();

// -----------------------------------------------------------------------------
// グローバルミドルウェア (全リクエストで最初に実行する処理)
// -----------------------------------------------------------------------------
app.use('*', loggerMiddleware);

// CORS ミドルウェアの適用
app.use(
    '*',
    cors({
        origin: env.CORS_ORIGIN,
        allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
        allowHeaders: ['Content-Type', 'Authorization'],
        credentials: true,
    })
);

// -----------------------------------------------------------------------------
// テスト専用ルート (テストの場合のみ有効化)
// -----------------------------------------------------------------------------
if (isTest) {
    app.get('/test/error', () => {
        throw new Error('Test internal error');
    });
}

// -----------------------------------------------------------------------------
// ルーティング・モジュール読み込み
// -----------------------------------------------------------------------------
// ヘルスチェックルート (/healthz)
app.route('/', healthRouter);

// 認証関連ルート (/api/auth/*)
app.route('/api/auth', authRouter(env.JWT_SECRET));

// システム状態管理ルート (/api/system/*)
app.route('/api/system', systemRouter);

// ユーザー管理ルート (/api/user-management/*) - 認証 + RBACガード付き
app.use('/api/user-management/*', authMiddleware(env.JWT_SECRET));
app.route('/api/user-management', userManagementRoutes);

// プラグイン/フィーチャーモジュールの動的読み込み
await loadFeatureModules(app, 'packages/features/*/src/index.ts');

// -----------------------------------------------------------------------------
// テスト専用バリデーションルート (テストの場合のみ)
// -----------------------------------------------------------------------------
if (isTest) {
    const sampleSchema = z.object({
        name: z.string().min(2, 'Name must be at least 2 characters'),
        email: z.string().email('Invalid email address'),
    });

    app.post(
        '/test/validation',
        zValidator('json', sampleSchema, (result, c) => {
            if (!result.success) {
                // Zod のエラー結果を統一した InvalidParam 形式に変換
                const invalidParams = result.error.issues.map((issue) => ({
                    name: issue.path.join('.'),
                    reason: issue.message,
                }));
                // カスタムValidationErrorをスローして共通onErrorに流す
                throw new ValidationError(invalidParams);
            }
        }),
        (c) => {
            return c.json({ success: true });
        }
    );
}

// -----------------------------------------------------------------------------
// 404 Not Found ハンドラー (RFC 9457 形式)
// -----------------------------------------------------------------------------
app.notFound((c) => {
    const problem: ProblemDetails = {
        type: 'about:blank',
        title: 'Not Found',
        status: 404,
        detail: 'The requested resource was not found',
        instance: c.req.path,
    };
    return c.json(problem, 404);
});

// -----------------------------------------------------------------------------
// 共通エラーハンドラー (app.onError - RFC 9457 形式)
// -----------------------------------------------------------------------------
app.onError((err, c) => {
    let status = 500;
    let title = 'Internal Server Error';
    let detail = 'An unexpected error occurred';
    let invalidParams: any = undefined;

    if (err instanceof AppError) {
        status = err.status;
        title = err.title;
        detail = err.message;

        if (err instanceof ValidationError) {
            invalidParams = err.invalidParams;
        }
    }

    const problem: ProblemDetails = {
        type: 'about:blank',
        title,
        status,
        detail,
        instance: c.req.path,
        ...(invalidParams && { invalidParams }),
    };

    return c.json(problem, status as any);
});

// -----------------------------------------------------------------------------
// サーバーバインド & 起動処理
// -----------------------------------------------------------------------------
const port = env.PORT; // 型安全な数値ポート番号を使用

// 💡 テスト以外の場合のみ、実際の HTTP サーバーを起動する
if (!isTest) {
    console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);
    serve({
        fetch: app.fetch,
        port,
        hostname: '0.0.0.0',
    });
}

export default app;
EOF_1787016563_8940

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.test.ts"
cat << 'EOF_1787016563_10624' > "apps/api/src/index.test.ts"
import { describe, it, expect } from 'vitest';
import app from './index';

describe('API Error Handling (RFC 9457)', () => {
    it('未定義のルートにアクセスした場合、404エラーがRFC9457形式で返ること', async () => {
        const res = await app.request('/api/non-existent-route');
        expect(res.status).toBe(404);

        const body = (await res.json()) as any;
        expect(body).toEqual({
            type: 'about:blank',
            title: 'Not Found',
            status: 404,
            detail: 'The requested resource was not found',
            instance: '/api/non-existent-route',
        });
    });

    it('意図しないサーバー内部エラーが発生した場合、500エラーが共通形式で返ること', async () => {
        const res = await app.request('/test/error');
        expect(res.status).toBe(500);

        const body = (await res.json()) as any;
        expect(body).toEqual({
            type: 'about:blank',
            title: 'Internal Server Error',
            status: 500,
            detail: 'An unexpected error occurred',
            instance: '/test/error',
        });
    });
});

describe('Zod Request Validation (Step 2)', () => {
    it('リクエストBodyが不正な場合、400エラーと詳細なフィールドエラー情報がRFC9457形式で返ること', async () => {
        // 必須項目（email）が欠落しており、name が短すぎる不正なリクエストデータ
        const invalidPayload = {
            name: 'a', // 最低2文字以上必要とする仕様
        };

        const res = await app.request('/test/validation', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(invalidPayload),
        });

        expect(res.status).toBe(400);

        const body = (await res.json()) as any;
        expect(body).toMatchObject({
            type: 'about:blank',
            title: 'Bad Request',
            status: 400,
            detail: 'Validation failed for the request payload',
            instance: '/test/validation',
        });

        // フィールドごとのエラー詳細が含まれているか検証
        expect(body.invalidParams).toEqual(
            expect.arrayContaining([
                expect.objectContaining({ name: 'name' }),
                expect.objectContaining({ name: 'email' }),
            ])
        );
    });
});

describe('User Management Integration (Step 9)', () => {
    it('未認証の状態で /api/user-management にアクセスした際、401 Unauthorized が返ること', async () => {
        const res = await app.request('/api/user-management');
        expect(res.status).toBe(401);
    });
});
EOF_1787016563_10624

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/health.test.ts"
cat << 'EOF_1787016563_11680' > "apps/api/src/routes/health.test.ts"
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import app from '../index';
import { db } from '@app/core/server';

describe('Health Check API (Step 6.1)', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        vi.restoreAllMocks();
    });

    afterEach(() => {
        vi.restoreAllMocks();
    });

    it('GET /healthz - DB導通が正常な場合、200 OK と status: ok を返すこと', async () => {
        const res = await app.request('/healthz');

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body).toEqual({
            status: 'ok',
            db: 'connected',
        });
    });

    it('GET /healthz - DB接続エラーが発生した場合、503 と RFC 9457 形式のエラーを返すこと', async () => {
        vi.spyOn(db, 'execute').mockRejectedValueOnce(new Error('Database connection failed'));

        const res = await app.request('/healthz');
        expect(res.status).toBe(503);

        const body = await res.json();

        expect(body).toEqual({
            type: 'about:blank',
            title: 'Service Unavailable',
            status: 503,
            detail: 'Database connection failed',
            instance: '/healthz',
        });
    });
});
EOF_1787016563_11680

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.ts"
cat << 'EOF_1787016563_12559' > "apps/api/src/routes/auth.ts"
import { Hono } from 'hono';
import { z } from 'zod';
import { eq } from 'drizzle-orm';
import { db, users } from '@app/core/server';
import { UnauthorizedError } from '@app/core';
import { verifyPassword, signJwt } from '@app/plugins-auth-local';
import { authMiddleware } from '../middlewares/auth-middleware';

// ログインリクエストのバリデーションスキーマ
const loginSchema = z.object({
    email: z.string().email(),
    password: z.string().min(1),
});

/**
 * 認証関連の API ルーター
 */
export function authRouter(jwtSecret: string) {
    const app = new Hono();

    // ----------------------------------------------------
    // 1. POST /login (ログイン & トークン発行)
    // ----------------------------------------------------
    app.post('/login', async (c) => {
        const body = await c.req.json();
        const result = loginSchema.safeParse(body);

        if (!result.success) {
            throw new UnauthorizedError('Invalid email or password format.');
        }

        const { email, password } = result.data;

        // DB からユーザーを検索
        const user = await db.query.users.findFirst({
            where: eq(users.email, email),
        });

        if (!user) {
            // セキュリティ上「ユーザーが存在しない」メッセージは出さず 401 を返す
            throw new UnauthorizedError('Invalid credentials.');
        }

        // パスワードの照合
        const isPasswordValid = await verifyPassword(password, user.passwordHash);
        if (!isPasswordValid) {
            throw new UnauthorizedError('Invalid credentials.');
        }

        // JWT アクセストークンの発行
        const token = await signJwt(
            {
                userId: user.id,
                email: user.email,
                role: user.role,
            },
            jwtSecret
        );

        return c.json({
            token,
            user: {
                id: user.id,
                email: user.email,
                role: user.role,
            },
        });
    });

    // ----------------------------------------------------
    // 2. GET /me (ログインユーザー情報取得)
    // ----------------------------------------------------
    app.get('/me', authMiddleware(jwtSecret), async (c) => {
        const currentUser = c.get('user');

        return c.json({
            user: {
                id: currentUser.userId,
                email: currentUser.email,
                role: currentUser.role,
            },
        });
    });

    return app;
}
EOF_1787016563_12559

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/system.ts"
cat << 'EOF_1787016563_24478' > "apps/api/src/routes/system.ts"
import { Hono } from 'hono';
import { db, plugins as pluginsTable } from '@app/core/server';
import { PluginRegistry } from '@app/core';

export const systemRouter = new Hono();

/**
 * GET /api/system/plugins
 * 有効化（enabled: true）されているプラグインの一覧および
 * フロントエンド表示に必要なナビゲーション（navItems）を返却するAPI
 */
systemRouter.get('/plugins', async (c) => {
    // 1. DBからプラグインの有効/無効ステータスを取得
    let dbPluginsMap = new Map<string, boolean>();
    try {
        const dbPlugins = await db.select().from(pluginsTable);
        dbPlugins.forEach((p) => dbPluginsMap.set(p.id, p.enabled));
    } catch (error) {
        console.warn('[System API] Failed to fetch plugins table status.');
    }

    // 2. レジストリから全プラグイン情報を取得し、有効なもののみフィルタリング
    const activePlugins = PluginRegistry.getAll()
        .filter((plugin) => {
            // DBに存在する場合はその値、存在しない場合はデフォルトで有効(true)とする
            return dbPluginsMap.has(plugin.id) ? dbPluginsMap.get(plugin.id) : true;
        })
        .map((plugin) => ({
            id: plugin.id,
            name: plugin.name,
            description: plugin.description,
            navItems: plugin.navItems ?? [],
        }));

    return c.json({
        plugins: activePlugins,
    });
});
EOF_1787016563_24478

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/user-management.test.ts"
cat << 'EOF_1787016563_1982' > "apps/api/src/routes/user-management.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import app from '../index';
import { signJwt } from '@app/plugins-auth-local';
import { env } from '@app/core';
import { db, users } from '@app/core/server';
import { eq } from 'drizzle-orm';

async function createToken(role: 'admin' | 'user', id: string = '1') {
    return await signJwt({ sub: id, role }, env.JWT_SECRET);
}

describe('User Management API Routes (PostgreSQL Integration)', () => {
    beforeEach(async () => {
        await db.delete(users);
        await db.insert(users).values([
            {
                id: 1,
                name: '管理者',
                email: 'admin@example.com',
                passwordHash: 'dummy_hash',
                role: 'admin',
                isActive: true,
            },
            {
                id: 2,
                name: '一般ユーザー',
                email: 'user@example.com',
                passwordHash: 'dummy_hash',
                role: 'user',
                isActive: true,
            },
        ]);
    });

    it('認証ヘッダーがない場合は 401 を返すこと', async () => {
        const res = await app.request('/api/user-management');
        expect(res.status).toBe(401);
    });

    it('一般ユーザーからのアクセスは 403 を返すこと', async () => {
        const token = await createToken('user', '2');
        const res = await app.request('/api/user-management', {
            headers: { Authorization: `Bearer ${token}` },
        });
        expect(res.status).toBe(403);
    });

    it('GET /api/user-management - ユーザー一覧を取得できること', async () => {
        const token = await createToken('admin', '1');
        const res = await app.request('/api/user-management', {
            headers: { Authorization: `Bearer ${token}` },
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(200);
        const data = (await res.json()) as any;
        expect(data.users.length).toBe(2);
        expect(data.users[0].email).toBe('admin@example.com');
    });

    it('POST /api/user-management - パスワード未指定時にユーザーを作成し、自動生成された initialPassword を返却すること', async () => {
        const token = await createToken('admin', '1');
        const res = await app.request('/api/user-management', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
                name: '新規追加ユーザー',
                email: 'newuser@example.com',
                role: 'user',
            }),
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(201);
        const data = (await res.json()) as any;
        expect(data.user).toHaveProperty('id');
        expect(data.user.email).toBe('newuser@example.com');
        expect(data.initialPassword).toBeDefined();

        const [savedUser] = await db.select().from(users).where(eq(users.email, 'newuser@example.com'));
        expect(savedUser).toBeDefined();
        expect(savedUser.passwordHash).not.toBe('default_hash');
    });

    it('POST /api/user-management - パスワードを明示的に指定してユーザーを作成できること', async () => {
        const token = await createToken('admin', '1');
        const customPassword = 'MyCustomPassword123!';
        const res = await app.request('/api/user-management', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
                name: 'カスタムパスワードユーザー',
                email: 'custompass@example.com',
                role: 'user',
                password: customPassword,
            }),
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(201);
        const data = (await res.json()) as any;
        expect(data.user.email).toBe('custompass@example.com');
        expect(data.initialPassword).toBe(customPassword);

        const [savedUser] = await db.select().from(users).where(eq(users.email, 'custompass@example.com'));
        expect(savedUser).toBeDefined();
    });

    it('POST /api/user-management - 短すぎるパスワード（8文字未満）の場合はバリデーションエラーを返すこと', async () => {
        const token = await createToken('admin', '1');
        const res = await app.request('/api/user-management', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
                name: 'エラーユーザー',
                email: 'erroruser@example.com',
                role: 'user',
                password: 'short',
            }),
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(400);
    });

    describe('安全策（自己操作の禁止）', () => {
        it('管理者自身（ID: 1）を削除しようとした場合、400 エラーになること', async () => {
            const token = await createToken('admin', '1');
            const res = await app.request('/api/user-management/1', {
                method: 'DELETE',
                headers: { Authorization: `Bearer ${token}` },
            });

            expect(res.status).toBe(400);
            const data = (await res.json()) as any;
            expect(data).toHaveProperty('title');
        });

        it('管理者自身（ID: 1）のロールを user に変更しようとした場合、400 エラーになること', async () => {
            const token = await createToken('admin', '1');
            const res = await app.request('/api/user-management/1/role', {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify({ role: 'user' }),
            });

            expect(res.status).toBe(400);
        });

        it('管理者自身（ID: 1）を無効化しようとした場合、400 エラーになること', async () => {
            const token = await createToken('admin', '1');
            const res = await app.request('/api/user-management/1/status', {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify({ isActive: false }),
            });

            expect(res.status).toBe(400);
        });
    });

    it('DELETE /api/user-management/:id - 他のユーザー（ID: 2）を正しく削除できること', async () => {
        const token = await createToken('admin', '1');
        const res = await app.request('/api/user-management/2', {
            method: 'DELETE',
            headers: { Authorization: `Bearer ${token}` },
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(200);

        const [deletedUser] = await db.select().from(users).where(eq(users.id, 2));
        expect(deletedUser).toBeUndefined();
    });
});
EOF_1787016563_1982

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/health.ts"
cat << 'EOF_1787016563_23328' > "apps/api/src/routes/health.ts"
import { Hono } from 'hono';
import { db } from '@app/core/server';
import { AppError } from '@app/core';
import { sql } from 'drizzle-orm';

export const healthRouter = new Hono();

healthRouter.get('/healthz', async (c) => {
    try {
        // DB導通テスト (SELECT 1)
        await db.execute(sql`SELECT 1`);

        return c.json({
            status: 'ok',
            db: 'connected',
        });
    } catch (error) {
        // DB不通時は 503 エラーをスロー (status, code, title, message)
        throw new AppError(
            503,
            'SERVICE_UNAVAILABLE',
            'Service Unavailable',
            'Database connection failed'
        );
    }
});
EOF_1787016563_23328

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/system.test.ts"
cat << 'EOF_1787016563_13404' > "apps/api/src/routes/system.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { PluginRegistry } from '@app/core';
import { systemRouter } from './system';

describe('GET /api/system/plugins', () => {
    beforeEach(() => {
        PluginRegistry.register({
            id: 'sample-plugin',
            name: 'サンプル',
            routes: new Hono(),
            navItems: [{ label: 'サンプル画面', path: '/sample' }],
        });
    });

    it('有効なプラグイン一覧と navItems を返却すること', async () => {
        const app = new Hono();
        app.route('/api/system', systemRouter);

        const res = await app.request('/api/system/plugins');
        expect(res.status).toBe(200);
        const body = (await res.json()) as any;
        expect(body.plugins).toBeDefined();

        const target = body.plugins.find((p: any) => p.id === 'sample-plugin');
        expect(target).toBeDefined();
        expect(target.navItems).toHaveLength(1);

    });
});
EOF_1787016563_13404

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/user-management.ts"
cat << 'EOF_1787016563_9748' > "apps/api/src/routes/user-management.ts"
import { Hono } from 'hono';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { rbacMiddleware } from '../middlewares/rbac-middleware';
import { ValidationError, BadRequestError, NotFoundError } from '@app/core';
import { db, users } from '@app/core/server';
import { hashPassword } from '@app/plugins-auth-local';
import { eq } from 'drizzle-orm';

export const userManagementRoutes = new Hono();

// RBAC: admin ロールのみ許可
userManagementRoutes.use('*', rbacMiddleware(['admin']));

// JWT ペイロード（sub / id）からログインユーザー ID を取得するヘルパー
function getCurrentUserId(c: any): number | null {
    const user = c.get('user');
    if (!user) return null;
    const rawId = user.sub ?? user.id;
    return rawId ? Number(rawId) : null;
}

const createUserSchema = z.object({
    name: z.string().min(1, '名前は必須です'),
    email: z.string().email('有効なメールアドレスを入力してください'),
    role: z.enum(['admin', 'user'], { message: 'ロールは admin または user を指定してください' }),
    password: z.string().min(8, 'パスワードは8文字以上で指定してください').optional(),
});

// GET /api/user-management - ユーザー一覧取得
userManagementRoutes.get('/', async (c) => {
    const userList = await db.select().from(users);
    return c.json({ users: userList });
});

// POST /api/user-management - ユーザー新規追加
userManagementRoutes.post(
    '/',
    zValidator('json', createUserSchema, (result) => {
        if (!result.success) {
            const invalidParams = result.error.issues.map((issue) => ({
                name: issue.path.join('.'),
                reason: issue.message,
            }));
            throw new ValidationError(invalidParams);
        }
    }),
    async (c) => {
        const body = await c.req.json<z.infer<typeof createUserSchema>>();

        const [existingUser] = await db.select().from(users).where(eq(users.email, body.email));
        if (existingUser) {
            throw new BadRequestError('指定されたメールアドレスは既に登録されています');
        }

        // パスワードが指定されている場合はそれを使用し、未指定の場合は自動生成
        const rawPassword = body.password || `InitPass_${Math.random().toString(36).slice(-8)}`;
        const passwordHash = await hashPassword(rawPassword);

        const [newUser] = await db.insert(users).values({
            name: body.name,
            email: body.email,
            passwordHash,
            role: body.role,
            isActive: true,
        }).returning();

        return c.json({ user: newUser, initialPassword: rawPassword }, 201);
    }
);

// PATCH /api/user-management/:id/status - ステータス変更
userManagementRoutes.patch('/:id/status', async (c) => {
    const id = Number(c.req.param('id'));
    const currentUserId = getCurrentUserId(c);
    const { isActive } = await c.req.json<{ isActive: boolean }>();

    // 自分自身の無効化を防止
    if (currentUserId === id && isActive === false) {
        throw new BadRequestError('自分自身のアカウントを無効化することはできません');
    }

    const [updatedUser] = await db.update(users)
        .set({ isActive })
        .where(eq(users.id, id))
        .returning();

    if (!updatedUser) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ user: updatedUser });
});

// PATCH /api/user-management/:id/role - ロール変更
userManagementRoutes.patch('/:id/role', async (c) => {
    const id = Number(c.req.param('id'));
    const currentUserId = getCurrentUserId(c);
    const { role } = await c.req.json<{ role: 'user' | 'admin' }>();

    // 自分自身の管理者権限の剥奪（user化）を防止
    if (currentUserId === id && role !== 'admin') {
        throw new BadRequestError('自分自身の管理者権限を変更することはできません');
    }

    const [updatedUser] = await db.update(users)
        .set({ role })
        .where(eq(users.id, id))
        .returning();

    if (!updatedUser) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ user: updatedUser });
});

// DELETE /api/user-management/:id - ユーザー削除
userManagementRoutes.delete('/:id', async (c) => {
    const id = Number(c.req.param('id'));
    const currentUserId = getCurrentUserId(c);

    // 自分自身の削除を防止
    if (currentUserId === id) {
        throw new BadRequestError('自分自身のアカウントを削除することはできません');
    }

    const [deletedUser] = await db.delete(users)
        .where(eq(users.id, id))
        .returning();

    if (!deletedUser) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ message: 'ユーザーを削除しました', user: deletedUser });
});
EOF_1787016563_9748

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.test.ts"
cat << 'EOF_1787016563_6339' > "apps/api/src/routes/auth.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { authRouter } from './auth';
import { db, users } from '@app/core/server';
import { AppError } from '@app/core';
import { hashPassword } from '@app/plugins-auth-local';

describe('Auth Routes (Step 4.3)', () => {
    const secret = 'test-secret-key-at-least-32-chars-long';

    // テスト用アプリのセットアップ
    const createTestApp = () => {
        const app = new Hono();

        // 統一エラーハンドラ
        app.onError((err, c) => {
            if (err instanceof AppError) {
                return c.json(
                    {
                        type: 'about:blank',
                        title: err.title,
                        status: err.status,
                        detail: err.message,
                        instance: c.req.path,
                    },
                    err.status as any
                );
            }
            return c.json({ title: 'Internal Server Error', status: 500 }, 500);
        });

        app.route('/api/auth', authRouter(secret));
        return app;
    };

    // テスト用初期ユーザーのセットアップ
    beforeEach(async () => {
        // 既存データのクリーンアップ
        await db.delete(users);

        // テストユーザーを挿入
        const hashedPassword = await hashPassword('password123');
        await db.insert(users).values({
            name: 'Test User',
            email: 'test@example.com',
            passwordHash: hashedPassword,
            role: 'user',
        });
    });

    describe('POST /api/auth/login', () => {
        it('正しい資格情報でログインし、JWT トークンが返ること', async () => {
            const app = createTestApp();
            const res = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'test@example.com',
                    password: 'password123',
                }),
            });

            expect(res.status).toBe(200);
            const body = (await res.json()) as any;

            expect(body.token).toBeDefined();
            expect(body.user.email).toBe('test@example.com');
            expect(body.user.passwordHash).toBeUndefined();
        });

        it('誤ったパスワードの場合、401 エラーを返すこと', async () => {
            const app = createTestApp();
            const res = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'test@example.com',
                    password: 'wrongpassword',
                }),
            });

            expect(res.status).toBe(401);
        });


        it('存在しないメールアドレスの場合、401 エラーを返すこと', async () => {
            const app = createTestApp();
            const res = await app.request('/api/auth/login', {

                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'nonexistent@example.com',
                    password: 'password123',
                }),
            });

            expect(res.status).toBe(401);
        });
    });

    describe('GET /api/auth/me', () => {
        it('有効な JWT トークンで自分のプロファイルを取得できること', async () => {
            const app = createTestApp();

            // 1. ログインしてトークン取得
            const loginRes = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'test@example.com',
                    password: 'password123',
                }),
            });
            const { token } = (await loginRes.json()) as any;

            // 2. /me にリクエスト


            const meRes = await app.request('/api/auth/me', {
                headers: { Authorization: `Bearer ${token}` },


            });

            expect(meRes.status).toBe(200);
            const meBody = (await meRes.json()) as any;
            expect(meBody.user.email).toBe('test@example.com');
            expect(meBody.user.passwordHash).toBeUndefined();
        });

        it('Authorization ヘッダーがない場合、401 エラーを返すこと', async () => {
            const app = createTestApp();
            const res = await app.request('/api/auth/me');

            expect(res.status).toBe(401);
        });
    });
});
EOF_1787016563_6339

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.ts"
cat << 'EOF_1787016563_4266' > "apps/api/src/middlewares/auth-middleware.ts"
import type { MiddlewareHandler } from 'hono';
import { verifyJwt } from '@app/plugins-auth-local';
import { UnauthorizedError } from '@app/core';

// Hono の ContextVariableMap を拡張
declare module 'hono' {
    interface ContextVariableMap {
        user: Record<string, unknown>;
    }
}

/**
 * JWT Bearer トークンを検証する Hono ミドルウェア
 */
export function authMiddleware(secret: string): MiddlewareHandler {
    return async (c, next) => {
        const authHeader = c.req.header('Authorization');

        // 1. Authorization ヘッダーの存在チェック
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new UnauthorizedError('Authentication token is missing or invalid format.');
        }

        // 2. トークンの抽出と検証
        const token = authHeader.substring(7);
        const payload = await verifyJwt(token, secret);

        if (!payload) {
            throw new UnauthorizedError('Token is invalid or expired.');
        }

        // 3. コンテキストにユーザー情報をセットして次の処理へ
        c.set('user', payload);
        await next();
    };
}
EOF_1787016563_4266

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.test.ts"
cat << 'EOF_1787016563_3470' > "apps/api/src/middlewares/auth-middleware.test.ts"
import { describe, it, expect } from 'vitest';
import { Hono } from 'hono';

import { authMiddleware } from './auth-middleware';
import { AppError } from '@app/core';
import { signJwt } from '@app/plugins-auth-local';

describe('Auth Middleware (Step 4.2)', () => {
    const secret = 'test-secret-key-at-least-32-chars-long';

    // テスト用の Hono アプリセットアップ
    const createTestApp = () => {
        const app = new Hono();

        // 💡 統一エラーハンドラを設定する
        app.onError((err, c) => {
            if (err instanceof AppError) {
                return c.json(
                    {
                        type: 'about:blank',
                        title: err.title,
                        status: err.status,
                        detail: err.message,
                        instance: c.req.path,
                    },
                    err.status as any
                );
            }
            return c.json({ title: 'Internal Server Error', status: 500 }, 500);
        });

        // 認証が必要な保護ルート
        app.use('/protected/*', authMiddleware(secret));
        app.get('/protected/profile', (c) => {
            const user = c.get('user');
            return c.json({ message: 'Success', user });
        });


        return app;
    };


    it('Authorization ヘッダーがない場合、RFC 7807 形式で 401 エラーを返すこと', async () => {
        const app = createTestApp();
        const res = await app.request('/protected/profile');

        expect(res.status).toBe(401);
        const body = (await res.json()) as any;

        // RFC 7807 の形式チェック
        expect(body.status).toBe(401);
        expect(body.title).toBe('Unauthorized');
        expect(body.detail).toBeDefined();
    });

    it('不正なトークンの場合、401 エラーを返すこと', async () => {
        const app = createTestApp();
        const res = await app.request('/protected/profile', {
            headers: {
                Authorization: 'Bearer invalid-token-string',
            },
        });

        expect(res.status).toBe(401);
    });

    it('正常な Bearer トークンの場合、リクエストが通過しコンテキストにユーザー情報がセットされること', async () => {
        const app = createTestApp();
        const payload = { userId: 'user-123', role: 'admin' };
        const validToken = await signJwt(payload, secret);

        const res = await app.request('/protected/profile', {
            headers: {
                Authorization: `Bearer ${validToken}`,
            },
        });

        expect(res.status).toBe(200);
        const body = (await res.json()) as any;

        expect(body.message).toBe('Success');
        expect(body.user).toMatchObject(payload);
    });
});
EOF_1787016563_3470

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/rbac-middleware.test.ts"
cat << 'EOF_1787016563_29458' > "apps/api/src/middlewares/rbac-middleware.test.ts"
import { describe, it, expect } from 'vitest';
import { Hono } from 'hono';

import { authMiddleware } from './auth-middleware';
import { rbacMiddleware } from './rbac-middleware';
import { AppError } from '@app/core';
import { signJwt } from '@app/plugins-auth-local';

describe('RBAC Middleware (Step 4.3)', () => {
    const secret = 'test-secret-key-at-least-32-chars-long';

    const createTestApp = () => {
        const app = new Hono();

        app.onError((err, c) => {
            if (err instanceof AppError) {
                return c.json(
                    {
                        type: 'about:blank',
                        title: err.title,
                        status: err.status,
                        detail: err.message,
                        instance: c.req.path,
                    },
                    err.status as any
                );
            }
            return c.json({ title: 'Internal Server Error', status: 500 }, 500);
        });

        // 認証後に admin ロールのみ許可する管理者ルート
        app.use('/admin/*', authMiddleware(secret));
        app.use('/admin/*', rbacMiddleware(['admin']));

        app.get('/admin/dashboard', (c) => {
            return c.json({ message: 'Admin Dashboard' });
        });

        return app;
    };

    it('一般ユーザー (role: user) の場合、403 Forbidden を返すこと', async () => {
        const app = createTestApp();
        const userToken = await signJwt({ userId: 'u1', role: 'user' }, secret);
        const res = await app.request('/admin/dashboard', {
            headers: { Authorization: `Bearer ${userToken}` },
        });

        expect(res.status).toBe(403);
        const body = (await res.json()) as any;

        expect(body.title).toBe('Forbidden');
        expect(body.status).toBe(403);
    });

    it('管理者ユーザー (role: admin) の場合、200 OK でアクセス許可されること', async () => {
        const app = createTestApp();
        const adminToken = await signJwt({ userId: 'a1', role: 'admin' }, secret);
        const res = await app.request('/admin/dashboard', {
            headers: { Authorization: `Bearer ${adminToken}` },
        });

        expect(res.status).toBe(200);
        const body = (await res.json()) as any;

        expect(body.message).toBe('Admin Dashboard');
    });
});
EOF_1787016563_29458

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/logger.test.ts"
cat << 'EOF_1787016563_22332' > "apps/api/src/middlewares/logger.test.ts"
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { Hono } from 'hono';
import { loggerMiddleware } from './logger';

describe('Logger Middleware (Step 6.2)', () => {
    let consoleSpy: any;

    beforeEach(() => {
        consoleSpy = vi.spyOn(console, 'log').mockImplementation(() => { });
    });

    afterEach(() => {
        consoleSpy.mockRestore();
    });

    it('リクエスト完了時、メソッド・パス・ステータス・処理時間を JSON 形式でログ出力すること', async () => {
        const app = new Hono();
        app.use('*', loggerMiddleware);
        app.get('/test', (c) => c.text('OK', 200));

        const res = await app.request('/test');
        expect(res.status).toBe(200);

        expect(consoleSpy).toHaveBeenCalledTimes(1);
        const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);
        expect(logOutput).toMatchObject({
            level: 'info',
            method: 'GET',
            path: '/test',
            status: 200,
        });
        expect(typeof logOutput.durationMs).toBe('number');
    });

    it('Authorization ヘッダー等の機密情報がログに含まれる場合、マスク処理されること', async () => {
        const app = new Hono();
        app.use('*', loggerMiddleware);
        app.post('/login', (c) => c.text('OK', 200));

        await app.request('/login', {
            method: 'POST',
            headers: {
                Authorization: 'Bearer secret-token-123',
            },
        });

        const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);

        // 1. まず headers プロパティが確実に定義されている（undefinedでない）ことを検証
        expect(logOutput.headers).toBeDefined();

        // 2. その上で authorization がマスクされていることを検証
        expect(logOutput.headers.authorization).toBeDefined();
        expect(logOutput.headers.authorization).toBe('***');
    });

    it('4xx 系の業務エラー（401等）発生時、level が "info" でありスタックトレースが含まれないこと', async () => {
        const app = new Hono();
        app.use('*', loggerMiddleware);

        app.get('/unauthorized', () => {
            throw new Error('Invalid credentials');
        });

        app.onError((err, c) => {
            c.error = err;
            return c.json({ message: err.message }, 401);
        });

        const res = await app.request('/unauthorized');
        expect(res.status).toBe(401);

        const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);
        expect(logOutput).toMatchObject({
            level: 'info',
            method: 'GET',
            path: '/unauthorized',
            status: 401,
        });
        expect(logOutput.error).toBeUndefined();
    });

    it('500系エラー発生時、level が "error" となりエラーメッセージとスタックトレースが JSON に含まれること', async () => {
        const app = new Hono();
        app.use('*', loggerMiddleware);

        app.get('/error', () => {
            throw new Error('Internal Server Error Test');
        });

        app.onError((err, c) => {
            c.error = err;
            return c.json({ message: err.message }, 500);
        });

        const res = await app.request('/error');
        expect(res.status).toBe(500);

        const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);
        expect(logOutput).toMatchObject({
            level: 'error',
            method: 'GET',
            path: '/error',
            status: 500,
            error: {
                message: 'Internal Server Error Test',
            },
        });
        expect(typeof logOutput.error.stack).toBe('string');
    });
});
EOF_1787016563_22332

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/rbac-middleware.ts"
cat << 'EOF_1787016563_28459' > "apps/api/src/middlewares/rbac-middleware.ts"
// apps/api/src/middlewares/rbac-middleware.ts
import type { MiddlewareHandler } from 'hono';
import { ForbiddenError, UnauthorizedError } from '@app/core';

/**
 * 許可されたロールのみアクセスを許可する RBAC ミドルウェア
 * @param allowedRoles 許可するロールの配列 (例: ['admin'])
 */
export function rbacMiddleware(allowedRoles: string[]): MiddlewareHandler {
    return async (c, next) => {
        const user = c.get('user') as { role?: string } | undefined;

        // 認証ミドルウェアが通過していない場合
        if (!user) {
            throw new UnauthorizedError('Authentication required.');
        }

        // ロールが未設定または許可されていないロールの場合 403 Forbidden
        if (!user.role || !allowedRoles.includes(user.role)) {
            throw new ForbiddenError('You do not have permission to access this resource.');
        }

        await next();
    };
}
EOF_1787016563_28459

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/logger.ts"
cat << 'EOF_1787016563_8782' > "apps/api/src/middlewares/logger.ts"
import { MiddlewareHandler } from 'hono';

function formatLocalISOString(date: Date): string {
    // 1. 各日時のパーツをローカル時間で取得してパッド（穴埋め）する
    const YYYY = date.getFullYear();
    const MM = String(date.getMonth() + 1).padStart(2, '0');
    const DD = String(date.getDate()).padStart(2, '0');
    const hh = String(date.getHours()).padStart(2, '0');
    const mm = String(date.getMinutes()).padStart(2, '0');
    const ss = String(date.getSeconds()).padStart(2, '0');
    const mss = String(date.getMilliseconds()).padStart(3, '0'); // ミリ秒（3桁）

    // 2. 時分のオフセットを計算 (例: +09:00)
    const offsetMinutes = -date.getTimezoneOffset();
    const sign = offsetMinutes >= 0 ? '+' : '-';
    const absMinutes = Math.abs(offsetMinutes);
    const offsetH = String(Math.floor(absMinutes / 60)).padStart(2, '0');
    const offsetM = String(absMinutes % 60).padStart(2, '0');

    // 3. ミリ秒までの時刻と、時分オフセットを結合
    return `${YYYY}-${MM}-${DD}T${hh}:${mm}:${ss}.${mss}${sign}${offsetH}:${offsetM}`;
}

export const loggerMiddleware: MiddlewareHandler = async (c, next) => {
    const start = new Date();
    const { method, path } = c.req;

    await next();

    const end = new Date();
    const durationMs = end.getTime() - start.getTime();

    const status = c.res.status;

    // 💡 500 以上のシステムエラーのみ error レベルとする（4xx は info レベル）
    const isServerError = status >= 500;
    const logLevel = isServerError ? 'error' : 'info';

    const authHeader = c.req.header('authorization');
    const headers: Record<string, string> = {};
    if (authHeader) {
        headers['authorization'] = '***';
    }

    const logPayload: Record<string, any> = {
        level: logLevel,
        timestamp: formatLocalISOString(start),    //new Date().toISOString(),
        method,
        path,
        status,
        durationMs,
        headers: Object.keys(headers).length > 0 ? headers : undefined,
    };

    // 💡 500 以上のサーバーエラーの場合のみエラー情報（スタックトレース）を出力
    if (isServerError && c.error) {
        logPayload.error = {
            message: c.error.message,
            stack: c.error.stack,
        };
    }

    console.log(JSON.stringify(logPayload));
};
EOF_1787016563_8782

echo "作成: README.md"
cat << 'EOF_1787016563_11220' > "README.md"
# 📖 プロジェクト基本仕様書 (Project Architecture Specification) - v2.5

## 1. システム概要 (Overview)

本プロジェクトは、TypeScript をベースとしたモノレポ構成の Web アプリケーションです。
バックエンドには軽量・高速な Web フレームワーク（**Hono**）、フロントエンドにはコンポーネント指向 UI ライブラリ（**React + Vite + Tailwind CSS**）、データベース操作には型安全な ORM（**Drizzle ORM / PostgreSQL**）を採用しています。

共通ロジックや拡張機能（認証・UI コンポーネント・業務モジュール等）を独立したパッケージへ分離し、クライアント側では型安全な API クライアントと Context による認証状態管理を組み合わせることで、保守性と拡張性を高めたコンポーザブルなアーキテクチャを実現します。

---

## 2. 開発環境仕様 (Development Environment)

開発チーム全員が同一の動作環境を再現し、ローカル環境依存のエラーやデータベース構築の手間を排除するため、**コンテナ型開発環境 (VS Code Dev Containers + Docker Compose)** を標準の開発基盤として定めます。

### 2.1 開発環境要件

* **VS Code 拡張機能:** Dev Containers (`ms-vscode-remote.remote-containers`)
* **コンテナランタイム:** Docker 互換環境 (Docker Desktop / OrbStack / Rancher Desktop 等)
* **Node.js 実行環境:** LTS バージョン (`v20.x` コンテナ内で固定)
* **パッケージ管理:** `npm` ワークスペース（複数パッケージ間の相互依存関係を一括管理）

### 2.2 コンテナ & サービス構成

開発環境は `.devcontainer/docker-compose.yml` により、アプリケーション実行環境とデータベース環境の 2 つのサービスで構成されます。

| サービス名 | コンテナ / イメージ | 役割・設計の意図 |
| --- | --- | --- |
| **app** | Node.js 20 Linux 環境 (`.devcontainer/Dockerfile`) | 開発者のプライマリ実行環境。VS Code をアタッチして開発を行います。ホスト環境の `node_modules` との依存関係衝突を防ぐため、ライブラリ層は匿名ボリュームとして独立管理します。 |
| **db** | PostgreSQL (`postgres:16-alpine`) | 開発専用のローカルデータベース。アプリケーションの終了やリスタートを行ってもデータが失われないよう、専用ボリュームで永続化します。 |

* **コンテナ間ネットワーク接続:**
アプリケーションコンテナ（`app`）からデータベースコンテナ（`db`）へは、内部 DNS 解決された同一ネットワーク上の URI (`postgresql://postgres:postgres@db:5432/app_db`) を用いて接続します。

---

## 3. システムアーキテクチャ (System Architecture)

モノレポ構造の強みを活かし、システムの各領域（基盤・UI・認証・機能）の関心を分離（疎結合化）しています。開発者は定められた層構造に従って安全に機能を拡張します。

### 3.1 パッケージの層構造と役割 (Layer Architecture)

| パッケージ名 | レイヤー区分 | 設計の意図・基本方針 | 主な役割・含まれる機能 | 制約・連携方式 |
| --- | --- | --- | --- | --- |
| **`packages/core`** | 共通基盤 | システム全域で利用される不変的な「基盤ルール」を集約 | 型定義、環境変数検証 (`CORS_ORIGIN` 等)、DB接続・スキーマ定義、共通エラー定義 (RFC 9457)、動的ローダー | 上位のビジネスロジックや特定アプリへの依存厳禁 |
| **`packages/ui`** | 共通 UI | フロントエンド全域で再利用されるデザインシステム・共通コンポーネントを集約 | Tailwind CSS v4 設定、原子コンポーネント (`Button`)、共通 Layout (`Header`/`Sidebar`)、Toast 通知 (`Sonner`) | 画面固有のビジネスロジックを持たず、純粋なプレゼンテーションに専念 |
| **`packages/plugins/`** | プラグイン | 運用環境や顧客要件に応じて切り替え・拡張される機能を独立化 | **`auth-local`** (`bcryptjs` / `jose` によるハッシュ化・JWT生成・検証)、外部 ID プロバイダー（Active Directory 等）のアダプター | アプリ層から依存性を注入（DI）して利用 |
| **`packages/features/`** | 業務ドメイン | 特定の業務機能を単位ごとにカプセル化し、独立した追加・削除・テストを可能化 | ドメイン専用 API ルート、ビジネスロジック、関連 UI コンポーネント | 上位アプリから単方向参照、他ドメインとは原則独立 |

### 3.2 拡張ルールと依存方向 (Extension Rules)

1. **機能追加の手順:**
新しいドメイン機能や連携モジュールを追加する際は、`packages/features/` または `packages/plugins/` 配下に新規パッケージを作成し、ルートのワークスペース管理に登録します。
2. **単方向依存の徹底:**
依存の方向は常に **「上位（`apps/`）から下位（`packages/`）」** の一方向に限定します。下位パッケージから上位アプリケーションへの逆参照は厳禁とします。

---

## 4. ディレクトリ構造 & 全ファイル一覧 (Directory & File Structure)

プロジェクト全体のフォルダおよびファイル構造です。コンポーネントやロジックとそのテストはコロケーション（同一ディレクトリ配置）を基本原則とします。

```text
.
├── .devcontainer/                # コンテナ開発環境構成
│   ├── devcontainer.json         # VS Code 開発環境統合設定
│   ├── docker-compose.yml        # 開発用マルチコンテナ構成定義 (app, db)
│   ├── Dockerfile                # アプリケーションコンテナのベース構築
│   └── scripts/                  # 開発環境自動化・初期化スクリプト群
│       └── setup-test-db.sh      # テスト用データベース作成・権限付与スクリプト
├── .env                          # プロジェクト共通の環境変数定義ファイル
├── .env.example                  # 環境変数のサンプル・テンプレート
├── .gitignore                    # Git 管理対象外設定
├── package.json                  # 全体スクリプトおよび Workspaces ルート定義
├── tsconfig.json                 # モノレポ共通のベース TypeScript 設定
│
├── apps/                         # アプリケーション層 (実行体)
│   ├── api/                      # サーバーサイド API アプリケーション (Hono)
│   │   ├── src/
│   │   │   ├── index.ts          # API エントリーポイント (CORS/ルーティング統括・共通エラーハンドラー・RFC 9457)
│   │   │   ├── index.test.ts     # API 共通挙動テスト (404/500/共通エラーハンドラー/バリデーション)
│   │   │   ├── middlewares/      # ミドルウェア層
│   │   │   │   ├── auth-middleware.ts      # JWT 検証・コンテキスト設定ミドルウェア
│   │   │   │   ├── auth-middleware.test.ts # 認証ミドルウェア単体・統合テスト
│   │   │   │   ├── rbac-middleware.ts      # ロールベース認可ミドルウェア (requireRole)
│   │   │   │   └── rbac-middleware.test.ts # 認可ミドルウェア単体・統合テスト (403 Forbidden 検証)
│   │   │   └── routes/           # アプリケーション固有のルーティング
│   │   │       ├── auth.ts       # 認証 API ルート (/login, /me)
│   │   │       ├── auth.test.ts  # 認証 API 統合テスト (ログイン・プロファイル取得)
│   │   │       ├── health.ts     # ヘルスチェック API ルート (/healthz)
│   │   │       └── health.test.ts# ヘルスチェック API 統合テスト (DB 接続確認・503 エラーハンドリング)
│   │   ├── package.json          # API サーバー用依存関係・スクリプト
│   │   └── tsconfig.json         # API サーバー用 TypeScript 設定
│   │
│   └── web/                      # クライアントサイド Web アプリケーション (React / Vite)
│       ├── public/               # 静的アセット (favicon 等)
│       ├── src/
│       │   ├── env.ts            # クライアント用環境変数保護・型定義モジュール
│       │   ├── App.tsx           # ルート UI コンポーネント (ルーティング・ProtectedRoute 適用)
│       │   ├── App.test.tsx      # ルート UI 単体テスト
│       │   ├── main.tsx          # React レンダリングエントリーポイント (index.cssインポート必須)
│       │   ├── index.css         # Tailwind CSS v4 エントリーポイント (@import "tailwindcss"; @source ...)
│       │   ├── auth/             # 認証状態管理・コンテキスト層
│       │   │   ├── AuthContext.tsx   # AuthContext / AuthProvider / useAuth フック実装
│       │   │   ├── AuthContext.test.tsx # AuthContext の単体テスト (ログイン/ログアウト/トークン永続化)
│       │   │   ├── ProtectedRoute.tsx   # 未認証ユーザー制限・リダイレクトガードコンポーネント
│       │   │   └── ProtectedRoute.test.tsx # ProtectedRoute 単体テスト
│       │   ├── components/       # アプリケーション固有の UI コンポーネント
│       │   │   ├── LoginForm.tsx     # ログインフォームコンポーネント (useAuth 連携)
│       │   │   └── LoginForm.test.tsx# ログインフォームの単体テスト
│       │   ├── pages/            # 画面ページコンポーネント
│       │   │   ├── LoginPage.tsx      # ログイン画面
│       │   │   ├── LoginPage.test.tsx # ログイン画面統合テスト
│       │   │   ├── DashboardPage.tsx  # ダッシュボード保護画面
│       │   │   └── DashboardPage.test.tsx # ダッシュボード画面単体テスト
│       │   ├── lib/              # フロントエンド共通ユーティリティ・ライブラリ
│       │   │   ├── apiClient.ts      # Fetch ベースの型安全 API クライアント (RFC 9457 エラーパース・トークン付与)
│       │   │   └── apiClient.test.ts # apiClient の単体・モックテスト
│       │   └── test/
│       │       └── setup.ts      # React Testing Library 用グローバルセットアップ
│       ├── index.html            # HTML エントリーテンプレート
│       ├── package.json          # Web アプリ用依存関係・スクリプト
│       ├── tsconfig.json         # Web アプリ用 TypeScript 設定 (packages/ui の include パス指定含む)
│       ├── tsconfig.node.json    # Vite 設定用 TypeScript 補助設定
│       └── vite.config.ts        # Vite 設定 (API プロキシ・環境変数読み込み・Vitest 設定)
│
└── packages/                     # 共有パッケージ層 (ライブラリ・モジュール)
    ├── core/                     # システム共通基盤パッケージ
    │   ├── drizzle.config.ts     # 通常開発/マイグレーション用 Drizzle 構成
    │   ├── drizzle-test.config.ts# テストDB専用 ORM 構成ファイル
    │   ├── src/
    │   │   ├── index.ts          # パッケージ共通エクスポート（Core モジュール統合）
    │   │   ├── config/           # 環境変数スキーマおよび堅牢化ロジック
    │   │   │   ├── env.ts        # Zod による環境変数定義・検証関数 (CORS_ORIGIN / API_BASE_URL 自動変換等)
    │   │   │   └── env.test.ts   # 環境変数検証の単体テスト
    │   │   ├── db/               # DB 接続インスタンスおよびスキーマ定義
    │   │   │   ├── index.ts      # シングルトン / 動的 DB 接続管理 (`db`, `activeQueryClient`)
    │   │   │   ├── schema.ts     # Drizzle テーブル定義 (Single Source of Truth)
    │   │   │   └── users.test.ts # Users テーブル CRUD & Unique 制約 DB 統合テスト
    │   │   ├── errors/           # システム標準エラー構造・RFC 9457 定義 (役割ごとにファイル分割)
    │   │   │   ├── types.ts      # エラー型定義 (`ProblemDetails`, `InvalidParam`)
    │   │   │   ├── app-error.ts  # 基底例外クラス (`AppError`)
    │   │   │   ├── not-found-error.ts       # 404 例外 (`NotFoundError`)
    │   │   │   ├── internal-server-error.ts # 500 例外 (`InternalServerError`)
    │   │   │   ├── validation-error.ts      # 400 例外 (`ValidationError`)
    │   │   │   ├── unauthorized-error.ts    # 401 例外 (`UnauthorizedError`)
    │   │   │   ├── forbidden-error.ts       # 403 例外 (`ForbiddenError`)
    │   │   │   ├── index.ts      # 共通エラー一括エクスポート
    │   │   │   └── errors.test.ts# エラークラス構造化単体テスト
    │   │   ├── registry/         # 動的モジュールローダー
    │   │   │   └── hono-auto-loader.ts # Feature モジュール自動探索機能
    │   │   └── test/             # テスト自動化ライフサイクル定義
    │   │       ├── global-setup.ts# 全テスト実行前の DB スキーマ自動同期処理
    │   │       └── setup.ts      # 各テストケース実行前のデータ自動全クリーンアップ
    │   ├── package.json          # 共通基盤パッケージ用依存関係
    │   └── tsconfig.json         # 共通基盤用 TypeScript 設定
    │
    ├── ui/                       # 共有 UI コンポーネントパッケージ
    │   ├── src/
    │   │   ├── index.ts          # UI パッケージエクスポート統合
    │   │   ├── lib/
    │   │   │   └── utils.ts      # clsx + tailwind-merge による cn ユーティリティ
    │   │   ├── components/
    │   │   │   ├── button.tsx        # CVA 準拠 Button コンポーネント
    │   │   │   ├── button.test.tsx   # Button 単体テスト (コロケーション)
    │   │   │   ├── layout.tsx        # AppLayout, HeaderContent, SidebarNav コンポーネント
    │   │   │   ├── layout.test.tsx   # Layout 単体テスト (コロケーション)
    │   │   │   ├── toaster.tsx       # Sonner Toast プロバイダー & RFC 9457 エラーハンドラー
    │   │   │   └── toaster.test.tsx  # Toast & showErrorToast 単体テスト (コロケーション)
    │   │   └── test/
    │   │       └── setup.ts      # jest-dom マッチャー拡張セットアップ
    │   ├── package.json          # @app/ui 依存関係 (clsx, tailwind-merge, cva, sonner)
    │   ├── tsconfig.json         # UI パッケージ用 TS 設定 (jest-dom / vitest 型拡張)
    │   └── vite.config.ts        # UI パッケージ用 Vitest 設定
    │
    ├── plugins/                  # 切り替え可能なプラグイン群
    │   ├── auth-ad/              # Active Directory 認証連携モジュール
    │   │   ├── src/index.ts
    │   │   └── package.json
    │   └── auth-local/           # ローカルデータベース認証モジュール
    │       ├── src/
    │       │   ├── index.ts          # パッケージエントリーポイント
    │       │   ├── auth-utils.ts     # Bcrypt パスワードハッシュ化 & Jose JWT ユーティリティ
    │       │   └── auth-utils.test.ts# パスワードハッシュ・JWT 署名/検証の単体テスト
    │       └── package.json
    └── features/                 # 業務ドメイン機能モジュール群
        └── sample/               # サンプル機能モジュール
            ├── src/
            │   ├── index.ts      # `/sample` ルート定義
            │   └── index.test.ts # モジュール単体（`/sample` 応答）のテスト
            └── package.json

```

---

## 5. データベース & ORM 仕様 (Database & ORM)

### 5.1 ORM の設計と接続管理

* **型安全性の保障:** アプリケーションコードとデータベース構造の不一致を防ぐため、完全な TypeScript サポートを持つ ORM (Drizzle ORM + `postgres` ライブラリ) を採用します。
* **動的接続・マルチクライアント管理:**
`packages/core/src/db/index.ts` にて `NODE_ENV === 'test'` の条件に応じて開発用（`DATABASE_URL`）とテスト用（`TEST_DATABASE_URL`）の接続を自動切替します。また、テスト終了時にコネクションプールを正常終了できるよう `activeQueryClient` をエクスポートします。

```typescript
// packages/core/src/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';
import { env } from '../config/env';

const isTest = env.NODE_ENV === 'test';

export const queryClient = postgres(env.DATABASE_URL);
export const dev_db = drizzle(queryClient, { schema });

export const queryTestClient = postgres(env.TEST_DATABASE_URL);
export const test_db = drizzle(queryTestClient, { schema });

export const db = isTest ? test_db : dev_db;
export const activeQueryClient = isTest ? queryTestClient : queryClient;

export { schema };

```

### 5.2 スキーマ定義 (Single Source of Truth)

データベースの構造は、`packages/core/src/db/schema.ts` を正として定義します。

#### `users` テーブル

ユーザー認証、権限、およびプロファイル情報を一元管理します。

```typescript
// packages/core/src/db/schema.ts
import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  role: text('role').notNull().default('user'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

```

| カラム名 | DB論理名 | 型 | 制約 | 説明 |
| --- | --- | --- | --- | --- |
| `id` | `id` | `serial` | PRIMARY KEY | ユーザー識別子 |
| `name` | `name` | `text` | NOT NULL | ユーザー表示名 |
| `email` | `email` | `text` | NOT NULL, UNIQUE | メールアドレス（ログインID） |
| `passwordHash` | `password_hash` | `text` | NOT NULL | `bcryptjs` でハッシュ化されたパスワード |
| `role` | `role` | `text` | NOT NULL, Default: `'user'` | システム権限 (`user`, `admin` 等) |
| `createdAt` | `created_at` | `timestamp` | NOT NULL, Default: `now()` | レコード作成日時 |

### 5.3 マイグレーション & 構成ファイルの分離設計

* **マイグレーション運用:** スキーマ変更時は `drizzle-kit generate` でマイグレーションファイルを生成し、`drizzle-kit push` または `migrate` コマンドで DB に反映します。
* **構成ファイルの分離:** テスト実行時と通常開発時でデータベース設定が混同するのを防ぐため、テスト用構成は **`drizzle-test.config.ts`** と命名して管理します。

---

## 6. API & エラーレスポンス仕様 (API & Error Handling)

### 6.1 統一エラーレスポンス仕様 (RFC 9457 準拠)

エラーレスポンスの構造を統一し、クライアント側（フロントエンド）でのエラー処理を明確化するため、RFC 7807 を置き換えた最新標準である **RFC 9457 (Problem Details for HTTP APIs)** に完全準拠した構造を採用します。

無意味なダミー URI やハードコードを排除するため、特定の拡張ドキュメント URI を割り当てないエラーの `type` プロパティには、RFC 9457 の標準規格規定値である **`"about:blank"`** を一律に設定します。

| フィールド名 | キー名 | 役割・説明 | 設定例 |
| --- | --- | --- | --- |
| **エラー分類 URI** | `type` | エラーの種類を明確に識別する URI。特別な説明ドキュメントを持たない場合は `"about:blank"` | `"about:blank"` |
| **タイトル** | `title` | エラーの概要 | `"Bad Request"`, `"Unauthorized"`, `"Forbidden"`, `"Not Found"`, `"Service Unavailable"` |
| **ステータスコード** | `status` | HTTP ステータスコード | `400`, `401`, `403`, `404`, `500`, `503` |
| **詳細メッセージ** | `detail` | 発生原因の具体的な説明 | `"You do not have permission to access this resource."` |
| **発生パス** | `instance` | エラーが発生したリクエスト URI パス | `"/api/auth/login"`, `"/admin/dashboard"` |
| **フィールド別詳細** | `invalidParams` | **(任意)** 入力検証エラー時の違反項目・理由リスト | `[{ "name": "email", "reason": "Invalid syntax" }]` |

#### エラー制御方針

1. **例外クラスの階層化 (`AppError`):** ドメイン例外（`ValidationError`, `UnauthorizedError`, `ForbiddenError` 等）は基底クラス `AppError` を継承して定義し、`packages/core/src/errors/` 配下に1クラス1ファイルで管理。
2. **未定義エラーのキャッチ (500):** 予期せぬ例外は Hono の `app.onError` ハンドラを介して規格化された 500 エラー構造（`type: "about:blank"`）へ変換。
3. **入力検証エラーの標準化 (400):** Zod バリデーション失敗時は不備フィールドと理由を `invalidParams` へ自動マッピング。
4. **フロントエンド連携:** クライアント側（`apps/web/src/lib/apiClient.ts`）はエラーレスポンスを自動で RFC 9457 `ProblemDetails` オブジェクトとして抽出・パースし、`packages/ui` の `showErrorToast` と連携して適切な Toast 通知を即座にユーザーへフィードバック。

---

### 6.2 認証・認可 API 仕様 (Authentication & Authorization API Spec)

ベース URL: `/api/auth`

#### ① ログイン & トークン発行 (`POST /api/auth/login`)

* **認証:** 不要
* **リクエスト (`application/json`):**

```json
{
  "email": "test@example.com",
  "password": "password123"
}

```

* **レスポンス (200 OK):**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "test@example.com",
    "role": "user"
  }
}

```

* **エラーレスポンス (401 Unauthorized - RFC 9457):**

```json
{
  "type": "about:blank",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Invalid credentials.",
  "instance": "/api/auth/login"
}

```

#### ② 認証ユーザー情報取得 (`GET /api/auth/me`)

* **認証:** 必要 (`Authorization: Bearer <JWT_TOKEN>`)
* **レスポンス (200 OK):**

```json
{
  "user": {
    "id": 1,
    "email": "test@example.com",
    "role": "user"
  }
}

```

* **エラーレスポンス (401 Unauthorized - RFC 9457):**

```json
{
  "type": "about:blank",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Invalid credentials.",
  "instance": "/api/auth/me"
}

```

#### ③ ロールベース認可制御 (RBAC Middleware)

* **認証・認可:** 必要 (`authMiddleware` + `requireRole(['admin'])`)
* **エラーレスポンス (403 Forbidden - RFC 9457):**

```json
{
  "type": "about:blank",
  "title": "Forbidden",
  "status": 403,
  "detail": "You do not have permission to access this resource.",
  "instance": "/admin/dashboard"
}

```

---

### 6.3 ヘルスチェック & 構造化ログ仕様

#### ヘルスチェック API (`GET /healthz`)

* **役割:** API サーバーの生存確認および PostgreSQL 導通確認。
* **正常時レスポンス (200 OK):**

```json
{
  "status": "ok",
  "db": "connected"
}

```

* **DB接続障害時レスポンス (503 Service Unavailable - RFC 9457):**

```json
{
  "type": "about:blank",
  "title": "Service Unavailable",
  "status": 503,
  "detail": "Database connection failed",
  "instance": "/healthz"
}

```

#### 構造化ロギング

* **ログ出力:** 全リクエストのコンテキスト情報を構造化ログとして出力。
* **マスク処理:** `DATABASE_URL` や `JWT_SECRET` などの接続文字列・機密情報は `formatEnvForLog` を介して自動伏字化（`***`）。

---

## 7. フロントエンド状態管理 & API 通信仕様 (Frontend State & Client Spec)

### 7.1 API クライアント (`apps/web/src/lib/apiClient.ts`)

* **機能:** Fetch API のラッパーとして、HTTP リクエスト生成、共通ヘッダー設定、およびエラー判定を一元管理。
* **認証トークン自動付与:** ローカルストレージ（または認証コンテキスト）から保持中の JWT トークンを取得し、`Authorization: Bearer <token>` ヘッダーへ自動挿入。
* **RFC 9457 エラーパース:** レスポンスが `!response.ok` の場合、JSON ボディから RFC 9457 構造（`type`, `title`, `status`, `detail`, `instance`, `invalidParams`）を安全に抽出しスロー。

### 7.2 認証コンテキスト (`apps/web/src/auth/AuthContext.tsx` / `useAuth`)

* **役割:** アプリ全体のログイン状態、認証済みユーザープロファイル、JWT トークンの管理および共有。
* **提供機能:**
* `login(email, password)`: `apiClient` を介して `/api/auth/login` を実行し、受け取ったトークンとユーザー情報を保持。
* `logout()`: トークンを破棄し未認証状態へリセット。


* **初期化・自動ログイン:** アプリ起動時にローカルストレージ内のトークンを確認し、`/api/auth/me` からユーザー情報を自動復元。
* **保護ルート制御 (`apps/web/src/auth/ProtectedRoute.tsx`):**
* `useAuth` の未認証状態時はログイン画面へ安全に自動リダイレクト。
* 認証完了後はダッシュボード画面（`AppLayout`）を表示。


* **UI コンポーネント連携 (`apps/web/src/components/LoginForm.tsx`):**
* `useAuth` から `login` を呼び出し。
* 送信中のローディング状態の表示・二重送信防止。
* エラー発生時は `showErrorToast`（`packages/ui`）にエラーオブジェクトを渡し、Sonner Toast で通知。



---

## 8. セキュリティ & 環境変数仕様 (Security & Environment Variables)

### 8.1 定義されている環境変数

| 変数名 | 対象領域 | 型 / 制約 | 意図・役割 / 動的補完 |
| --- | --- | --- | --- |
| `NODE_ENV` | API | `'development'` | `'test'` | `'production'` | 実行環境の動作モード指定 |
| `PORT` | API | 数値 (デフォルト: `3001`) | API サーバーが待受を行うポート番号 |
| `API_BASE_URL` | API | URL形式文字列 (オプショナル) | API のベース URL。未定義の場合は `PORT` の値から `http://localhost:${PORT}` を Zod transform により自動生成 |
| `CORS_ORIGIN` | API | 文字列 (オプショナル) | バックエンドで許可する Cross-Origin。未定義の場合は `http://localhost:${DEFAULT_FRONTEND_PORT}` (3000) を自動補完設定 |
| `DATABASE_URL` | API | URL形式文字列 | 開発・本番データベースへの接続 URI |
| `TEST_DATABASE_URL` | API | URL形式文字列 | テスト専用データベースへの接続 URI |
| `JWT_SECRET` | API | 32文字以上の文字列 | JWT アクセストークンの署名・検証に使用するシークレットキー |
| `VITE_PORT` | Web | 数値・文字列 | 開発用 Web サーバーの待受ポート |
| `VITE_API_TARGET_URL` | Web | URL形式文字列 | 開発時の API 転送先 (DevProxy ターゲット) |
| `VITE_APP_TITLE` | Web | 文字列 | アプリケーションの表示タイトル |

### 8.2 セキュリティ設計

1. **フェイルファスト（Fail-Fast）原則:** 起動時に Zod で環境変数を検証し、不備があれば即座に起動を停止。
2. **`API_BASE_URL` の動的連動:** ハードコードを排除し、環境変数または `PORT` から動的に計算されたベース URL を使用。
3. **ログマスク処理:** 接続パスワード等を含む文字列（`DATABASE_URL`, `TEST_DATABASE_URL`）はシステムログ出力時に自動でマスク（`***` 化）。
4. **パスワードハッシュ & トークン:** 平文保存を禁止し、`bcryptjs` でハッシュ化。トークン生成には `jose` を使用。
5. **権制度制御（RBAC）:** ロールベースアクセス制御 (`requireRole`) により、無効または権限不足のリクエストに対して 403 Forbidden（RFC 9457）を厳格に返却。
6. **曖昧なエラーメッセージ:** ログイン失敗時は理由を区別せず一律 `Invalid credentials.` (401) を返却し、アカウント列挙攻撃を防止。
7. **CORS & クライアント環境変数:** Web アプリからの Cross-Origin リクエストは `apps/api/src/index.ts` の `cors()` ミドルウェアにて `env.CORS_ORIGIN` を参照して安全に許可。ブラウザ公開環境変数は `VITE_` プレフィックスに限定し `apps/web/src/env.ts` 経由でカプセル化。

---

## 9. 動的モジュール読み込み仕様 (Dynamic Auto-Loader)

### 9.1 機能の自動検出とルーティング登録

* 各 Feature パッケージが持つ API ルート（Hono インスタンス）を個別に手動インポートする手間を省くため、指定ディレクトリ配下のモジュールを動的に探索・一括登録する自動ローダー機構（`hono-auto-loader.ts`）を導入します。

### 9.2 クロスプラットフォーム＆モジュール互換性の保障

* OS 間（Windows / Linux / macOS）のファイルパス記法差異や、ビルドツール（Vite / Node.js ESM）の URL 解釈エラーを回避するため、`pathToFileURL` を用いて変換します。

```typescript
// packages/core/src/registry/hono-auto-loader.ts
const absolutePath = path.resolve(file);
const moduleUrl = pathToFileURL(absolutePath).href; // URI形式へ安全に変換
const module = await import(/* @vite-ignore */ moduleUrl); // 不要な静的解析警告を抑止

```

---

## 10. テストアーキテクチャ & ライフサイクル (Testing Architecture)

テストの信頼性と再現性を維持するため、**「テスト実行時の環境の自動セットアップ」** と **「テストケース間の相互干渉防止」**、および **「コロケーション（同一ディレクトリ）テスト配置」** を導入しています。

### 10.1 テスト基盤と疎結合アサーション

* **テストランナー:** Vitest（高速なインメモリ実行およびモジュール連携環境を提供）
* **テスト配置方針（コロケーション）:** UI コンポーネントおよび個別のユニットモジュールに対するテストコードは、実装ファイルと同じディレクトリに併設（例: `apiClient.ts` と `apiClient.test.ts`）。リファクタリング時の影響範囲を限定化します。
* **モックの適切なクリーンアップ:** 各テスト実行前に `beforeEach` で `vi.restoreAllMocks()` / `vi.clearAllMocks()` を実行し、モックの状態リークを防止。
* **疎結合アサーション方針:** テストコードがプロダクトコードの内部実装（ドキュメント URL 構造等）に過剰に結合するのを防ぐため、アサーションには `toMatchObject` または正確なエラー構造の同一性検証を用い、脆いテスト（Fragile Test）化を防止します。

### 10.2 テスト自動化ライフサイクル

1. **テスト開始前の DB スキーマ自動同期 (Global Setup):**
全テスト実行直前に `globalSetup` が `drizzle-test.config.ts` を用いてテスト用 DB（`TEST_DATABASE_URL`）のスキーマを自動同期。
2. **テストケース間の完全な状態隔離 (Setup Files):**
各テスト実行直前に `packages/core/src/test/setup.ts` 等でデータベース内のデータを自動一括消去。
3. **DOM マッチャーの型拡張:**
フロントエンドテスト（`apps/web`, `packages/ui`）では `@testing-library/jest-dom` および `@testing-library/user-event` を読み込み、`toBeInTheDocument` や `toBeDisabled` などの標準 DOM アサーションを完全型安全に利用可能化。
4. **テスト終了後のコネクション安全開放:**
各 DB 統合テストの `afterAll` フックにて `activeQueryClient.end()` を呼び出し、PostgreSQL コネクションの切り忘れを防止。

---

## 11. 実行スクリプト リファレンス (Scripts)

プロジェクト内で利用する標準的なコマンドです。

### 11.1 開発サーバー起動

すべてのアプリケーション（API・Web）を開発モードで並行起動します。

```bash
npm run dev

```

### 11.2 全テストの自動実行 (TDD)

すべてのパッケージの単体テスト、DB 連携テスト、ミドルウェア・API 統合テスト、UI コンポーネントテストを一括実行します。

```bash
npm test

```

### 11.3 テスト用 DB スキーマの手動同期

テスト環境のデータベース構造を手動で最新状態へ更新したい場合に実行します。

```bash
npm run db:push:test

```
EOF_1787016563_11220

echo "作成: .env"
cat << 'EOF_1787016563_28092' > ".env"
# バックエンド用
PORT=3001
API_BASE_URL=http://localhost:3001
DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db
TEST_DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db_test
JWT_SECRET=your-super-secret-jwt-key-must-be-at-least-32-bytes-long
TZ=Asia/Tokyo

# フロントエンド用 (VITE_ プレフィックスを付ける)
# /workspace/apps/web/src/env.ts と同期する
VITE_PORT=3000
VITE_API_TARGET_URL=http://127.0.0.1:3001
VITE_APP_TITLE=マイアプリケーション
EOF_1787016563_28092

echo -e "\n復元が完了しました！"
