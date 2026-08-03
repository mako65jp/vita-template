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
cat << 'EOF_1785720373_9685' > "package.json"
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
    "test": "vitest run"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^6.0.5",
    "concurrently": "^8.2.2",
    "typescript": "^5.3.3",
    "vite": "^8.2.0",
    "vitest": "^4.1.10"
  },
  "dependencies": {
    "@hono/node-server": "^2.0.5"
  }
}
EOF_1785720373_9685

echo "作成: .gitignore"
cat << 'EOF_1785720373_12218' > ".gitignore"
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
EOF_1785720373_12218

echo "作成: plan.md"
cat << 'EOF_1785720373_16886' > "plan.md"
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
EOF_1785720373_16886

mkdir -p ".devcontainer"
echo "作成: .devcontainer/Dockerfile"
cat << 'EOF_1785720373_28799' > ".devcontainer/Dockerfile"
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>
EOF_1785720373_28799

mkdir -p ".devcontainer"
echo "作成: .devcontainer/devcontainer.json"
cat << 'EOF_1785720373_10580' > ".devcontainer/devcontainer.json"
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
EOF_1785720373_10580

mkdir -p ".devcontainer"
echo "作成: .devcontainer/docker-compose.yml"
cat << 'EOF_1785720373_29545' > ".devcontainer/docker-compose.yml"
version: '3.8'

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
      DATABASE_URL: "postgresql://postgres:postgres@db:5432/app_db?schema=public"
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: app_db
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
EOF_1785720373_29545

echo "作成: tsconfig.json"
cat << 'EOF_1785720373_19415' > "tsconfig.json"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
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
EOF_1785720373_19415

echo "作成: vitest.config.ts"
cat << 'EOF_1785720373_20029' > "vitest.config.ts"
import { defineConfig } from 'vitest/config';
// import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  // plugins: [tsconfigPaths()],
  resolve: {
    tsconfigPaths: true
  },
  test: {
    globals: true,
    environment: 'node',
    reporters: ['tree'],
  },
});
EOF_1785720373_20029

mkdir -p "packages/plugins/auth-ad"
echo "作成: packages/plugins/auth-ad/package.json"
cat << 'EOF_1785720373_191' > "packages/plugins/auth-ad/package.json"
{
  "name": "@app/plugins-auth-ad",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785720373_191

mkdir -p "packages/plugins/auth-ad/src"
echo "作成: packages/plugins/auth-ad/src/index.ts"
cat << 'EOF_1785720373_9197' > "packages/plugins/auth-ad/src/index.ts"
import { AuthPlugin } from '@app/core/auth/auth-registry.ts';

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
EOF_1785720373_9197

mkdir -p "packages/plugins/auth-local"
echo "作成: packages/plugins/auth-local/package.json"
cat << 'EOF_1785720373_24232' > "packages/plugins/auth-local/package.json"
{
  "name": "@app/plugins-auth-local",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785720373_24232

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/index.ts"
cat << 'EOF_1785720373_7856' > "packages/plugins/auth-local/src/index.ts"
import { AuthPlugin } from '@app/core/auth/auth-registry.ts';

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
EOF_1785720373_7856

mkdir -p "packages/core"
echo "作成: packages/core/package.json"
cat << 'EOF_1785720373_18246' > "packages/core/package.json"
{
  "name": "@app/core",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "dependencies": {
    "@prisma/client": "^5.9.1",
    "glob": "^13.0.6",
    "hono": "^4.0.0",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "prisma": "^5.9.1"
  }
}
EOF_1785720373_18246

mkdir -p "packages/core/src/registry"
echo "作成: packages/core/src/registry/hono-auto-loader.ts"
cat << 'EOF_1785720373_29033' > "packages/core/src/registry/hono-auto-loader.ts"
import { Hono } from 'hono';
import { glob } from 'glob';
import path from 'path';

export async function loadFeatureModules(app: Hono, pattern: string) {
  const files = await glob(pattern);
  for (const file of files) {
    const absolutePath = path.resolve(file);
    const module = await import(`file://${absolutePath}`);
    if (module.default && typeof module.default === 'function') {
      const route = module.default();
      app.route('/', route);
      console.log(`[Auto-Loader] Loaded Feature module: ${file}`);
    }
  }
}
EOF_1785720373_29033

mkdir -p "packages/core/src"
echo "作成: packages/core/src/index.ts"
cat << 'EOF_1785720373_30871' > "packages/core/src/index.ts"
export * from './auth/auth-registry.ts';
export * from './registry/hono-auto-loader.ts';
export * from './db/client.ts';
export * from './config/env.ts';
export * from './errors/index.ts';
EOF_1785720373_30871

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.test.ts"
cat << 'EOF_1785720373_30341' > "packages/core/src/config/env.test.ts"
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { validateEnv } from './env.ts';
import { formatEnvForLog } from './env.ts';


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
EOF_1785720373_30341

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.ts"
cat << 'EOF_1785720373_3467' > "packages/core/src/config/env.ts"
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
    ? ({} as Env) // ブラウザ側でこのオブジェクトが呼ばれた場合はダミーを返す
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
EOF_1785720373_3467

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/client.ts"
cat << 'EOF_1785720373_12537' > "packages/core/src/db/client.ts"
import { PrismaClient } from '@prisma/client';

export const db = new PrismaClient();
EOF_1785720373_12537

mkdir -p "packages/core/src/auth"
echo "作成: packages/core/src/auth/auth-registry.ts"
cat << 'EOF_1785720373_14535' > "packages/core/src/auth/auth-registry.ts"
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
EOF_1785720373_14535

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/index.ts"
cat << 'EOF_1785720373_3600' > "packages/core/src/errors/index.ts"
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
EOF_1785720373_3600

mkdir -p "packages/features/sample"
echo "作成: packages/features/sample/package.json"
cat << 'EOF_1785720373_19466' > "packages/features/sample/package.json"
{
  "name": "@app/features-sample",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785720373_19466

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.ts"
cat << 'EOF_1785720373_13862' > "packages/features/sample/src/index.ts"
import { Hono } from 'hono';

export default function createSampleFeature() {
  const app = new Hono();

  app.get('/sample', (c) => {
    return c.json({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });

  return app;
}
EOF_1785720373_13862

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.test.ts"
cat << 'EOF_1785720373_22743' > "packages/features/sample/src/index.test.ts"
import { describe, it, expect } from 'vitest';
import createSampleFeature from './index.ts';

describe('Sample Feature API', () => {
  it('GET /sample should return 200 and json message', async () => {
    const app = createSampleFeature();
    const res = await app.request('/sample');
    
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body).toEqual({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });
});
EOF_1785720373_22743

echo "作成: doc.md"
cat << 'EOF_1785720373_3457' > "doc.md"
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
EOF_1785720373_3457

mkdir -p "apps/web"
echo "作成: apps/web/package.json"
cat << 'EOF_1785720373_24525' > "apps/web/package.json"
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
EOF_1785720373_24525

mkdir -p "apps/web"
echo "作成: apps/web/index.html"
cat << 'EOF_1785720373_12015' > "apps/web/index.html"
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
EOF_1785720373_12015

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.json"
cat << 'EOF_1785720373_2718' > "apps/web/tsconfig.json"
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "types": ["vite/client"]
  },
  "include": ["src"]
}
EOF_1785720373_2718

mkdir -p "apps/web/src"
echo "作成: apps/web/src/main.tsx"
cat << 'EOF_1785720373_26231' > "apps/web/src/main.tsx"
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF_1785720373_26231

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.tsx"
cat << 'EOF_1785720373_1264' > "apps/web/src/components/LoginForm.tsx"
import React, { useState } from 'react';

export const LoginForm: React.FC = () => {
  // ... (省略)
};
EOF_1785720373_1264

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.tsx"
cat << 'EOF_1785720373_32331' > "apps/web/src/App.tsx"
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
EOF_1785720373_32331

mkdir -p "apps/web/src"
echo "作成: apps/web/src/env.ts"
cat << 'EOF_1785720373_1415' > "apps/web/src/env.ts"
import { clientEnvSchema, type ClientEnv } from '@app/core/config/env.ts';

// Vite の import.meta.env を Zod で検証・補完
export const env: ClientEnv = clientEnvSchema.parse({
    VITE_PORT: import.meta.env.VITE_PORT,
    VITE_API_TARGET_URL: import.meta.env.VITE_API_TARGET_URL,
    VITE_APP_TITLE: import.meta.env.VITE_APP_TITLE,
});
EOF_1785720373_1415

mkdir -p "apps/web"
echo "作成: apps/web/vite.config.ts"
cat << 'EOF_1785720373_29109' > "apps/web/vite.config.ts"
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
// import tsconfigPaths from 'vite-tsconfig-paths';
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

    // plugins: [react(), tsconfigPaths()],
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
EOF_1785720373_29109

mkdir -p "apps/api"
echo "作成: apps/api/package.json"
cat << 'EOF_1785720373_26846' > "apps/api/package.json"
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
EOF_1785720373_26846

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.ts"
cat << 'EOF_1785720373_30408' > "apps/api/src/index.ts"
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { validateEnv, formatEnvForLog } from '@app/core/config/env.ts';
import { AppError, ProblemDetails, ValidationError } from '@app/core/errors/index.ts';
import { loadFeatureModules } from '@app/core/registry/hono-auto-loader.ts';
import { AuthRegistry } from '@app/core/auth/auth-registry.ts';
import { LocalAuthPlugin } from '@app/plugins/auth-local/src/index.ts';
import { ActiveDirectoryAuthPlugin } from '@app/plugins/auth-ad/src/index.ts';
import authRouter from './routes/auth.ts';

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
EOF_1785720373_30408

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.test.ts"
cat << 'EOF_1785720373_5475' > "apps/api/src/index.test.ts"
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import app from './index.ts';

describe('API Server Integration Tests', () => {
    const originalEnv = process.env;

    beforeEach(() => {
        // モジュールキャッシュをリセットして、再インポート時にトップレベルのコード（validateEnv）が再実行されるようにする
        vi.resetModules();
        process.env = { ...originalEnv };
    });

    afterEach(() => {
        process.env = originalEnv;
    });

    it('正しい環境変数がセットされている場合、アプリが正常にルーティング応答すること', async () => {
        process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/app_db';
        process.env.PORT = '3001';

        const { default: app } = await import('./index.ts');

        const res = await app.request('/sample');
        expect(res.status).toBe(200);

        const body = await res.json();
        expect(body).toEqual({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
    });

    it('DATABASE_URL が存在しない場合、エントリポイント実行時に例外をスローすること', async () => {
        delete process.env.DATABASE_URL;

        await expect(async () => {
            await import('./index.ts');
        }).rejects.toThrow('環境変数の検証に失敗しました');
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
EOF_1785720373_5475

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.ts"
cat << 'EOF_1785720373_16212' > "apps/api/src/routes/auth.ts"
import { Hono } from 'hono';
import { AuthRegistry } from '@app/core/auth/auth-registry.ts';

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
EOF_1785720373_16212

echo "作成: README.md"
cat << 'EOF_1785720373_12835' > "README.md"
# 📖 プロジェクト基本仕様書 (Project Architecture Specification)

## 1. システム概要 (Overview)

本プロジェクトは、TypeScript をベースとしたモノレポ構成の Web アプリケーションです。
バックエンドには軽量・高速な **Hono** を、フロントエンドには **React + Vite** を採用し、共通ロジックやプラグイン（認証・機能コンポーネント等）を `packages/` 配下に分離した拡張性の高いアーキテクチャを採用しています。

---

## 2. 開発環境仕様 (Development Environment)

開発チーム間での環境差異を失くし、データベース（PostgreSQL）を含めた開発環境を一括構築するため、**VS Code Dev Containers + Docker Compose** を標準の開発環境として導入しています。

### 2.1 開発環境要件

* **VS Code 拡張機能:** `ms-vscode-remote.remote-containers` (Dev Containers)
* **コンテナランタイム:** Docker Desktop / OrbStack / Rancher Desktop 等
* **Node.js バージョン:** `v20.x` (DevContainer 上で固定)
* **パッケージマネージャー:** `npm` (npm workspaces によるマルチパッケージ管理)

### 2.2 DevContainer & Docker Compose サービス構成

`.devcontainer/docker-compose.yml` により、以下の 2 つのサービスが連携して起動します。

| サービス名 | コンテナ / イメージ | ポートフォワード | 役割・説明 |
| --- | --- | --- | --- |
| **app** | .devcontainer/Dockerfile (`typescript-node:1-20-bookworm`) | `3000:3000`, `3001:3001` | 開発用アプリケーションコンテナ。VS Code がアタッチする対象。各パッケージの `node_modules` はホストとの干渉を防ぐため匿名ボリュームとして分離。 |
| **db** | `postgres:15-alpine` | `5432:5432` | 開発用 PostgreSQL データベース。`postgres-data` ボリュームによりデータが永続化されます。 |

* **コンテナ内データベース接続:**
`app` コンテナからは `postgresql://postgres:postgres@db:5432/app_db?schema=public` で接続します。

---

## 3. アーキテクチャ＆拡張パターン (Architecture & Extension Patterns)

本プロジェクトはモノレポ構造を生かし、各領域の責務を明確に分離（疎結合化）しています。新しい機能やプラグインを追加する際は、以下の構成パターンに従って実装します。

### 3.1 パッケージの層構造と役割 (Layer Architecture)

* **`packages/core` (基盤レイヤー)**
* アプリケーション全体で共有される**型定義・環境変数設定・共通ユーティリティ・エラー定義**を保持します。
* `apps/*` や他の `packages/*` から普遍的に参照される「共通基盤」です。特定のビジネスロジックには依存させません。


* **`packages/plugins/` (認証・外部連携プラグイン)**
* 特定の認証方式（例: Local認証、Active Directory / OAuth 等）や外部連携サービスなどの切替可能なコンポーネントを独立パッケージ化します。
* `apps/api` や `apps/web` は、設定や環境変数に応じて使用するプラグインを選択・注入（Dependency Injection）します。


* **`packages/features/` (ドメイン機能モジュール)**
* 特定の業務ドメインや機能群（例: サンプル機能 `sample`、ユーザー管理、決済等）をカプセル化したパッケージです。
* フロントエンドコンポーネントとバックエンドロジック（または API ルート定義）をセットでパッケージ化することで、機能単位での追加・削除・テストを容易にします。



### 3.2 機能拡張パターン (Extension Workflow)

1. **新しい共有プラグイン・機能の追加（※実装構成例）:**
* **例:** `packages/plugins/` または `packages/features/` 配下に新しいディレクトリ（例: `packages/features/todo`）を作成し、`package.json` を配置する構成などが考えられます。
* ルートの `package.json`（および必要に応じて `docker-compose.yml` 等）の依存関係指定と合わせることで、npm ワークスペースとして自動認識させる運用方法が一例として挙げられます。


2. **依存関係の参照ルール:**
* 参照は常に **上位層（`apps/`） ➔ 下位層（`packages/`）** の一方向に限定します。
* `packages/` 内のモジュールが `apps/` のコードに逆依存することは禁止します。



---

## 4. ディレクトリ構造 & 全ファイル一覧 (Directory & File Structure)

`npm workspaces` を使用してプロジェクトをマルチパッケージ管理しています。

```text
.
├── .devcontainer/                # DevContainer & Docker 構成フォルダ
│   ├── devcontainer.json         # DevContainer 起動・拡張機能設定
│   ├── docker-compose.yml        # DevContainer 連携サービス定義 (app, db)
│   └── Dockerfile                # DevContainer 用ベースイメージ・環境定義
├── .env                          # プロジェクト共通の環境変数設定ファイル
├── .gitignore                    # Git 管理除外設定
├── package.json                  # ルート package.json (全体スクリプト・ワークスペース管理)
├── tsconfig.json                 # モノレポ全体のベース TypeScript 設定
│
├── apps/                         # アプリケーションフォルダ
│   ├── api/                      # バックエンド API サーバー (Hono / Node.js)
│   │   ├── src/
│   │   │   ├── index.ts          # API エントリーポイント (ルーティング, エラーハンドリング & サーバー起動制御)
│   │   │   ├── index.test.ts     # API 統合テスト (エラーレスポンス・Zod検証・Vitest)
│   │   │   └── routes/
│   │   │       └── auth.ts       # 認証用ルーティング
│   │   ├── package.json          # API サーバー用依存関係 (@hono/zod-validator, zod 追加済)
│   │   └── tsconfig.json         # API サーバー用 TypeScript 設定
│   │
│   └── web/                      # フロントエンド Web アプリ (React / Vite)
│       ├── public/               # 静的アセットフォルダ
│       ├── src/
│       │   ├── env.ts            # フロントエンド用型安全環境変数モジュール
│       │   ├── App.tsx           # メインコンポーネント
│       │   └── main.tsx          # React エントリーポイント
│       ├── index.html            # HTML テンプレート
│       ├── package.json          # Web アプリ用依存関係・スクリプト
│       ├── tsconfig.json         # Web アプリ用 TypeScript 設定
│       └── vite.config.ts        # Vite 設定 (DevProxy, loadEnv)
│
└── packages/                     # 共有パッケージフォルダ
    ├── core/                     # 共通ロジック・設定・型定義パッケージ
    │   ├── src/
    │   │   ├── config/
    │   │   │   ├── env.ts        # 環境変数スキーマ & ロジック (Zod)
    │   │   │   └── env.test.ts   # 環境変数の単体テスト (Vitest)
    │   │   ├── errors/
    │   │   │   └── index.ts      # 共通エラークラス (AppError, ValidationError) & RFC 7807 型定義 [NEW]
    │   │   ├── auth/             # 認証レジストリ基盤
    │   │   └── registry/         # モジュール動的ローダー (hono-auto-loader)
    │   ├── package.json          # 共通パッケージ用依存関係・スクリプト
    │   └── tsconfig.json         # 共通パッケージ用 TypeScript 設定
    ├── plugins/                  # 認証プラグイン群
    │   ├── auth-ad/              # Active Directory 認証プラグイン
    │   └── auth-local/           # ローカル認証プラグイン
    └── features/                 # 機能モジュール群
        └── sample/               # サンプル機能パッケージ

```

---

## 5. 環境変数 & セキュリティ仕様 (Environment Variables & Security)

環境変数はバックエンド・フロントエンド双方で **Zod スキーマ** を用いて起動時に型検証・初期値補完を行います。

### 5.1 環境変数一覧

| 変数名 | 対象 | 型 / 制約 | デフォルト値 | 説明 |
| --- | --- | --- | --- | --- |
| `NODE_ENV` | API | `'development'`, `'test'`, `'production'` | `'development'` | 動作モード |
| `PORT` | API | `number` | `3001` | API サーバーの待受ポート |
| `DATABASE_URL` | API | `string` (URL形式) | **(必須)** | PostgreSQL 接続文字列 |
| `VITE_PORT` | Web | `string` | `'3000'` | 開発用 Web サーバーのポート |
| `VITE_API_TARGET_URL` | Web | `string` (URL形式) | `'[http://127.0.0.1:3001](http://127.0.0.1:3001)'` | DevProxy 転送先 API URL |
| `VITE_APP_TITLE` | Web | `string` | `'My App'` | アプリケーションタイトル |

> ⚠️ **ブラウザ参照ルール:** クライアント側（Web）から参照可能な環境変数は、セキュリティ上 **`VITE_` プレフィックス** が必須となります。

### 5.2 環境変数の検証・セキュリティアーキテクチャ

1. **バックエンド (`apps/api`):**
* **起動時チェック:** API 起動時、`validateEnv()` により `envSchema` の適合チェックを実施。不正時はエラーログを出力してプロセスを即座に停止します。
* **ログ出力 & 秘密情報マスク:** 起動時に適用された設定内容を JSON ログ出力します。ログ出力時は `formatEnvForLog()` が `DATABASE_URL` のパスワード部分を自動的に `***` へ伏字化（マスク）します。


2. **フロントエンド (`apps/web`):**
* **安全なカプセル化 (`apps/web/src/env.ts`):** ブラウザ環境で `process.env` を参照して発生する `ReferenceError` を防ぐため、`import.meta.env` を `clientEnvSchema` で検証・型抽出した `env` オブジェクトを経由して利用します。
* **Vite プロキシ連携:** `vite.config.ts` にて `loadEnv` を用い、ルート直下の `.env` から `VITE_API_TARGET_URL` を読み込んで API プロキシを設定します。



---

## 6. APIエラーレスポンス & バリデーション仕様 (RFC 7807) [NEW]

本プロジェクトでは、すべての API エラーレスポンスを **RFC 7807 (Problem Details for HTTP APIs)** 仕様に準拠させて統一しています。

### 6.1 エラーレスポンス基本構造 (`ProblemDetails`)

```typescript
export interface InvalidParam {
  name: string;   // エラーが発生したフィールド名（例: "email"）
  reason: string; // エラー内容（例: "Invalid email address"）
}

export interface ProblemDetails {
  type: string;           // エラーの分類を示す URI (例: "https://api.example.com/errors/not-found")
  title: string;          // エラーの概要 (例: "Not Found", "Bad Request")
  status: number;         // HTTP ステータスコード (例: 404, 400, 500)
  detail: string;         // エラーの詳細メッセージ
  instance: string;       // エラーが発生したリクエストパス (例: "/api/v1/users")
  invalidParams?: InvalidParam[]; // バリデーションエラー時のフィールド別詳細リスト
}

```

### 6.2 エラー処理の動作原則

1. **404 Not Found 規格化:** 存在しないルートへのアクセスは `app.notFound` により常に 404 の RFC 7807 JSON が返却されます。
2. **500 Internal Server Error 規格化:** アプリ内部で捕捉されなかった未定義例外は `app.onError` で全件キャッチし、機密情報を除外した上で 500 の RFC 7807 JSON を生成・返却します。
3. **Zod 入力バリデーション (400 Bad Request):**
* `@hono/zod-validator` を通じて送信された payload を検証します。
* 検証エラー発生時は `ValidationError` がスローされ、`app.onError` 経由で `invalidParams` 配列（フィールドごとの違反理由）を含む 400 レスポンスとして返却されます。



---

## 7. 実行スクリプト & テスト仕様 (Scripts & Testing)

### 7.1 開発サーバー起動

ルートディレクトリ（または DevContainer 上）にて以下を実行します。

```bash
npm run dev

```

* `concurrently` により `dev:api` と `dev:web` を同時並行で立ち上げます。
* **API 起動コマンド:** `tsx watch --env-file=../../.env src/index.ts`

### 7.2 テスト自動化 & 非同期ソケット制御

全テスト（TDD）の実行には以下を使用します。

```bash
npm test

```

* **テスト環境保護 (`NODE_ENV === 'test'`):**
`apps/api/src/index.ts` では `process.env.NODE_ENV !== 'test'` の条件分岐を設け、テスト実行時には `serve()` (HTTPリスナーのバインド) を自動スキップします。これにより、ポートの二重バインドや未捕獲のソケットエラーを防ぎ、Hono の `app.request()` によるインメモリテストをミリ秒単位で高速かつ正常に実行します。
* **テストカバレッジ:**
* 未定義パスアクセスの 404 検証
* サーバー例外発生時の 500 検証
* Zod スキーマ違反時の 400 & `invalidParams` レスポンス構造の検証
EOF_1785720373_12835

echo "作成: .env"
cat << 'EOF_1785720373_24007' > ".env"
# バックエンド用
PORT=3001
DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db?schema=public

# フロントエンド用 (VITE_ プレフィックスを付ける)
# /workspace/apps/web/src/env.ts と同期する
VITE_PORT=3000
VITE_API_TARGET_URL=http://127.0.0.1:3001
VITE_APP_TITLE=マイアプリケーション
EOF_1785720373_24007

echo -e "\n復元が完了しました！"
