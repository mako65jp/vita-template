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
cat << 'EOF_1785659812_32375' > "package.json"
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
    "concurrently": "^8.2.2",
    "typescript": "^5.3.3",
    "vite": "^5.2.11",
    "vite-tsconfig-paths": "^4.3.1",
    "vitest": "^1.6.0"
  }
}
EOF_1785659812_32375

echo "作成: .gitignore"
cat << 'EOF_1785659812_17134' > ".gitignore"
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
EOF_1785659812_17134

mkdir -p ".devcontainer"
echo "作成: .devcontainer/Dockerfile"
cat << 'EOF_1785659812_11967' > ".devcontainer/Dockerfile"
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>
EOF_1785659812_11967

mkdir -p ".devcontainer"
echo "作成: .devcontainer/devcontainer.json"
cat << 'EOF_1785659812_28728' > ".devcontainer/devcontainer.json"
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
EOF_1785659812_28728

mkdir -p ".devcontainer"
echo "作成: .devcontainer/docker-compose.yml"
cat << 'EOF_1785659812_16485' > ".devcontainer/docker-compose.yml"
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
EOF_1785659812_16485

echo "作成: tsconfig.json"
cat << 'EOF_1785659812_8581' > "tsconfig.json"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "allowImportingTsExtensions": true,
    "noEmit": true,
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "baseUrl": ".",
    "paths": {
      "@app/core/*": ["packages/core/src/*"],
      "@app/plugins/*": ["packages/plugins/*"],
      "@app/features/*": ["packages/features/*"]
    }
  },
  "exclude": ["node_modules", "dist"]
}
EOF_1785659812_8581

echo "作成: vitest.config.ts"
cat << 'EOF_1785659812_31580' > "vitest.config.ts"
import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    globals: true,
    environment: 'node',
  },
});
EOF_1785659812_31580

mkdir -p "packages/plugins/auth-ad"
echo "作成: packages/plugins/auth-ad/package.json"
cat << 'EOF_1785659812_14224' > "packages/plugins/auth-ad/package.json"
{
  "name": "@app/plugins-auth-ad",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785659812_14224

mkdir -p "packages/plugins/auth-ad/src"
echo "作成: packages/plugins/auth-ad/src/index.ts"
cat << 'EOF_1785659812_24993' > "packages/plugins/auth-ad/src/index.ts"
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
EOF_1785659812_24993

mkdir -p "packages/plugins/auth-local"
echo "作成: packages/plugins/auth-local/package.json"
cat << 'EOF_1785659812_13653' > "packages/plugins/auth-local/package.json"
{
  "name": "@app/plugins-auth-local",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785659812_13653

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/index.ts"
cat << 'EOF_1785659812_31945' > "packages/plugins/auth-local/src/index.ts"
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
EOF_1785659812_31945

mkdir -p "packages/core"
echo "作成: packages/core/package.json"
cat << 'EOF_1785659812_21720' > "packages/core/package.json"
{
  "name": "@app/core",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "dependencies": {
    "@prisma/client": "^5.9.1",
    "glob": "^10.3.10",
    "hono": "^4.0.0",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "prisma": "^5.9.1"
  }
}
EOF_1785659812_21720

mkdir -p "packages/core/src/registry"
echo "作成: packages/core/src/registry/hono-auto-loader.ts"
cat << 'EOF_1785659812_11227' > "packages/core/src/registry/hono-auto-loader.ts"
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
EOF_1785659812_11227

mkdir -p "packages/core/src"
echo "作成: packages/core/src/index.ts"
cat << 'EOF_1785659812_30646' > "packages/core/src/index.ts"
export * from './auth/auth-registry.ts';
export * from './registry/hono-auto-loader.ts';
export * from './db/client.ts';
export * from './config/env.ts';
EOF_1785659812_30646

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.test.ts"
cat << 'EOF_1785659812_8313' > "packages/core/src/config/env.test.ts"
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
EOF_1785659812_8313

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.ts"
cat << 'EOF_1785659812_23239' > "packages/core/src/config/env.ts"
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
EOF_1785659812_23239

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/client.ts"
cat << 'EOF_1785659812_23530' > "packages/core/src/db/client.ts"
import { PrismaClient } from '@prisma/client';

export const db = new PrismaClient();
EOF_1785659812_23530

mkdir -p "packages/core/src/auth"
echo "作成: packages/core/src/auth/auth-registry.ts"
cat << 'EOF_1785659812_17261' > "packages/core/src/auth/auth-registry.ts"
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
EOF_1785659812_17261

mkdir -p "packages/features/sample"
echo "作成: packages/features/sample/package.json"
cat << 'EOF_1785659812_26698' > "packages/features/sample/package.json"
{
  "name": "@app/features-sample",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785659812_26698

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.ts"
cat << 'EOF_1785659812_25790' > "packages/features/sample/src/index.ts"
import { Hono } from 'hono';

export default function createSampleFeature() {
  const app = new Hono();

  app.get('/sample', (c) => {
    return c.json({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });

  return app;
}
EOF_1785659812_25790

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.test.ts"
cat << 'EOF_1785659812_13844' > "packages/features/sample/src/index.test.ts"
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
EOF_1785659812_13844

echo "作成: doc.md"
cat << 'EOF_1785659812_15169' > "doc.md"
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
EOF_1785659812_15169

mkdir -p "apps/web"
echo "作成: apps/web/package.json"
cat << 'EOF_1785659812_28770' > "apps/web/package.json"
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
    "@vitejs/plugin-react": "^4.2.1",
    "typescript": "^5.3.3"
  }
}
EOF_1785659812_28770

mkdir -p "apps/web"
echo "作成: apps/web/index.html"
cat << 'EOF_1785659812_6168' > "apps/web/index.html"
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
EOF_1785659812_6168

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.json"
cat << 'EOF_1785659812_31730' > "apps/web/tsconfig.json"
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
EOF_1785659812_31730

mkdir -p "apps/web/src"
echo "作成: apps/web/src/main.tsx"
cat << 'EOF_1785659812_24843' > "apps/web/src/main.tsx"
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF_1785659812_24843

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.tsx"
cat << 'EOF_1785659812_700' > "apps/web/src/components/LoginForm.tsx"
import React, { useState } from 'react';

export const LoginForm: React.FC = () => {
  // ... (省略)
};
EOF_1785659812_700

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.tsx"
cat << 'EOF_1785659812_11158' > "apps/web/src/App.tsx"
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
EOF_1785659812_11158

mkdir -p "apps/web/src"
echo "作成: apps/web/src/env.ts"
cat << 'EOF_1785659812_1837' > "apps/web/src/env.ts"
import { clientEnvSchema, type ClientEnv } from '@app/core/config/env.ts';

// Vite の import.meta.env を Zod で検証・補完
export const env: ClientEnv = clientEnvSchema.parse({
    VITE_PORT: import.meta.env.VITE_PORT,
    VITE_API_TARGET_URL: import.meta.env.VITE_API_TARGET_URL,
    VITE_APP_TITLE: import.meta.env.VITE_APP_TITLE,
});
EOF_1785659812_1837

mkdir -p "apps/web"
echo "作成: apps/web/vite.config.ts"
cat << 'EOF_1785659812_7993' > "apps/web/vite.config.ts"
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';
import path from 'path';

export default defineConfig(({ mode }) => {
  // モノレポのルート直下（../../）にある .env ファイルをロード
  const envDir = path.resolve(__dirname, '../../');
  const env = loadEnv(mode, envDir, '');

  // ポート番号やプロキシ先を環境変数から取得（フォールバック付き）
  const webPort = parseInt(env.VITE_PORT || '3000', 10);
  const apiTarget = env.VITE_API_TARGET_URL || 'http://127.0.0.1:3001';

  return {
    // Vite が .env ファイルを探すディレクトリを指定
    envDir,

    plugins: [react(), tsconfigPaths()],

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
EOF_1785659812_7993

mkdir -p "apps/api"
echo "作成: apps/api/package.json"
cat << 'EOF_1785659812_2213' > "apps/api/package.json"
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
    "@hono/node-server": "^1.8.2",
    "hono": "^4.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "tsx": "^4.7.1",
    "typescript": "^5.3.3"
  }
}
EOF_1785659812_2213

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.ts"
cat << 'EOF_1785659812_12517' > "apps/api/src/index.ts"
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { loadFeatureModules } from '@app/core/registry/hono-auto-loader.ts';
import { AuthRegistry } from '@app/core/auth/auth-registry.ts';
import { LocalAuthPlugin } from '@app/plugins/auth-local/src/index.ts';
import { ActiveDirectoryAuthPlugin } from '@app/plugins/auth-ad/src/index.ts';
import { validateEnv, formatEnvForLog } from '@app/core/config/env.ts';
import authRouter from './routes/auth.ts';

// 1. 起動時に環境変数を検証・取得
const env = validateEnv();

// 2. コンソールに読み込まれた環境変数を綺麗に出力 🚀
console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog(env));

AuthRegistry.register(new LocalAuthPlugin());
AuthRegistry.register(new ActiveDirectoryAuthPlugin());

const app = new Hono();

app.route('/api/auth', authRouter);
await loadFeatureModules(app, 'packages/features/*/src/index.ts');

const port = env.PORT; // 型安全な数値ポ—ト番号を使用
console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);

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
EOF_1785659812_12517

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.test.ts"
cat << 'EOF_1785659812_13626' > "apps/api/src/index.test.ts"
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

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
EOF_1785659812_13626

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.ts"
cat << 'EOF_1785659812_26365' > "apps/api/src/routes/auth.ts"
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
EOF_1785659812_26365

echo "作成: README.md"
cat << 'EOF_1785659812_31940' > "README.md"
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
* アプリケーション全体で共有される**型定義・環境変数設定・共通ユーティリティ**を保持します。
* `apps/*` や他の `packages/*` から普遍的に参照される「共通基盤」です。特定のビジネスロジックには依存させません。


* **`packages/plugins/` (認証・外部連携プラグイン)**
* 特定の認証方式（例: Local認証、Active Directory / OAuth 等）や外部連携サービスなどの切替可能なコンポーネントを独立パッケージ化します。
* `apps/api` や `apps/web` は、設定や環境変数に応じて使用するプラグインを選択・注入（Dependency Injection）します。


* **`packages/features/` (ドメイン機能モジュール)**
* 特定の業務ドメインや機能群（例: サンプル機能 `sample`、ユーザー管理、決済等）をカプセル化したパッケージです。
* フロントエンドコンポーネントとバックエンドロジック（または API ルート定義）をセットでパッケージ化することで、機能単位での追加・削除・テストを容易にします。



### 3.2 機能拡張パターン (Extension Workflow)

1. **新しい共有プラグイン・機能の追加:**
* `packages/plugins/` または `packages/features/` 配下に新しいディレクトリ（例: `packages/features/todo`）を作成し、`package.json` を配置します。
* ルートの `package.json`（`docker-compose.yml` 等）の依存関係指定と合わせることで、自動的にワークスペースとして認識されます。


2. **依存関係の参照ルール:**
* 参照は常に **上位層（`apps/`） ➔ 下位層（`packages/`）** の一方向に限定します。
* `packages/` 内のモジュールが `apps/` のコードに逆依存することは禁止します。



---

## 4. ディレクトリ構造 & 全ファイル一覧 (Directory & File Structure)

`npm workspaces` を使用してプロジェクトをマルチパッケージ管理しています。プロジェクト内の全ファイル・フォルダ構成は以下の通りです。

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
│   │   │   ├── index.ts          # API エントリーポイント (ルーティング & サーバー起動制御)
│   │   │   └── index.test.ts     # API 統合テスト (Vitest)
│   │   ├── package.json          # API サーバー用依存関係・スクリプト
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
    │   │   └── config/
    │   │       ├── env.ts        # 環境変数スキーマ & ロジック (Zod)
    │   │       └── env.test.ts   # 環境変数の単体テスト (Vitest)
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

#### 1. バックエンド (`apps/api`)

* **起動時チェック:** API 起動時、`validateEnv()` により `envSchema` の適合チェックを実施。不正時はエラーログを出力してプロセスを即座に停止します。
* **ログ出力 & 秘密情報マスク:** 起動時に適用された設定内容を JSON ログ出力します。ログ出力時は `formatEnvForLog()` が `DATABASE_URL` のパスワード部分を自動的に `***` へ伏字化（マスク）します。

#### 2. フロントエンド (`apps/web`)

* **安全なカプセル化 (`apps/web/src/env.ts`):** ブラウザ環境で Node.js の `process.env` を参照して発生する `ReferenceError` を防ぐため、`import.meta.env` を `clientEnvSchema` で検証・型抽出した `env` オブジェクトを経由して安全にコンポーネント内から利用します。
* **Vite プロキシ連携:** `vite.config.ts` にて `loadEnv` を用い、ルート直下の `.env` から `VITE_API_TARGET_URL` を読み込んで API プロキシを設定します。

---

## 6. 実行スクリプト & テスト仕様 (Scripts & Testing)

### 6.1 開発サーバー起動

ルートディレクトリ（または DevContainer 上）にて以下を実行します。

```bash
npm run dev

```

* `concurrently` により `dev:api` と `dev:web` を同時並行で立ち上げます。
* **API 起動コマンド:** `tsx watch --env-file=../../.env src/index.ts`
*(※ `--env-file` は `watch` サブコマンドの後に指定)*

### 6.2 テスト自動化 & 非同期ソケット制御

全テスト（TDD）の実行には以下を使用します。

```bash
npm test

```

* **テスト環境保護 (`NODE_ENV === 'test'`):**
`apps/api/src/index.ts` では `process.env.NODE_ENV !== 'test'` の条件分岐を設け、テスト実行時には `serve()` (HTTPリスナーのバインド) を自動スキップします。これにより、ポートの二重バインドや未捕獲のソケットエラーを防ぎ、Hono の `app.request()` によるインメモリテストを高速かつ正常に完結させます。
EOF_1785659812_31940

echo "作成: .env"
cat << 'EOF_1785659812_6074' > ".env"
# バックエンド用
PORT=3001
DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db?schema=public

# フロントエンド用 (VITE_ プレフィックスを付ける)
# /workspace/apps/web/src/env.ts と同期する
VITE_PORT=3000
VITE_API_TARGET_URL=http://127.0.0.1:3001
VITE_APP_TITLE=マイアプリケーション
EOF_1785659812_6074

echo -e "\n復元が完了しました！"
