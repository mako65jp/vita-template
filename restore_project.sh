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
cat << 'EOF_1785802053_12200' > "package.json"
{
  "name": "devcontainer-monorepo",
  "private": true,
  "type": "module",
  "workspaces": [
    "apps/*",
    "packages/*",
    "packages/plugins/*",
    "packages/features/*"
  ],
  "scripts": {
    "start": "concurrently \"npm run dev:api\" \"npm run dev:web\"",
    "dev": "npm start",
    "dev:api": "npm --workspace=apps/api run dev",
    "dev:web": "npm --workspace=apps/web run dev",
    "build": "npm run build --workspaces",
    "test": "vitest run",
    "db:push": "npm run db:push --workspaces --if-present",
    "db:push:test": "npm run db:push:test --workspaces --if-present",
    "db:push:all": "npm run db:push:all --workspaces --if-present"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^6.0.5",
    "concurrently": "^8.2.2",
    "typescript": "^5.3.3",
    "vite": "^8.2.0",
    "vitest": "^4.1.10"
  },
  "dependencies": {
    "@hono/node-server": "^2.0.5",
    "drizzle-orm": "^0.45.2"
  }
}
EOF_1785802053_12200

echo "作成: .gitignore"
cat << 'EOF_1785802053_6735' > ".gitignore"
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
EOF_1785802053_6735

echo "作成: plan.md"
cat << 'EOF_1785802053_13186' > "plan.md"
# 📋 共通ひな形機能 一覧表

### 凡例（記号の定義）
* **機能優先順位 (Application Need):** 
  * 🔴 **高 (必須):** ほぼ100%のアプリで開発最初期に必要なコア機能
  * 🟡 **中 (標準):** 多くのWebアプリで運用や保守に必要な推奨機能
  * 🟢 **低 (拡張):** 特定の要件（ファイル扱う、メール送る等）に応じて使う機能
* **TDD優先順位 (Test-Driven Order):** 
  * **【Step 1〜8】:** テストの書きやすさ・依存関係（土台から作る）に基づいた推奨実装順

---

| 機能名 | 機能概要 | 担当パッケージ | 機能優先順位 | TDD優先順位 | TDDでの進め方・テストのポイント |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **統一エラーハンドリング** | Hono `app.onError` / RFC 7807 準拠のエラーレスポンス規格化 | `apps/api`<br>`packages/core` | 🔴 **高** | **Step 1** | 外部依存がなく最初に着手。意図的に例外を発生させ、期待通りの JSON 構造とステータスコードが返るかを単体テスト。 |
| **Zod リクエスト検証** | `@hono/zod-validator` による型安全な入力チェック・エラー返却 | `apps/api`<br>`packages/core` | 🔴 **高** | **Step 2** | 不正なリクエスト payload を投げた際に、400 エラーと詳細な検証メッセージが返るかのテストを書いてからルーティングを実装。 |
| **DB スキーマ & ORM** | Drizzle / Prisma 導入、マイグレーション、テスト用シード自動化 | `apps/api`<br>`packages/core` | 🔴 **高** | **Step 3** | テスト用 DB に対して、CRUD 操作やトランザクションが正しく動くかDB統合テストを記述。（後のAPIテストの土台になる） |
| **認証・認可基盤 (Auth)** | JWT / Cookie ハンドリング、パスワードハッシュ化、RBAC（権限制御） | `packages/plugins/auth-*`<br>`apps/api` | 🔴 **高** | **Step 4** | 無効なトークンや権限不足で 401/403 が返るか、正しくコンテキストにユーザー情報が注入されるかをミドルウェア単位でテスト。 |
| **構造化ロギング & ヘルス** | Pino 等による JSON ログ、機密情報マスク、`/healthz` エンドポイント | `apps/api` | 🟡 **中** | **Step 5** | 秘密情報がマスクされるか、DB接続切断時に `/healthz` が 503 を返すかをテスト。 |
| **UI 基本コンポーネント** | Shadcn UI / Tailwind 導入、共通 Layout、Error Boundary、Toast | `apps/web`<br>`packages/ui` | 🟡 **中** | **Step 6** | Vitest + React Testing Library を使い、共通コンポーネントのレンダリングやエラー表示の操作発火テストを記述。 |
| **ストレージ抽象化** | ローカル / S3 (MinIO) を環境変数で切り替え可能なファイル保存機能 | `packages/core`<br>`apps/api` | 🟢 **低** | **Step 7** | モック（S3クライアントの抽象化インターフェース）を用いて、ファイル保存・取得・バリデーション処理をテスト。 |
| **メール・通知基盤** | Nodemailer / Resend 連携、HTML メールテンプレート生成機能 | `packages/core` | 🟢 **低** | **Step 8** | 実際にはメールを送信せず、生成される HTML 文言やプロバイダー呼び出しの引数が正しいかを単体テスト。 |

---

### 💡 2つの優先順位がずれる理由（ポイント）

1. **「認証機能」はアプリ機能としては最優先（🔴高）だが、TDD順序では【Step 4】**
   * 認証ロジックのテストを書くには、事前に入力バリデーション（Step 2）や DB へのユーザー保存（Step 3）のテスト環境が整っている必要があるためです。
2. **「ログ・ヘルスチェック」はアプリ機能としては運用向け（🟡中）だが、TDD順序では【Step 5】**
   * API と DB の基礎テスト環境が完成した直後に組み込むことで、後続の複雑なドメイン開発時のデバッグが格段に楽になります。
EOF_1785802053_13186

mkdir -p ".devcontainer/scripts"
echo "作成: .devcontainer/scripts/init-test-db.sh"
cat << 'EOF_1785802053_26952' > ".devcontainer/scripts/init-test-db.sh"
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE $POSTGRES_DB_TEST;
EOSQL
EOF_1785802053_26952

mkdir -p ".devcontainer"
echo "作成: .devcontainer/Dockerfile"
cat << 'EOF_1785802053_17635' > ".devcontainer/Dockerfile"
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>
EOF_1785802053_17635

mkdir -p ".devcontainer"
echo "作成: .devcontainer/devcontainer.json"
cat << 'EOF_1785802053_20918' > ".devcontainer/devcontainer.json"
{
  "name": "Monorepo DevContainer with DB",
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspace",
  "customizations": {
    "vscode": {
      "settings": {
        "typescript.tsdk": "node_modules/typescript/lib",
        "editor.formatOnSave": true,
        "vitest.enable": true
      },
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode",
        "prisma.prisma",
        "vitest.explorer"
      ]
    }
  },
  "forwardPorts": [3000, 3001, 5432],
  "updateContentCommand": "sudo chown -R node:node /workspace && npm install"
}
EOF_1785802053_20918

mkdir -p ".devcontainer"
echo "作成: .devcontainer/docker-compose.yml"
cat << 'EOF_1785802053_30357' > ".devcontainer/docker-compose.yml"


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
      - "3000:3000"
      - "3001:3001"
    environment:
      DATABASE_URL: "postgresql://postgres:postgres@db:5432/app_db"
      DATABASE_URL_TEST: "postgresql://postgres:postgres@db:5432/app_db_test"
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
EOF_1785802053_30357

echo "作成: tsconfig.json"
cat << 'EOF_1785802053_6664' > "tsconfig.json"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "noEmit": true,
    "lib": [
      "ES2022",
      "DOM",
      "DOM.Iterable"
    ],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "baseUrl": ".",
    "paths": {
      "@app/core/*": [
        "packages/core/src/*"
      ],
      "@app/plugins/*": [
        "packages/plugins/*"
      ],
      "@app/features/*": [
        "packages/features/*"
      ]
    }
  },
  "exclude": [
    "node_modules",
    "dist"
  ]
}
EOF_1785802053_6664

echo "作成: vitest.config.ts"
cat << 'EOF_1785802053_13508' > "vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
  resolve: {
    tsconfigPaths: true
  },
  test: {
    globals: true,
    environment: 'node',
    reporters: ['tree'],
  },
});
EOF_1785802053_13508

mkdir -p "packages/plugins/auth-ad"
echo "作成: packages/plugins/auth-ad/package.json"
cat << 'EOF_1785802053_8850' > "packages/plugins/auth-ad/package.json"
{
  "name": "@app/plugins-auth-ad",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785802053_8850

mkdir -p "packages/plugins/auth-ad/src"
echo "作成: packages/plugins/auth-ad/src/index.ts"
cat << 'EOF_1785802053_2500' > "packages/plugins/auth-ad/src/index.ts"
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
EOF_1785802053_2500

mkdir -p "packages/plugins/auth-local"
echo "作成: packages/plugins/auth-local/package.json"
cat << 'EOF_1785802053_15476' > "packages/plugins/auth-local/package.json"
{
  "name": "@app/plugins-auth-local",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785802053_15476

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/index.ts"
cat << 'EOF_1785802053_31177' > "packages/plugins/auth-local/src/index.ts"
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
EOF_1785802053_31177

mkdir -p "packages/core"
echo "作成: packages/core/package.json"
cat << 'EOF_1785802053_29981' > "packages/core/package.json"
{
  "name": "@app/core",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "db:push": "drizzle-kit push",
    "db:push:test": "drizzle-kit push --config=drizzle-test.config.ts",
    "db:push:all": "npm run db:push && npm run db:push:test"
  },
  "main": "./src/index.ts",
  "dependencies": {
    "drizzle-orm": "^0.45.2",
    "glob": "^13.0.6",
    "hono": "^4.0.0",
    "postgres": "^3.4.9",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "drizzle-kit": "^0.31.10"
  }
}
EOF_1785802053_29981

mkdir -p "packages/core"
echo "作成: packages/core/drizzle-test.config.ts"
cat << 'EOF_1785802053_6047' > "packages/core/drizzle-test.config.ts"
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
    // スキーマファイルの場所
    schema: './src/db/schema.ts',

    // マイグレーションファイルの出力先（push の場合は参照のみ）
    out: './drizzle',

    // 使用する DB ドライバー
    dialect: 'postgresql',

    // 接続情報（.env から読み込み）
    dbCredentials: {
        url: process.env.TEST_DATABASE_URL || 'postgresql://postgres:postgres@db:5432/app_db_test',
    },
});
EOF_1785802053_6047

mkdir -p "packages/core"
echo "作成: packages/core/vitest.config.ts"
cat << 'EOF_1785802053_4240' > "packages/core/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    test: {
        globalSetup: ['./src/test/global-setup.ts'], // ① テスト前に自動で db:push:test
        setupFiles: ['./src/test/setup.ts'],         // ② 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1785802053_4240

mkdir -p "packages/core/src/registry"
echo "作成: packages/core/src/registry/hono-auto-loader.ts"
cat << 'EOF_1785802053_32620' > "packages/core/src/registry/hono-auto-loader.ts"
import { Hono } from 'hono';
import { glob } from 'glob';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

export async function loadFeatureModules(app: Hono, pattern: string) {
  const files = await glob(pattern);
  for (const file of files) {
    const absolutePath = path.resolve(file);

    // 💡 pathToFileURL を使って安全な file:// URL を生成
    const moduleUrl = pathToFileURL(absolutePath).href;
    // const module = await import(/* @vite-ignore */ moduleUrl);
    const module = await import(moduleUrl);

    if (module.default && typeof module.default === 'function') {
      const route = module.default();
      app.route('/', route);
      console.log(`[Auto-Loader] Loaded Feature module: ${file}`);
    }
  }
}
EOF_1785802053_32620

mkdir -p "packages/core/src"
echo "作成: packages/core/src/index.ts"
cat << 'EOF_1785802053_10937' > "packages/core/src/index.ts"
export * from './auth/auth-registry';
export * from './registry/hono-auto-loader';
export * from './db/client';
export * from './config/env';
export * from './errors/index';
EOF_1785802053_10937

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.test.ts"
cat << 'EOF_1785802053_12254' > "packages/core/src/config/env.test.ts"
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { validateEnv, formatEnvForLog } from './env';


describe('Environment Variables Validation', () => {
    const originalEnv = process.env;

    beforeEach(() => {
        // テストごとに process.env を分離・復元できるようにクローン
        process.env = { ...originalEnv };
    });

    afterEach(() => {
        process.env = originalEnv;
    });

    it('正しい環境変数が渡された場合、検証済みオブジェクトを返すこと', () => {
        process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/app_db';
        process.env.PORT = '3001';
        process.env.NODE_ENV = 'development';

        const env = validateEnv(process.env);

        expect(env.DATABASE_URL).toBe('postgresql://postgres:postgres@localhost:5432/app_db');
        expect(env.PORT).toBe(3001); // 文字列から数値へ変換されること
        expect(env.NODE_ENV).toBe('development');
    });

    it('PORT が指定されていない場合、デフォルト値 3001 を使用すること', () => {
        process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/app_db';
        delete process.env.PORT;

        const env = validateEnv(process.env);

        expect(env.PORT).toBe(3001);
    });

    it('DATABASE_URL が存在しない場合、エラーをスローすること', () => {
        delete process.env.DATABASE_URL;

        expect(() => validateEnv(process.env)).toThrowError('環境変数の検証に失敗しました');
    });

    it('PORT に数値以外の文字列が渡された場合、エラーをスローすること', () => {
        process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/app_db';
        process.env.PORT = 'not-a-number';

        expect(() => validateEnv(process.env)).toThrowError();
    });
});

describe('formatEnvForLog', () => {
    it('DATABASE_URL などのパスワード部分がマスク処理されて文字列化されること', () => {
        const mockEnv = {
            NODE_ENV: 'development' as const,
            PORT: 3001,
            DATABASE_URL: 'postgresql://postgres:secret_pass@localhost:5432/app_db',
        };

        const formatted = formatEnvForLog(mockEnv);

        // ダブルクォーテーション付きの "PORT": 3001 を検証
        expect(formatted).toContain('"PORT": 3001');
        expect(formatted).not.toContain('secret_pass'); // パスワードが露出していないこと
        expect(formatted).toContain('***'); // マスクされていること
    });
});
EOF_1785802053_12254

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.ts"
cat << 'EOF_1785802053_10156' > "packages/core/src/config/env.ts"
import { z } from 'zod';

// ==========================================
// 1. バックエンド用 (Node.js) スキーマ & 関数
// ==========================================
export const envSchema = z.object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    PORT: z.coerce.number().default(3001),
    DATABASE_URL: z.string().url({ message: 'DATABASE_URL は有効なURL形式である必要があります' }),
});

export type Env = z.infer<typeof envSchema>;

export function validateEnv(targetEnv: Record<string, string | undefined> = process.env): Env {
    const result = envSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        console.error('❌ 無効な環境変数があります:\n', formattedErrors);
        throw new Error(`環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

/**
 * ログ出力用に環境変数を整形（パスワード等はマスク）する関数
 */
export function formatEnvForLog(envObj: Env): string {
    const maskedEnv = { ...envObj };

    if (maskedEnv.DATABASE_URL) {
        maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL.replace(
            /:\/\/(.*):(.*)@/,
            '://$1:***@'
        );
    }

    return JSON.stringify(maskedEnv, null, 2);
}

// ⚠️ トップレベルで validateEnv() を直接実行するのではなく、
// ブラウザ環境（typeof window !== 'undefined'）では参照しない安全なガードを入れる
export const env: Env = typeof window !== 'undefined'
    ? ({} as Env)
    : (process.env.NODE_ENV === 'test'
        ? (process.env as unknown as Env)
        : validateEnv());


// ==========================================
// 2. フロントエンド用 (Vite / Browser) スキーマ
// ==========================================
export const clientEnvSchema = z.object({
    VITE_PORT: z.string().optional().default('3000'),
    VITE_API_TARGET_URL: z.string().url().optional().default('http://127.0.0.1:3001'),
    VITE_APP_TITLE: z.string().optional().default('My App'),
});

export type ClientEnv = z.infer<typeof clientEnvSchema>;
EOF_1785802053_10156

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/index.ts"
cat << 'EOF_1785802053_10893' > "packages/core/src/db/index.ts"
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';
import { validateEnv } from '../config/env';

const env = validateEnv();

// PostgreSQL 接続クライアントの作成
const queryClient = postgres(env.DATABASE_URL);
export const db = drizzle(queryClient, { schema });
EOF_1785802053_10893

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/db.test.ts"
cat << 'EOF_1785802053_10155' > "packages/core/src/db/db.test.ts"
import { describe, it, expect } from 'vitest';
import { db } from './index';
import { users } from './schema';
import { eq } from 'drizzle-orm';

describe('DB Integration Test (Step 3)', () => {
    it('ユーザーテーブルにデータを挿入し、取得できること', async () => {
        const testEmail = `test-${Date.now()}@example.com`;

        // 1. レコード挿入 (Create)
        const [insertedUser] = await db
            .insert(users)
            .values({
                name: 'Test User',
                email: testEmail,
            })
            .returning();

        expect(insertedUser).toBeDefined();
        expect(insertedUser.name).toBe('Test User');
        expect(insertedUser.email).toBe(testEmail);

        // 2. レコード取得 (Read)
        const [fetchedUser] = await db
            .select()
            .from(users)
            .where(eq(users.id, insertedUser.id));

        expect(fetchedUser).toBeDefined();
        expect(fetchedUser.email).toBe(testEmail);
    });
});
EOF_1785802053_10155

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/schema.ts"
cat << 'EOF_1785802053_30784' > "packages/core/src/db/schema.ts"
// 例: pgTable に新しいカラムを追加
import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
    id: serial('id').primaryKey(),
    name: text('name').notNull(),
    email: text('email').notNull().unique(),
    createdAt: timestamp('created_at').defaultNow().notNull(),
});
EOF_1785802053_30784

mkdir -p "packages/core/src/auth"
echo "作成: packages/core/src/auth/auth-registry.ts"
cat << 'EOF_1785802053_28725' > "packages/core/src/auth/auth-registry.ts"
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
EOF_1785802053_28725

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/index.ts"
cat << 'EOF_1785802053_16160' > "packages/core/src/errors/index.ts"
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

export class NotFoundError extends AppError {
    constructor(message = 'The requested resource was not found') {
        super(404, 'not-found', 'Not Found', message);
    }
}

export class InternalServerError extends AppError {
    constructor(message = 'An unexpected error occurred') {
        super(500, 'internal-server-error', 'Internal Server Error', message);
    }
}

export class ValidationError extends AppError {
    constructor(
        public readonly invalidParams: InvalidParam[],
        message = 'Validation failed for the request payload'
    ) {
        super(400, 'validation-error', 'Bad Request', message);
    }
}
EOF_1785802053_16160

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/setup.ts"
cat << 'EOF_1785802053_16951' > "packages/core/src/test/setup.ts"
import { beforeEach } from 'vitest';
import { db } from '../db'; // テスト用DBに接続しているDrizzleインスタンス
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
EOF_1785802053_16951

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/global-setup.ts"
cat << 'EOF_1785802053_13290' > "packages/core/src/test/global-setup.ts"
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

    try {
        execSync('npx drizzle-kit push --config=drizzle-test.config.ts', {
            cwd: corePackageDir,
            stdio: 'inherit',
        });
        console.log('✅ テスト用データベースの準備完了!\n');
    } catch (error) {
        console.error('❌ テスト用データベースへのスキーマ反映に失敗しました:', error);
        throw error;
    }
}
EOF_1785802053_13290

mkdir -p "packages/core"
echo "作成: packages/core/drizzle.config.ts"
cat << 'EOF_1785802053_25' > "packages/core/drizzle.config.ts"
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
    // スキーマファイルの場所
    schema: './src/db/schema.ts',

    // マイグレーションファイルの出力先（push の場合は参照のみ）
    out: './drizzle',

    // 使用する DB ドライバー
    dialect: 'postgresql',

    // 接続情報（.env から読み込み）
    dbCredentials: {
        url: process.env.DATABASE_URL || 'postgresql://postgres:postgres@db:5432/app_db_test',
    },
});
EOF_1785802053_25

mkdir -p "packages/features/sample"
echo "作成: packages/features/sample/package.json"
cat << 'EOF_1785802053_27357' > "packages/features/sample/package.json"
{
  "name": "@app/features-sample",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785802053_27357

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.ts"
cat << 'EOF_1785802053_17817' > "packages/features/sample/src/index.ts"
import { Hono } from 'hono';

export default function createSampleFeature() {
  const app = new Hono();

  app.get('/sample', (c) => {
    return c.json({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });

  return app;
}
EOF_1785802053_17817

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.test.ts"
cat << 'EOF_1785802053_25221' > "packages/features/sample/src/index.test.ts"
import { describe, it, expect } from 'vitest';
import createSampleFeature from './index';

describe('Sample Feature API', () => {
  it('GET /sample should return 200 and json message', async () => {
    const app = createSampleFeature();
    const res = await app.request('/sample');

    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body).toEqual({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });
});
EOF_1785802053_25221

echo "作成: doc.md"
cat << 'EOF_1785802053_7783' > "doc.md"
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
EOF_1785802053_7783

mkdir -p "apps/web"
echo "作成: apps/web/package.json"
cat << 'EOF_1785802053_3245' > "apps/web/package.json"
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
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.55",
    "@types/react-dom": "^18.2.19",
    "@vitejs/plugin-react": "^6.0.5",
    "typescript": "^5.3.3"
  }
}
EOF_1785802053_3245

mkdir -p "apps/web"
echo "作成: apps/web/index.html"
cat << 'EOF_1785802053_6407' > "apps/web/index.html"
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
EOF_1785802053_6407

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.json"
cat << 'EOF_1785802053_8301' > "apps/web/tsconfig.json"
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "composite": true,
    "jsx": "react-jsx",
    "useDefineForClassFields": true,
    "allowJs": false,
    "allowSyntheticDefaultImports": true,
    /* モノレポ内の共通パッケージ・型定義へのエイリアス設定 */
    "baseUrl": ".",
    "paths": {
      "@/*": [
        "./src/*"
      ],
      "@app/core/*": [
        "../../packages/core/src/*"
      ]
    }
  },
  "include": [
    "src"
  ],
  "references": [
    {
      "path": "./tsconfig.node.json"
    }
  ]
}
EOF_1785802053_8301

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.node.json"
cat << 'EOF_1785802053_12768' > "apps/web/tsconfig.node.json"
{
    "compilerOptions": {
        "composite": true,
        "skipLibCheck": true,
        "module": "ESNext",
        "moduleResolution": "bundler",
        "allowSyntheticDefaultImports": true
    },
    "include": [
        "vite.config.ts"
    ]
}
EOF_1785802053_12768

mkdir -p "apps/web/src"
echo "作成: apps/web/src/main.tsx"
cat << 'EOF_1785802053_20025' > "apps/web/src/main.tsx"
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF_1785802053_20025

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.tsx"
cat << 'EOF_1785802053_4683' > "apps/web/src/components/LoginForm.tsx"
import React, { useState } from 'react';

export const LoginForm: React.FC = () => {
  // ... (省略)
};
EOF_1785802053_4683

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.tsx"
cat << 'EOF_1785802053_19271' > "apps/web/src/App.tsx"
import React from 'react';
import { env } from './env';
import { LoginForm } from './components/LoginForm.tsx';

export default function App() {
  return (
    <div>
      <h1>DevContainer + Docker Compose {env.VITE_APP_TITLE}</h1>
      <LoginForm />
    </div>
  );
}
EOF_1785802053_19271

mkdir -p "apps/web/src"
echo "作成: apps/web/src/env.ts"
cat << 'EOF_1785802053_17712' > "apps/web/src/env.ts"
import { clientEnvSchema, type ClientEnv } from '@app/core/config/env';

// Vite の import.meta.env を Zod で検証・補完
export const env: ClientEnv = clientEnvSchema.parse({
    VITE_PORT: import.meta.env.VITE_PORT,
    VITE_API_TARGET_URL: import.meta.env.VITE_API_TARGET_URL,
    VITE_APP_TITLE: import.meta.env.VITE_APP_TITLE,
});
EOF_1785802053_17712

mkdir -p "apps/web"
echo "作成: apps/web/vite.config.ts"
cat << 'EOF_1785802053_13104' > "apps/web/vite.config.ts"
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig(({ mode }) => {
    // モノレポのルート直下（../../）にある .env ファイルをロード
    const envDir = path.resolve(import.meta.dirname, '../../');
    const env = loadEnv(mode, envDir, '');

    // ポート番号やプロキシ先を環境変数から取得（フォールバック付き）
    const webPort = parseInt(env.VITE_PORT || '3000', 10);
    const apiTarget = env.VITE_API_TARGET_URL || 'http://127.0.0.1:3001';

    return {
        // Vite が .env ファイルを探すディレクトリを指定
        envDir,

        plugins: [react()],
        resolve: {
            tsconfigPaths: true
        },

        server: {
            host: '0.0.0.0',
            port: webPort,
            proxy: {
                '/api': apiTarget,
                '/sample': apiTarget,
            },
        },
    };
});
EOF_1785802053_13104

mkdir -p "apps/api"
echo "作成: apps/api/package.json"
cat << 'EOF_1785802053_26756' > "apps/api/package.json"
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
EOF_1785802053_26756

mkdir -p "apps/api"
echo "作成: apps/api/tsconfig.json"
cat << 'EOF_1785802053_28657' > "apps/api/tsconfig.json"
{
    "extends": "../../tsconfig.json",
    "compilerOptions": {
        "module": "NodeNext",
        "moduleResolution": "NodeNext",
        "target": "ES2022",
        "outDir": "./dist",
        "rootDir": "./src",
        "types": [
            "node"
        ]
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1785802053_28657

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.ts"
cat << 'EOF_1785802053_6723' > "apps/api/src/index.ts"
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { validateEnv, formatEnvForLog } from '@app/core/config/env';
import { AppError, ProblemDetails, ValidationError } from '@app/core/errors/index';
import { loadFeatureModules } from '@app/core/registry/hono-auto-loader';
import { AuthRegistry } from '@app/core/auth/auth-registry';
import { LocalAuthPlugin } from '@app/plugins/auth-local/src/index';
import { ActiveDirectoryAuthPlugin } from '@app/plugins/auth-ad/src/index';
import authRouter from './routes/auth';

// 1. 起動時に環境変数を検証・取得
const env = validateEnv();

// 2. コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
if (process.env.NODE_ENV !== 'test') {
    console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog(env));
}

// 3. プラグインの登録
AuthRegistry.register(new LocalAuthPlugin());
AuthRegistry.register(new ActiveDirectoryAuthPlugin());

const app = new Hono();

// -----------------------------------------------------------------------------
// テスト専用ルート (NODE_ENV === 'test' の場合のみ有効化)
// -----------------------------------------------------------------------------
if (process.env.NODE_ENV === 'test') {
    app.get('/test/error', () => {
        throw new Error('Test internal error');
    });
}

// -----------------------------------------------------------------------------
// ルーティング・モジュール読み込み
// -----------------------------------------------------------------------------
app.route('/api/auth', authRouter);
await loadFeatureModules(app, 'packages/features/*/src/index.ts');

// -----------------------------------------------------------------------------
// テスト専用バリデーションルート (NODE_ENV === 'test' の場合のみ)
// -----------------------------------------------------------------------------
if (process.env.NODE_ENV === 'test') {
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
// 404 Not Found ハンドラー (RFC 7807 形式)
// -----------------------------------------------------------------------------
app.notFound((c) => {
    const problem: ProblemDetails = {
        type: 'https://api.example.com/errors/not-found',
        title: 'Not Found',
        status: 404,
        detail: 'The requested resource was not found',
        instance: c.req.path,
    };
    return c.json(problem, 404);
});

// -----------------------------------------------------------------------------
// 共通エラーハンドラー (app.onError - RFC 7807 形式)
// -----------------------------------------------------------------------------
app.onError((err, c) => {
    if (process.env.NODE_ENV !== 'test') {
        console.error(`[Error] ${c.req.method} ${c.req.path}:`, err);
    }

    let status = 500;
    let type = 'https://api.example.com/errors/internal-server-error';
    let title = 'Internal Server Error';
    let detail = 'An unexpected error occurred';
    let invalidParams: any = undefined;

    if (err instanceof AppError) {
        status = err.status;
        type = `https://api.example.com/errors/${err.code}`;
        title = err.title;
        detail = err.message;

        // ValidationError の場合は invalidParams を抽出
        if (err instanceof ValidationError) {
            invalidParams = err.invalidParams;
        }
    }

    const problem: ProblemDetails = {
        type,
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

// 💡 テスト環境（NODE_ENV === 'test'）以外の場合のみ、実際の HTTP サーバーを起動する
if (process.env.NODE_ENV !== 'test') {
    console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);
    serve({
        fetch: app.fetch,
        port,
        hostname: '0.0.0.0',
    });
}

export default app;
EOF_1785802053_6723

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.test.ts"
cat << 'EOF_1785802053_1935' > "apps/api/src/index.test.ts"
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import app from './index';
import { validateEnv } from './env';

describe('API Server Integration Tests', () => {
    it('正しい環境変数がセットされている場合、アプリが正常にルーティング応答すること', async () => {
        // 静的にインポートした app をそのまま利用できます
        const res = await app.request('/sample');
        expect(res.status).toBe(200);

        const body = await res.json();
        expect(body).toEqual({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
    });
});

describe('Environment Variable Validation', () => {
    const originalEnv = process.env;

    beforeEach(() => {
        process.env = { ...originalEnv };
    });

    afterEach(() => {
        process.env = originalEnv;
    });

    it('DATABASE_URL が存在しない場合、検証関数が例外をスローすること', () => {
        delete process.env.DATABASE_URL;

        // モジュールの再読み込みではなく、純粋な関数として例外発生を検証
        expect(() => {
            validateEnv(process.env);
        }).toThrow('環境変数の検証に失敗しました');
    });

    it('必要な環境変数が揃っている場合、正常にオブジェクトが返ること', () => {
        const mockEnv = {
            DATABASE_URL: 'postgresql://postgres:postgres@localhost:5432/app_db',
            PORT: '3001',
        };

        expect(() => validateEnv(mockEnv)).not.toThrow();
    });
});

describe('API Error Handling (RFC 7807)', () => {
    it('未定義のルートにアクセスした場合、404エラーがRFC7807形式で返ること', async () => {
        const res = await app.request('/api/non-existent-route');
        expect(res.status).toBe(404);

        const body = await res.json();
        expect(body).toEqual({
            type: 'https://api.example.com/errors/not-found',
            title: 'Not Found',
            status: 404,
            detail: 'The requested resource was not found',
            instance: '/api/non-existent-route',
        });
    });

    it('意図しないサーバー内部エラーが発生した場合、500エラーが共通形式で返ること', async () => {
        const res = await app.request('/test/error');
        expect(res.status).toBe(500);

        const body = await res.json();
        expect(body).toEqual({
            type: 'https://api.example.com/errors/internal-server-error',
            title: 'Internal Server Error',
            status: 500,
            detail: 'An unexpected error occurred',
            instance: '/test/error',
        });
    });
});

describe('Zod Request Validation (Step 2)', () => {
    it('リクエストBodyが不正な場合、400エラーと詳細なフィールドエラー情報がRFC7807形式で返ること', async () => {
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

        const body = await res.json();
        expect(body).toMatchObject({
            type: 'https://api.example.com/errors/validation-error',
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
EOF_1785802053_1935

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.ts"
cat << 'EOF_1785802053_1659' > "apps/api/src/routes/auth.ts"
import { Hono } from 'hono';
import { AuthRegistry } from '@app/core/auth/auth-registry';

const authRouter = new Hono();

authRouter.post('/login', async (c) => {
  const body = await c.req.json();
  const strategy = process.env.AUTH_STRATEGY || 'local';

  try {
    const user = await AuthRegistry.authenticate(strategy, body);
    return c.json({ success: true, user });
  } catch (error: any) {
    return c.json({ success: false, message: error.message }, 401);
  }
});

export default authRouter;
EOF_1785802053_1659

mkdir -p "apps/api/src"
echo "作成: apps/api/src/env.ts"
cat << 'EOF_1785802053_8391' > "apps/api/src/env.ts"
import { z } from 'zod';

const envSchema = z.object({
    DATABASE_URL: z.string().min(1, '環境変数の検証に失敗しました'),
    PORT: z.string().optional(),
});

export function validateEnv(env: Record<string, string | undefined> = process.env) {
    const result = envSchema.safeParse(env);
    if (!result.success) {
        throw new Error('環境変数の検証に失敗しました');
    }
    return result.data;
}
EOF_1785802053_8391

echo "作成: README.md"
cat << 'EOF_1785802053_8244' > "README.md"
# 📖 プロジェクト基本仕様書 (Project Architecture Specification)

## 1. システム概要 (Overview)

本プロジェクトは、TypeScript をベースとしたモノレポ構成の Web アプリケーションです。
バックエンドには軽量・高速な Web フレームワーク（**Hono**）を、フロントエンドにはコンポーネント指向 UI ライブラリ（**React + Vite**）を採用し、データベース操作には型安全な ORM（**Drizzle ORM / PostgreSQL**）を導入しています。
共通ロジックや拡張機能（認証・業務コンポーネント等）を独立したパッケージへ分離することで、保守性と拡張性を高めたコンポーザブルなアーキテクチャを実現します。

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

## 3. アーキテクチャ＆拡張パターン (Architecture & Extension Patterns)

モノレポ構造の強みを活かし、システムの各領域（基盤・認証・機能）の関心を分離（疎結合化）しています。開発者は定められた層構造に従って安全に機能を拡張します。

### 3.1 パッケージの層構造と役割 (Layer Architecture)

| パッケージ名 | レイヤー区分 | 設計の意図・基本方針 | 主な役割・含まれる機能 | 制約・連携方式 |
| --- | --- | --- | --- | --- |
| **`packages/core`** | 共通基盤 | システム全域で利用される不変的な「基盤ルール」を集約 | 型定義、環境変数検証、DB接続・スキーマ定義、共通エラー定義、動的ローダー | 上位のビジネスロジックや特定アプリへの依存厳禁 |
| **`packages/plugins/`** | プラグイン | 運用環境や顧客要件に応じて切り替え・拡張される機能を独立化 | ローカル認証、外部 ID プロバイダー（Active Directory 等）の認証アダプター | アプリ層から依存性を注入（DI）して利用 |
| **`packages/features/`** | 業務ドメイン | 特定の業務機能を単位ごとにカプセル化し、独立した追加・削除・テストを可能化 | ドメイン専用 API ルート、ビジネスロジック、関連 UI コンポーネント | 上位アプリから単方向参照、他ドメインとは原則独立 |

### 3.2 拡張ルールと依存方向 (Extension Rules)

1. **機能追加の手順:**
* 新しいドメイン機能や連携モジュールを追加する際は、`packages/features/` または `packages/plugins/` 配下に新規パッケージを作成し、ルートのワークスペース管理に登録します。


2. **単方向依存の徹底:**
* 依存の方向は常に **「上位（`apps/`）から下位（`packages/`）」** の一方向に限定します。下位パッケージから上位アプリケーションへの逆参照は厳禁とします。



---

## 4. データベース & ORM 仕様 (Database & ORM)

### 4.1 ORM の設計と接続管理

* **型安全性の保障:** アプリケーションコードとデータベース構造の不一致を防ぐため、完全な TypeScript サポートを持つ ORM (Drizzle ORM) を採用します。
* **シングルトン接続:** データベースへのコネクション pool の無駄遣いを防ぐため、`packages/core/src/db/index.ts` にて環境変数の正常性を検証した上で、単一の接続インスタンス（`db`）を保持・供給します。

### 4.2 スキーマ定義

* データベースの構造（テーブル・リレーション等）は、`packages/core/src/db/schema.ts` を正（Single Source of Truth）として定義します。

### 4.3 構成ファイルの分離設計

* テスト実行時と通常開発時でデータベース設定が混同するのを防ぐため、設定ファイルを明確に分離します。
* 特にテスト専用の設定ファイルは、テストフレームワーク（Vitest）の自動テスト検出機能が誤ってテストケースと誤認しないよう、**`drizzle-test.config.ts`** のように明示的な命名ルールを設けて構成します。

---

## 5. 動的モジュール読み込み仕様 (Dynamic Auto-Loader)

### 5.1 機能の自動検出とルーティング登録

* 各 Feature パッケージが持つ API ルート（Hono インスタンス）を個別に手動インポートする手間を省くため、指定ディレクトリ配下のモジュールを動的に探索・一括登録する自動ローダー機構（`hono-auto-loader.ts`）を導入します。

### 5.2 クロスプラットフォーム＆モジュール互換性の保障

* 動的インポート実行時における OS 間（Windows / Linux / macOS）のファイルパス記法差異や、ビルドツール（Vite / Node.js ESM）の URL 解釈エラーを回避するため、以下の実装ガイドラインを厳守します。

> **意図:** 単純な文字列連結によるパス指定（`file://...`）を避け、Node.js 標準の URI 変換処理を用いることで、ポータブルで安全な動的インポートを実現します。また、ビルドツールに対して不必要な静的解析警告を出さないよう抑制します。

```typescript
// 安全な動的インポート実装例 (packages/core/src/registry/hono-auto-loader.ts)
const absolutePath = path.resolve(file);
const moduleUrl = pathToFileURL(absolutePath).href; // URI形式へ安全に変換
const module = await import(/* @vite-ignore */ moduleUrl); // 不要な静的解析警告を抑止

```

---

## 6. ディレクトリ構造 & 全ファイル一覧 (Directory & File Structure)

モノレポ全体を見通し良く管理するための標準的なフォルダおよび全ファイル構成です。

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
│   │   │   ├── index.ts          # API エントリーポイント (ルーティング統括・エラー処理・ライフサイクル制御)
│   │   │   ├── index.test.ts     # API 統合テスト (RFC 7807 エラー検証・Zod バリデーション)
│   │   │   └── routes/           # アプリケーション固有のルーティング
│   │   │       └── auth.ts       # 認証APIエンドポイント
│   │   ├── package.json          # API サーバー用依存関係・スクリプト
│   │   └── tsconfig.json         # API サーバー用 TypeScript 設定
│   │
│   └── web/                      # クライアントサイド Web アプリケーション (React / Vite)
│       ├── public/               # 静的アセット (favicon 等)
│       ├── src/
│       │   ├── env.ts            # クライアント用環境変数保護・型定義モジュール
│       │   ├── App.tsx           # ルート UI コンポーネント
│       │   ├── main.tsx          # React レンダリングエントリーポイント
│       │   └── index.css         # グローバルスタイル定義
│       ├── index.html            # HTML エントリーテンプレート
│       ├── package.json          # Web アプリ用依存関係・スクリプト
│       ├── tsconfig.json         # Web アプリ用 TypeScript 設定
│       ├── tsconfig.node.json    # Vite 設定用 TypeScript 補助設定
│       └── vite.config.ts        # Vite 設定 (API プロキシ・環境変数読み込み)
│
└── packages/                     # 共有パッケージ層 (ライブラリ・モジュール)
    ├── core/                     # システム共通基盤パッケージ
    │   ├── drizzle.config.ts     # 通常開発/マイグレーション用 Drizzle 構成
    │   ├── drizzle-test.config.ts# テストDB専用 ORM 構成ファイル (ファイル名衝突回避)
    │   ├── src/
    │   │   ├── index.ts          # パッケージ共通エクスポート（Core モジュール統合）
    │   │   ├── config/           # 環境変数スキーマおよび堅牢化ロジック
    │   │   │   ├── env.ts        # Zod による環境変数定義・検証関数
    │   │   │   └── env.test.ts   # 環境変数検証の単体テスト
    │   │   ├── db/               # DB 接続インスタンスおよびスキーマ正定義
    │   │   │   ├── index.ts      # シングルトン DB 接続管理
    │   │   │   ├── schema.ts     # Drizzle テーブル定義 (Single Source of Truth)
    │   │   │   └── db.test.ts    # データベース CRUD 操作統合テスト
    │   │   ├── errors/           # システム標準エラー構造・RFC 7807 定義
    │   │   │   ├── index.ts      # 共通エラークラス群 & インターフェース
    │   │   │   └── errors.test.ts# エラークラス構造化単体テスト
    │   │   ├── auth/             # 認証レジストリ基盤・基本型定義
    │   │   ├── registry/         # 動的モジュールローダー
    │   │   │   └── hono-auto-loader.ts # Feature モジュール自動探索機能
    │   │   └── test/             # テスト自動化ライフサイクル定義
    │   │       ├── global-setup.ts# 全テスト実行前の DB スキーマ自動同期処理
    │   │       └── setup.ts      # 各テストケース実行前のデータ自動全クリーンアップ
    │   ├── package.json          # 共通基盤パッケージ用依存関係
    │   └── tsconfig.json         # 共通基盤用 TypeScript 設定
    ├── plugins/                  # 切り替え可能なプラグイン群
    │   ├── auth-ad/              # Active Directory 認証連携モジュール
    │   │   ├── src/index.ts
    │   │   └── package.json
    │   └── auth-local/           # ローカルデータベース認証モジュール
    │       ├── src/index.ts
    │       └── package.json
    └── features/                 # 業務ドメイン機能モジュール群
        └── sample/               # サンプル機能モジュール
            ├── src/
            │   ├── index.ts      # サンプル機能 API ルート定義
            │   └── index.test.ts # サンプル機能単体テスト
            └── package.json

```

---

## 7. 環境変数 & セキュリティ仕様 (Environment Variables & Security)

環境変数の未設定や型間違いによるランタイムエラーを防ぎ、不必要な機密情報の漏洩を保護するため、**起動時自動検証とログの不透明化** を義務付けます。

### 7.1 定義されている環境変数

| 変数名 | 対象領域 | 型 / 制約 | 意図・役割 |
| --- | --- | --- | --- |
| `NODE_ENV` | API | `'development'` | `'test'` | `'production'` | 実行環境の動作モード指定 |
| `PORT` | API | 数値 | API サーバーが待受を行うポート番号 |
| `DATABASE_URL` | API | URL形式文字列 | データベースへの接続URI (認証情報含む) |
| `VITE_PORT` | Web | 数値・文字列 | 開発用 Web サーバーの待受ポート |
| `VITE_API_TARGET_URL` | Web | URL形式文字列 | 開発時の API 転送先 (DevProxy ターゲット) |
| `VITE_APP_TITLE` | Web | 文字列 | アプリケーションの表示タイトル |

### 7.2 セキュリティ & バリデーション設計

1. **フェイルファスト（Fail-Fast）原則:**
* アプリケーション起動時に環境変数を検証（Zod スキーマ）し、1つでも不備があれば起動を即座に安全に中断します。不正な設定のまま不完全な状態で動作し続けることを防ぎます。


2. **機密情報のログマスク（伏字化）:**
* 動作確認用に設定内容をシステムログへ出力する際、データベースパスワード等の認証情報が含まれる文字列（`DATABASE_URL`）は自動的にマスク処理（`***` 化）を施し、ログからの情報漏洩を防ぎます。


3. **フロントエンドの環境変数カプセル化:**
* ブラウザ環境へ公開してよい変数は `VITE_` プレフィックスが付与されたものに限定します。
* グローバルな `process.env` への直接アクセスによる事故を防ぐため、フロントエンド用の安全な参照モジュール（`apps/web/src/env.ts`）を経由したアクセスのみを許可します。



---

## 8. APIエラーレスポンス仕様 (RFC 7807 準拠)

システムから返却されるエラーレスポンスの構造を統一し、クライアント側（フロントエンド）でのエラー処理・デバッグを容易にするため、**RFC 7807 (Problem Details for HTTP APIs)** に準拠した構造を採用します。

### 8.1 統一エラーレスポンス構造

エラー時は、単なるテキストではなく必ず以下の統一フォーマット（JSON）で返却します。

| フィールド名 | キー名 | 役割・説明 | 設定例 |
| --- | --- | --- | --- |
| **エラー分類 URI** | `type` | エラーの種類を明確に識別するURI | `"[https://api.example.com/errors/bad-request](https://api.example.com/errors/bad-request)"` |
| **タイトル** | `title` | エラーの概要（ステータスコードに準拠） | `"Bad Request"`, `"Not Found"` |
| **ステータスコード** | `status` | HTTP ステータスコード | `400`, `404`, `500` |
| **詳細メッセージ** | `detail` | 発生原因の具体的な説明 | `"Validation failed for parameter 'email'"` |
| **発生パス** | `instance` | エラーが発生したリクエスト URI パス | `"/api/v1/users"` |
| **フィールド別詳細** | `invalidParams` | **(任意)** 入力検証エラー時の違反項目・理由リスト | `[{ "name": "email", "reason": "Invalid syntax" }]` |

### 8.2 エラー制御方針

1. **未定義エラーのキャッチ (500 Internal Server Error):**
* 予期せぬ例外が発生した場合でも、スタックトレースや内部実装の秘匿情報をそのままクライアントへ返さず、規格化された 500 エラー構造へ変換して返却します。


2. **入力検証エラーの自動標準化 (400 Bad Request):**
* リクエストデータの検証に失敗した場合、不備のある入力フィールドとエラー理由を `invalidParams` へ自動的にマッピングして通知します。



---

## 9. テストアーキテクチャ & ライフサイクル (Testing Architecture)

テストの信頼性と再現性を維持するため、**「テスト実行時の環境の自動セットアップ」** と **「テストケース間の相互干渉防止」** を自動化しています。

### 9.1 テスト基盤

* **テストランナー:** Vitest（高速なインメモリ実行およびモジュール連携環境を提供）

### 9.2 テスト自動化ライフサイクル

1. **テスト開始前のデータベース構造の自動最新化 (Global Setup):**
* 全テストスイートが実行される直前に、**テスト用データベースのテーブル構造（スキーマ）を常に最新の状態へ自動同期** します。
* これにより、開発者がテスト実行前に手動でデータベースを初期化・マイグレーションする作業を不要にし、常に最新のコード仕様に基づいたテストを保証します。
* *(内部補足: `globalSetup` 内で `drizzle-kit push` 相当の最新化コマンドをテスト用設定で実行します)*


2. **テストケース間の完全な状態隔離 (Setup Files):**
* 個々のテスト（`it` / `test`）が実行される直前に、**データベース内の既存データを自動的に一括クリーンアップ** します。
* 1つのテスト結果が他のテストに影響を与える「テストの副作用（データ汚染）」を排除し、常に独立した決定論的なテスト実行環境を維持します。
* *(内部補足: 全テーブルに対する `TRUNCATE CASCADE` を自動実行します)*


3. **テスト実行環境の分離保護:**
* テスト実行時（`NODE_ENV=test`）は、実際の HTTP ポートの解放・バインドを抑制します。
* ポートの競合エラーを防ぎつつ、高速なインメモリ HTTP リクエストによる API の振る舞い検証を可能にします。



---

## 10. 実行スクリプト リファレンス (Scripts)

プロジェクト内で利用する標準的なコマンドです。

### 10.1 開発サーバー起動

すべてのアプリケーション（API・Web）を開発モードで並行起動します。

```bash
npm run dev

```

### 10.2 全テストの自動実行

すべてのパッケージの単体テスト、DB 連携テスト、API レスポンス検証を一括実行します（実行時に DB スキーマの最新化とデータ破棄が自動適用されます）。

```bash
npm test

```

### 10.3 テスト用 DB スキーマの手動同期

テスト環境のデータベース構造を手動で最新状態へ更新したい場合に実行します。

```bash
npm run db:push:test

```
EOF_1785802053_8244

echo "作成: .env"
cat << 'EOF_1785802053_19089' > ".env"
# バックエンド用
PORT=3001
DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db
TEST_DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db_test

# フロントエンド用 (VITE_ プレフィックスを付ける)
# /workspace/apps/web/src/env.ts と同期する
VITE_PORT=3000
VITE_API_TARGET_URL=http://127.0.0.1:3001
VITE_APP_TITLE=マイアプリケーション
EOF_1785802053_19089

echo -e "\n復元が完了しました！"
