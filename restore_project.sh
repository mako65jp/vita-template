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
cat << 'EOF_1785833489_13876' > "package.json"
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
EOF_1785833489_13876

echo "作成: .gitignore"
cat << 'EOF_1785833489_8831' > ".gitignore"
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
EOF_1785833489_8831

echo "作成: plan.md"
cat << 'EOF_1785833489_3353' > "plan.md"
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
EOF_1785833489_3353

mkdir -p ".devcontainer/scripts"
echo "作成: .devcontainer/scripts/init-test-db.sh"
cat << 'EOF_1785833489_31886' > ".devcontainer/scripts/init-test-db.sh"
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE $POSTGRES_DB_TEST;
EOSQL
EOF_1785833489_31886

mkdir -p ".devcontainer"
echo "作成: .devcontainer/Dockerfile"
cat << 'EOF_1785833489_31594' > ".devcontainer/Dockerfile"
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>
EOF_1785833489_31594

mkdir -p ".devcontainer"
echo "作成: .devcontainer/devcontainer.json"
cat << 'EOF_1785833489_19463' > ".devcontainer/devcontainer.json"
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
EOF_1785833489_19463

mkdir -p ".devcontainer"
echo "作成: .devcontainer/docker-compose.yml"
cat << 'EOF_1785833489_14448' > ".devcontainer/docker-compose.yml"


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
EOF_1785833489_14448

echo "作成: tsconfig.json"
cat << 'EOF_1785833489_17403' > "tsconfig.json"
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
EOF_1785833489_17403

echo "作成: vitest.config.ts"
cat << 'EOF_1785833489_5727' > "vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
  resolve: {
    tsconfigPaths: true
  },
  test: {
    globals: true,
    reporters: ['tree'],

    projects: [
      'packages/*',
      'apps/api',
      'apps/web/vitest.config.ts',
    ],
  },
});
EOF_1785833489_5727

mkdir -p "packages/plugins/auth-ad"
echo "作成: packages/plugins/auth-ad/package.json"
cat << 'EOF_1785833489_26127' > "packages/plugins/auth-ad/package.json"
{
  "name": "@app/plugins-auth-ad",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785833489_26127

mkdir -p "packages/plugins/auth-ad/src"
echo "作成: packages/plugins/auth-ad/src/index.ts"
cat << 'EOF_1785833489_18195' > "packages/plugins/auth-ad/src/index.ts"
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
EOF_1785833489_18195

mkdir -p "packages/plugins/auth-local"
echo "作成: packages/plugins/auth-local/package.json"
cat << 'EOF_1785833489_25355' > "packages/plugins/auth-local/package.json"
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
EOF_1785833489_25355

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/index.ts"
cat << 'EOF_1785833489_14549' > "packages/plugins/auth-local/src/index.ts"
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
EOF_1785833489_14549

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/auth-utils.ts"
cat << 'EOF_1785833489_18826' > "packages/plugins/auth-local/src/auth-utils.ts"
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
EOF_1785833489_18826

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/auth-utils.test.ts"
cat << 'EOF_1785833489_1985' > "packages/plugins/auth-local/src/auth-utils.test.ts"
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
EOF_1785833489_1985

mkdir -p "packages/core"
echo "作成: packages/core/package.json"
cat << 'EOF_1785833489_28169' > "packages/core/package.json"
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
EOF_1785833489_28169

mkdir -p "packages/core"
echo "作成: packages/core/drizzle-test.config.ts"
cat << 'EOF_1785833489_21000' > "packages/core/drizzle-test.config.ts"
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
EOF_1785833489_21000

mkdir -p "packages/core"
echo "作成: packages/core/vitest.config.ts"
cat << 'EOF_1785833489_30755' > "packages/core/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    test: {
        globalSetup: ['./src/test/global-setup.ts'],    // ① テスト前に自動で db:push:test
        setupFiles: ['./src/test/setup.ts'],            // ② 各テスト実行前にテーブルデータを全消去
        fileParallelism: false,                         // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
    },
});
EOF_1785833489_30755

mkdir -p "packages/core/src/registry"
echo "作成: packages/core/src/registry/hono-auto-loader.ts"
cat << 'EOF_1785833489_21739' > "packages/core/src/registry/hono-auto-loader.ts"
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
EOF_1785833489_21739

mkdir -p "packages/core/src"
echo "作成: packages/core/src/index.ts"
cat << 'EOF_1785833489_12163' > "packages/core/src/index.ts"
export * from './auth/auth-registry';
export * from './registry/hono-auto-loader';
export * from './db';
export * from './config/env';
export * from './errors';
EOF_1785833489_12163

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.test.ts"
cat << 'EOF_1785833489_30206' > "packages/core/src/config/env.test.ts"
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
EOF_1785833489_30206

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.ts"
cat << 'EOF_1785833489_21859' > "packages/core/src/config/env.ts"
import { z } from 'zod';

// ==========================================
// 1. バックエンド用 (Node.js) スキーマ & 関数
// ==========================================
export const envSchema = z.object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    PORT: z.coerce.number().default(3001),
    DATABASE_URL: z.string().url({ message: 'DATABASE_URL は有効なURL形式である必要があります' }),
    JWT_SECRET: z
        .string()
        .min(32, 'JWT_SECRET must be at least 32 characters long')
        .default('super-secret-jwt-key-for-testing-purposes-123456'),
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
EOF_1785833489_21859

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/index.ts"
cat << 'EOF_1785833489_15530' > "packages/core/src/db/index.ts"
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';
import { validateEnv } from '../config/env';

const env = validateEnv();

// PostgreSQL 接続クライアントの作成
const queryClient = postgres(env.DATABASE_URL);
export const db = drizzle(queryClient, { schema });

// 💡 スキーマも外部から参照できるように export します
export { schema };
EOF_1785833489_15530

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/db.test.ts"
cat << 'EOF_1785833489_19318' > "packages/core/src/db/db.test.ts"
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
                passwordHash: 'hashed_password_sample_123',
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
EOF_1785833489_19318

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/schema.ts"
cat << 'EOF_1785833489_23950' > "packages/core/src/db/schema.ts"
import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
    id: serial('id').primaryKey(),
    name: text('name').notNull(),
    email: text('email').notNull().unique(),
    passwordHash: text('password_hash').notNull(),
    role: text('role').notNull().default('user'),
    createdAt: timestamp('created_at').defaultNow().notNull(),
});
EOF_1785833489_23950

mkdir -p "packages/core/src/auth"
echo "作成: packages/core/src/auth/auth-registry.ts"
cat << 'EOF_1785833489_10203' > "packages/core/src/auth/auth-registry.ts"
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
EOF_1785833489_10203

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/index.ts"
cat << 'EOF_1785833489_11201' > "packages/core/src/errors/index.ts"
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

export class UnauthorizedError extends AppError {
    constructor(message = 'Authentication token is missing or invalid') {
        super(401, 'unauthorized', 'Unauthorized', message);
    }
}
EOF_1785833489_11201

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/setup.ts"
cat << 'EOF_1785833489_5166' > "packages/core/src/test/setup.ts"
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
EOF_1785833489_5166

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/global-setup.ts"
cat << 'EOF_1785833489_27089' > "packages/core/src/test/global-setup.ts"
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
EOF_1785833489_27089

mkdir -p "packages/core/src"
echo "作成: packages/core/src/seed-dev-user.ts"
cat << 'EOF_1785833489_23134' > "packages/core/src/seed-dev-user.ts"
import { db } from './db'; // packages/core 内の db エクスポートのパス
import { users } from './db/schema'; // users スキーマ
import { hashPassword } from '@app/plugins-auth-local';
// packages/core にハッシュ関数（または bcrypt/argon2）があればそれを使用

async function main() {
    const email = 'mako65jp@gmail.com';
    const password = '1234'; // お好みのパスワード

    // もし core 内にハッシュ関数があれば使い、無ければ使っているライブラリでハッシュ化
    const hashedPassword = await hashPassword(password);

    await db.insert(users).values({
        email,
        passwordHash: hashedPassword,
        name: '開発ユーザー',
    }).onConflictDoNothing();

    console.log(`✅ User created: ${email}`);
    process.exit(0);
}

main().catch((err) => {
    console.error('❌ Failed:', err);
    process.exit(1);
});
EOF_1785833489_23134

mkdir -p "packages/core"
echo "作成: packages/core/drizzle.config.ts"
cat << 'EOF_1785833489_1496' > "packages/core/drizzle.config.ts"
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
EOF_1785833489_1496

mkdir -p "packages/features/sample"
echo "作成: packages/features/sample/package.json"
cat << 'EOF_1785833489_22527' > "packages/features/sample/package.json"
{
  "name": "@app/features-sample",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785833489_22527

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.ts"
cat << 'EOF_1785833489_21511' > "packages/features/sample/src/index.ts"
import { Hono } from 'hono';

export default function createSampleFeature() {
  const app = new Hono();

  app.get('/sample', (c) => {
    return c.json({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });

  return app;
}
EOF_1785833489_21511

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.test.ts"
cat << 'EOF_1785833489_30055' > "packages/features/sample/src/index.test.ts"
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
EOF_1785833489_30055

echo "作成: doc.md"
cat << 'EOF_1785833489_16442' > "doc.md"
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
EOF_1785833489_16442

echo "作成: SUMMRY.md"
cat << 'EOF_1785833489_4075' > "SUMMRY.md"
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
EOF_1785833489_4075

mkdir -p "apps/web"
echo "作成: apps/web/package.json"
cat << 'EOF_1785833489_31796' > "apps/web/package.json"
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
    "@testing-library/jest-dom": "^6.9.1",
    "@testing-library/react": "^16.3.2",
    "@types/react": "^18.2.55",
    "@types/react-dom": "^18.2.19",
    "@vitejs/plugin-react": "^6.0.5",
    "jsdom": "^29.1.1",
    "typescript": "^5.3.3"
  }
}
EOF_1785833489_31796

mkdir -p "apps/web"
echo "作成: apps/web/index.html"
cat << 'EOF_1785833489_6527' > "apps/web/index.html"
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
EOF_1785833489_6527

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.json"
cat << 'EOF_1785833489_23502' > "apps/web/tsconfig.json"
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "composite": true,
    "jsx": "react-jsx",
    "useDefineForClassFields": true,
    "allowJs": false,
    "allowSyntheticDefaultImports": true,
    "types": [
      "vite/client"
    ],
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
EOF_1785833489_23502

mkdir -p "apps/web"
echo "作成: apps/web/vitest.config.ts"
cat << 'EOF_1785833489_18764' > "apps/web/vitest.config.ts"
import { defineConfig, mergeConfig } from 'vitest/config';
import viteConfig from './vite.config.ts';

export default defineConfig(async (configEnv) => {
    // vite.config が関数の場合でも正しく評価してオブジェクトを取得
    const baseConfig = typeof viteConfig === 'function' ? viteConfig(configEnv) : viteConfig;

    return mergeConfig(
        baseConfig,
        defineConfig({
            test: {
                environment: 'jsdom', // 👈 ここを追加（すべてのテストで jsdom / DOM API を有効化）
                globals: true,        // describe, it, expect などをグローバル化する場合
                setupFiles: ['./src/test/setup.ts'],
            },
        })
    );
});
EOF_1785833489_18764

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.node.json"
cat << 'EOF_1785833489_18329' > "apps/web/tsconfig.node.json"
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
EOF_1785833489_18329

mkdir -p "apps/web/src/test"
echo "作成: apps/web/src/test/setup.ts"
cat << 'EOF_1785833489_21373' > "apps/web/src/test/setup.ts"
import '@testing-library/jest-dom';
EOF_1785833489_21373

mkdir -p "apps/web/src"
echo "作成: apps/web/src/main.tsx"
cat << 'EOF_1785833489_13487' > "apps/web/src/main.tsx"
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF_1785833489_13487

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.test.tsx"
cat << 'EOF_1785833489_14592' > "apps/web/src/context/AuthContext.test.tsx"
import { renderHook, act, waitFor } from '@testing-library/react';
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { AuthProvider, useAuth } from './AuthContext';
import React from 'react';

// fetch のモック設定
const globalFetch = vi.fn();
global.fetch = globalFetch;

describe('AuthContext / useAuth (Step 5.1)', () => {
    beforeEach(() => {
        localStorage.clear();
        vi.clearAllMocks();
    });

    const wrapper = ({ children }: { children: React.ReactNode }) => (
        <AuthProvider>{children}</AuthProvider>
    );

    it('初期状態では未認証であり、localStorage にトークンがなければユーザーは null であること', async () => {
        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isLoading).toBe(false);
        });

        expect(result.current.isAuthenticated).toBe(false);
        expect(result.current.user).toBeNull();
    });

    it('login 関数を実行すると API を呼び出し、トークンとユーザー情報を保存すること', async () => {
        const mockUser = { id: 1, name: 'Test User', email: 'test@example.com', role: 'user' };
        const mockToken = 'mock-jwt-token';

        // ログイン API のレスポンスをモック
        globalFetch.mockResolvedValueOnce({
            ok: true,
            status: 200,
            json: async () => ({ token: mockToken, user: mockUser }),
        });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await act(async () => {
            await result.current.login('test@example.com', 'password123');
        });

        expect(globalFetch).toHaveBeenCalledWith(
            '/api/auth/login',
            expect.objectContaining({
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email: 'test@example.com', password: 'password123' }),
            })
        );

        expect(localStorage.getItem('token')).toBe(mockToken);
        expect(result.current.isAuthenticated).toBe(true);
        expect(result.current.user).toEqual(mockUser);
    });

    it('logout 関数を実行するとトークンとユーザー情報が破棄されること', async () => {
        localStorage.setItem('token', 'existing-token');

        // /me API の初期化レスポンスをモック
        globalFetch.mockResolvedValueOnce({
            ok: true,
            status: 200,
            json: async () => ({ user: { id: 1, email: 'test@example.com', role: 'user' } }),
        });

        const { result } = renderHook(() => useAuth(), { wrapper });

        await waitFor(() => {
            expect(result.current.isAuthenticated).toBe(true);
        });

        act(() => {
            result.current.logout();
        });

        expect(localStorage.getItem('token')).toBeNull();
        expect(result.current.isAuthenticated).toBe(false);
        expect(result.current.user).toBeNull();
    });
});
EOF_1785833489_14592

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.tsx"
cat << 'EOF_1785833489_22091' > "apps/web/src/context/AuthContext.tsx"
import React, { createContext, useContext, useState, useEffect } from 'react';

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
    const [token, setToken] = useState<string | null>(() => localStorage.getItem('token'));
    const [isLoading, setIsLoading] = useState<boolean>(true);

    // 初期化時：localStorage にトークンがあれば /api/auth/me でユーザー情報を復元
    useEffect(() => {
        const initAuth = async () => {
            const storedToken = localStorage.getItem('token');
            if (!storedToken) {
                setIsLoading(false);
                return;
            }

            try {
                const res = await fetch('/api/auth/me', {
                    headers: {
                        Authorization: `Bearer ${storedToken}`,
                    },
                });

                if (res.ok) {
                    const data = await res.json();
                    setUser(data.user);
                    setToken(storedToken);
                } else {
                    localStorage.removeItem('token');
                    setToken(null);
                    setUser(null);
                }
            } catch (error) {
                console.error('Failed to restore authentication session:', error);
                localStorage.removeItem('token');
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
        const res = await fetch('/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, password }),
        });

        if (!res.ok) {
            const errorData = await res.json().catch(() => ({}));
            throw new Error(errorData.detail || 'Login failed');
        }

        const data = await res.json();
        localStorage.setItem('token', data.token);
        setToken(data.token);
        setUser(data.user);
    };

    // ログアウト処理
    const logout = () => {
        localStorage.removeItem('token');
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
EOF_1785833489_22091

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.tsx"
cat << 'EOF_1785833489_23836' > "apps/web/src/components/LoginForm.tsx"
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
EOF_1785833489_23836

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.test.tsx"
cat << 'EOF_1785833489_735' > "apps/web/src/components/LoginForm.test.tsx"
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
EOF_1785833489_735

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.tsx"
cat << 'EOF_1785833489_31984' > "apps/web/src/App.tsx"
// import React from 'react';
// import { env } from './env';
// import { LoginForm } from './components/LoginForm.tsx';

// export default function App() {
//   return (
//     <div>
//       <h1>DevContainer + Docker Compose {env.VITE_APP_TITLE}</h1>
//       <LoginForm />
//     </div>
//   );
// }
import React from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { LoginForm } from './components/LoginForm';

const MainContent: React.FC = () => {
  const { user, logout, isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return <div>読み込み中...</div>;
  }

  return (
    <main style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>DevContainer + Docker Compose マイアプリケーション</h1>

      {isAuthenticated && user ? (
        <div style={{ marginTop: '1rem', padding: '1rem', border: '1px solid #ccc', borderRadius: '4px' }}>
          <h2>ようこそ、{user.name || user.email} さん！</h2>
          <p><strong>Email:</strong> {user.email}</p>
          <p><strong>ID:</strong> {user.id}</p>
          <button
            onClick={logout}
            style={{ padding: '0.5rem 1rem', marginTop: '1rem', cursor: 'pointer' }}
          >
            ログアウト
          </button>
        </div>
      ) : (
        <div style={{ marginTop: '1rem' }}>
          <LoginForm />
        </div>
      )}
    </main>
  );
};

export function App() {
  return (
    <AuthProvider>
      <MainContent />
    </AuthProvider>
  );
}

export default App;
EOF_1785833489_31984

mkdir -p "apps/web/src"
echo "作成: apps/web/src/env.ts"
cat << 'EOF_1785833489_923' > "apps/web/src/env.ts"
import { clientEnvSchema, type ClientEnv } from '@app/core';

// Vite の import.meta.env を Zod で検証・補完
export const env: ClientEnv = clientEnvSchema.parse({
    VITE_PORT: import.meta.env.VITE_PORT,
    VITE_API_TARGET_URL: import.meta.env.VITE_API_TARGET_URL,
    VITE_APP_TITLE: import.meta.env.VITE_APP_TITLE,
});
EOF_1785833489_923

mkdir -p "apps/web"
echo "作成: apps/web/vite.config.ts"
cat << 'EOF_1785833489_15691' > "apps/web/vite.config.ts"
import { defineConfig } from 'vitest/config';
import { loadEnv } from 'vite';
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
EOF_1785833489_15691

mkdir -p "apps/api"
echo "作成: apps/api/package.json"
cat << 'EOF_1785833489_23356' > "apps/api/package.json"
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
EOF_1785833489_23356

mkdir -p "apps/api"
echo "作成: apps/api/tsconfig.json"
cat << 'EOF_1785833489_27835' > "apps/api/tsconfig.json"
{
    "extends": "../../tsconfig.json",
    "compilerOptions": {
        "target": "ES2022",
        "module": "ESNext",
        "moduleResolution": "bundler",
        "outDir": "./dist",
        "types": [
            "node"
        ]
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1785833489_27835

mkdir -p "apps/api"
echo "作成: apps/api/vitest.config.ts"
cat << 'EOF_1785833489_30353' > "apps/api/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
  },
});
EOF_1785833489_30353

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.ts"
cat << 'EOF_1785833489_4549' > "apps/api/src/index.ts"
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { validateEnv, formatEnvForLog } from '@app/core';
import { AppError, ProblemDetails, ValidationError } from '@app/core';
import { loadFeatureModules } from '@app/core';
import { AuthRegistry } from '@app/core';
import { LocalAuthPlugin } from '@app/plugins-auth-local';
import { ActiveDirectoryAuthPlugin } from '@app/plugins-auth-ad';
import { authRouter } from './routes/auth';

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
// 💡 authRouter(env.JWT_SECRET) のように実行して Hono インスタンスを渡す
app.route('/api/auth', authRouter(env.JWT_SECRET));

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
EOF_1785833489_4549

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.test.ts"
cat << 'EOF_1785833489_4440' > "apps/api/src/index.test.ts"
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
EOF_1785833489_4440

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.ts"
cat << 'EOF_1785833489_4329' > "apps/api/src/routes/auth.ts"
import { Hono } from 'hono';
import { z } from 'zod';
import { eq } from 'drizzle-orm';
import { db, schema, UnauthorizedError } from '@app/core';
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
            where: eq(schema.users.email, email),
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
EOF_1785833489_4329

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.test.ts"
cat << 'EOF_1785833489_9406' > "apps/api/src/routes/auth.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { authRouter } from './auth';
import { AppError, db, schema } from '@app/core';
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
        await db.delete(schema.users);

        // テストユーザーを挿入
        const hashedPassword = await hashPassword('password123');
        await db.insert(schema.users).values({
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
            const body = await res.json();
            expect(body.token).toBeDefined();
            expect(body.user.email).toBe('test@example.com');
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
            const { token } = await loginRes.json();

            // 2. /me にリクエスト
            const meRes = await app.request('/api/auth/me', {
                headers: { Authorization: `Bearer ${token}` },
            });

            expect(meRes.status).toBe(200);
            const meBody = await meRes.json();
            expect(meBody.user.email).toBe('test@example.com');
        });
    });
});
EOF_1785833489_9406

mkdir -p "apps/api/src"
echo "作成: apps/api/src/env.ts"
cat << 'EOF_1785833489_30862' > "apps/api/src/env.ts"
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
EOF_1785833489_30862

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.ts"
cat << 'EOF_1785833489_21830' > "apps/api/src/middlewares/auth-middleware.ts"
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
EOF_1785833489_21830

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.test.ts"
cat << 'EOF_1785833489_4255' > "apps/api/src/middlewares/auth-middleware.test.ts"
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
        const body = await res.json();

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
        const body = await res.json();
        expect(body.message).toBe('Success');
        expect(body.user).toMatchObject(payload);
    });
});
EOF_1785833489_4255

echo "作成: README.md"
cat << 'EOF_1785833489_11188' > "README.md"
# 📖 プロジェクト基本仕様書 (Project Architecture Specification) - 全体統合版

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
| **`packages/core`** | 共通基盤 | システム全域で利用される不変的な「基盤ルール」を集約 | 型定義、環境変数検証、DB接続・スキーマ定義、共通エラー定義 (RFC 7807)、動的ローダー | 上位のビジネスロジックや特定アプリへの依存厳禁 |
| **`packages/plugins/`** | プラグイン | 運用環境や顧客要件に応じて切り替え・拡張される機能を独立化 | **`auth-local`** (Bcrypt / JWT ユーティリティ)、外部 ID プロバイダー（Active Directory 等）の認証アダプター | アプリ層から依存性を注入（DI）して利用 |
| **`packages/features/`** | 業務ドメイン | 特定の業務機能を単位ごとにカプセル化し、独立した追加・削除・テストを可能化 | ドメイン専用 API ルート、ビジネスロジック、関連 UI コンポーネント | 上位アプリから単方向参照、他ドメインとは原則独立 |

### 3.2 拡張ルールと依存方向 (Extension Rules)

1. **機能追加の手順:**
新しいドメイン機能や連携モジュールを追加する際は、`packages/features/` または `packages/plugins/` 配下に新規パッケージを作成し、ルートのワークスペース管理に登録します。
2. **単方向依存の徹底:**
依存の方向は常に **「上位（`apps/`）から下位（`packages/`）」** の一方向に限定します。下位パッケージから上位アプリケーションへの逆参照は厳禁とします。

---

## 4. データベース & ORM 仕様 (Database & ORM)

### 4.1 ORM の設計と接続管理

* **型安全性の保障:** アプリケーションコードとデータベース構造の不一致を防ぐため、完全な TypeScript サポートを持つ ORM (Drizzle ORM) を採用します。
* **シングルトン接続:** データベースへのコネクション pool の無駄遣いを防ぐため、`packages/core/src/db/index.ts` にて環境変数の正常性を検証した上で、単一の接続インスタンス（`db`）を保持・供給します。

### 4.2 スキーマ定義 (Single Source of Truth)

データベースの構造は、`packages/core/src/db/schema.ts` を正として定義します。

#### `users` テーブル

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
│   │   │   ├── middlewares/      # ミドルウェア層
│   │   │   │   ├── auth-middleware.ts      # JWT 検証・コンテキスト設定ミドルウェア
│   │   │   │   └── auth-middleware.test.ts # ミドルウェア単体・統合テスト
│   │   │   └── routes/           # アプリケーション固有のルーティング
│   │   │       ├── auth.ts       # 認証 API ルート (/login, /me)
│   │   │       └── auth.test.ts  # 認証 API 統合テスト
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
    │   │   │   ├── index.ts      # 共通エラークラス群 (`AppError`, `UnauthorizedError`等)
    │   │   │   └── errors.test.ts# エラークラス構造化単体テスト
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
    │       ├── src/
    │       │   ├── index.ts      # パッケージエントリーポイント
    │       │   ├── password.ts   # Bcrypt パスワードハッシュ化・照合関数
    │       │   ├── jwt.ts        # Jose による JWT 署名・検証関数
    │       │   └── auth.test.ts  # パスワード & JWT 処理単体テスト
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
| `JWT_SECRET` | API | 32文字以上の文字列 | JWT アクセストークンの署名・検証に使用するシークレットキー |
| `VITE_PORT` | Web | 数値・文字列 | 開発用 Web サーバーの待受ポート |
| `VITE_API_TARGET_URL` | Web | URL形式文字列 | 開発時の API 転送先 (DevProxy ターゲット) |
| `VITE_APP_TITLE` | Web | 文字列 | アプリケーションの表示タイトル |

### 7.2 セキュリティ & バリデーション設計

1. **フェイルファスト（Fail-Fast）原則:**
アプリケーション起動時に環境変数を検証（Zod スキーマ）し、1つでも不備があれば起動を即座に安全に中断します。不正な設定のまま不完全な状態で動作し続けることを防ぎます。
2. **機密情報のログマスク（伏字化）:**
動作確認用に設定内容をシステムログへ出力する際、データベースパスワード等の認証情報が含まれる文字列（`DATABASE_URL`）は自動的にマスク処理（`***` 化）を施し、ログからの情報漏洩を防ぎます。
3. **パスワード保存とトークン生成:**
平文パスワードの保持は厳禁とし、`bcryptjs` によりソルト付きでハッシュ化された値のみを保存します。JWT の生成・検証には `jose` ライブラリを使用し、ステートレスでスケーラブルな認証を実現します。
4. **安全なエラー詳細返却:**
ログイン失敗時は「ユーザーが存在しない」のか「パスワードが違う」のかを区別させず、一律 `Invalid credentials.` (401) を返却し、ユーザー存在確認攻撃を防ぎます。
5. **フロントエンドの環境変数カプセル化:**
ブラウザ環境へ公開してよい変数は `VITE_` プレフィックスが付与されたものに限定します。グローバルな `process.env` への直接アクセスによる事故を防ぐため、フロントエンド用の安全な参照モジュール（`apps/web/src/env.ts`）を経由したアクセスのみを許可します。

---

## 8. API エラーレスポンス仕様 (RFC 7807 準拠)

システムから返却されるエラーレスポンスの構造を統一し、クライアント側（フロントエンド）でのエラー処理・デバッグを容易にするため、**RFC 7807 (Problem Details for HTTP APIs)** に準拠した構造を採用します。

### 8.1 統一エラーレスポンス構造

エラー時は、単なるテキストではなく必ず以下の統一フォーマット（JSON）で返却します。

| フィールド名 | キー名 | 役割・説明 | 設定例 |
| --- | --- | --- | --- |
| **エラー分類 URI** | `type` | エラーの種類を明確に識別するURI | `"about:blank"` または `"[https://api.example.com/errors/unauthorized](https://api.example.com/errors/unauthorized)"` |
| **タイトル** | `title` | エラーの概要（ステータスコードに準拠） | `"Bad Request"`, `"Unauthorized"`, `"Not Found"` |
| **ステータスコード** | `status` | HTTP ステータスコード | `400`, `401`, `404`, `500` |
| **詳細メッセージ** | `detail` | 発生原因の具体的な説明 | `"Authentication token is missing or invalid format."` |
| **発生パス** | `instance` | エラーが発生したリクエスト URI パス | `"/api/auth/me"` |
| **フィールド別詳細** | `invalidParams` | **(任意)** 入力検証エラー時の違反項目・理由リスト | `[{ "name": "email", "reason": "Invalid syntax" }]` |

### 8.2 エラー制御方針

1. **例外クラスの階層化 (`AppError`):**
すべてのドメイン例外（`ValidationError`, `UnauthorizedError`, `NotFoundError` 等）は基態クラス `AppError` を継承して定義します。
2. **未定義エラーのキャッチ (500 Internal Server Error):**
予期せぬ例外が発生した場合でも、スタックトレースや内部実装の秘匿情報をそのままクライアントへ返さず、Hono の `app.onError` ハンドラを介して規格化された 500 エラー構造へ変換して返却します。
3. **入力検証エラーの自動標準化 (400 Bad Request):**
リクエストデータの検証に失敗した場合、不備のある入力フィールドとエラー理由を `invalidParams` へ自動的にマッピングして通知します。

---

## 9. 認証・認可 API 仕様 (Authentication API Spec)

ベース URL: `/api`

### 9.1 ログイン & トークン発行 (`POST /api/auth/login`)

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
    "name": "Test User",
    "email": "test@example.com",
    "role": "user"
  }
}

```


* **エラーレスポンス (401 Unauthorized - RFC 7807):**
```json
{
  "type": "about:blank",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Invalid credentials.",
  "instance": "/api/auth/login"
}

```



### 9.2 認証ユーザー情報取得 (`GET /api/auth/me`)

* **認証:** 必要 (`Authorization: Bearer <JWT_TOKEN>`)
* **リクエストヘッダー:**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

```


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


* **エラーレスポンス (401 Unauthorized - RFC 7807):**
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

## 10. テストアーキテクチャ & ライフサイクル (Testing Architecture)

テストの信頼性と再現性を維持するため、**「テスト実行時の環境の自動セットアップ」** と **「テストケース間の相互干渉防止」** を自動化しています。

### 10.1 テスト基盤

* **テストランナー:** Vitest（高速なインメモリ実行およびモジュール連携環境を提供）

### 10.2 テスト自動化ライフサイクル

1. **テスト開始前のデータベース構造の自動最新化 (Global Setup):**
全テストスイートが実行される直前に、**テスト用データベースのテーブル構造（スキーマ）を常に最新の状態へ自動同期** します。開発者が手動でマイグレーションする作業を不要にし、最新コード仕様でのテストを保証します。
*(内部補足: `globalSetup` 内で `drizzle-kit push` 相当の最新化コマンドをテスト用設定 `drizzle-test.config.ts` で実行します)*
2. **テストケース間の完全な状態隔離 (Setup Files):**
個々のテスト（`it` / `test`）が実行される直前に、**データベース内の既存データを自動的に一括クリーンアップ**（全テーブルに対する `TRUNCATE CASCADE` 実行）します。
3. **テスト実行環境の分離保護:**
テスト実行時（`NODE_ENV=test`）は、実際の HTTP ポートの解放・バインドを抑制し、ポート競合を防ぎつつインメモリ HTTP リクエストで API 動作を高速検証します。

---

## 11. 実行スクリプト リファレンス (Scripts)

プロジェクト内で利用する標準的なコマンドです。

### 11.1 開発サーバー起動

すべてのアプリケーション（API・Web）を開発モードで並行起動します。

```bash
npm run dev

```

### 11.2 全テストの自動実行 (TDD)

すべてのパッケージの単体テスト、DB 連携テスト、ミドルウェア・API 統合テストを一括実行します（実行時に DB スキーマの最新化とデータ破棄が自動適用されます）。

```bash
npm test

```

### 11.3 テスト用 DB スキーマの手動同期

テスト環境のデータベース構造を手動で最新状態へ更新したい場合に実行します。

```bash
npm run db:push:test

```
EOF_1785833489_11188

echo "作成: .env"
cat << 'EOF_1785833489_19818' > ".env"
# バックエンド用
PORT=3001
DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db
TEST_DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db_test
JWT_SECRET=your-super-secret-jwt-key-must-be-at-least-32-bytes-long

# フロントエンド用 (VITE_ プレフィックスを付ける)
# /workspace/apps/web/src/env.ts と同期する
VITE_PORT=3000
VITE_API_TARGET_URL=http://127.0.0.1:3001
VITE_APP_TITLE=マイアプリケーション
EOF_1785833489_19818

echo -e "\n復元が完了しました！"
