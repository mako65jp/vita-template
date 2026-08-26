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
cat << 'EOF_1787723353_19170' > "package.json"
{
    "name": "monorepo",
    "private": true,
    "type": "module",
    "workspaces": [
        "apps/*",
        "shared/*",
        "plugins/*",
        "features/*"
    ],
    "scripts": {
        "build": "npm run build --workspaces --if-present",
        "coverage": "vitest run --coverage",
        "dev": "npm start",
        "dev:api": "npm --workspace=apps/api run dev",
        "dev:web": "npm --workspace=apps/web run dev",
        "db:push": "npm run db:push --workspaces --if-present",
        "db:seed": "npm run db:seed --workspaces --if-present",
        "pkg:lint": "npx manypkg check",
        "pkg:fix": "npx manypkg fix && npm install",
        "start": "concurrently \"npm run dev:api\" \"npm run dev:web\"",
        "test": "vitest run --watch --no-cache",
        "typecheck": "npm run typecheck --workspaces --if-present"
    },
    "devDependencies": {
        "@manypkg/cli": "^0.25.1",
        "@types/node": "^26.2.0",
        "@types/pg": "^8.23.1",
        "@vitest/coverage-v8": "^4.1.10",
        "concurrently": "^8.2.2",
        "drizzle-pgmem": "^0.6.2",
        "pg-mem": "^3.0.14",
        "vite": "^8.2.0",
        "vitest": "^4.1.11"
    },
    "dependencies": {
        "pg": "^8.23.0"
    }
}
EOF_1787723353_19170

echo "作成: cat_files.sh"
cat << 'EOF_1787723353_12378' > "cat_files.sh"
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
EOF_1787723353_12378

echo "作成: .gitignore"
cat << 'EOF_1787723353_10265' > ".gitignore"
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
EOF_1787723353_10265

mkdir -p "shared"
echo "作成: shared/package.json"
cat << 'EOF_1787723353_10927' > "shared/package.json"
{
  "devDependencies": {
    "@types/node": "^26.2.0"
  }
}
EOF_1787723353_10927

mkdir -p "shared/schemas"
echo "作成: shared/schemas/package.json"
cat << 'EOF_1787723353_20935' > "shared/schemas/package.json"
{
    "name": "@shared/schemas",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "main": "./index.ts",
    "types": "./index.ts",
    "exports": {
        ".": "./index.ts"
    },
    "scripts": {
        "build": "tsc",
        "typecheck": "tsc --noEmit"
    },
    "dependencies": {
        "postgres": "^3.4.9"
    },
    "devDependencies": {
        "drizzle-kit": "^0.31.10"
    }
}
EOF_1787723353_20935

mkdir -p "shared/schemas"
echo "作成: shared/schemas/index.ts"
cat << 'EOF_1787723353_10856' > "shared/schemas/index.ts"
export * from './src/users';
export * from './src/plugins';
EOF_1787723353_10856

mkdir -p "shared/schemas"
echo "作成: shared/schemas/vitest.config.ts"
cat << 'EOF_1787723353_23075' > "shared/schemas/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'jsdom',
        setupFiles: ['../../vitest-clear.ts'],               // ② 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1787723353_23075

mkdir -p "shared/schemas/src"
echo "作成: shared/schemas/src/plugins.test.ts"
cat << 'EOF_1787723353_5291' > "shared/schemas/src/plugins.test.ts"
import { describe, it, expect } from 'vitest';
import { db } from '@shared/server';
import { plugins } from './plugins';
import { eq } from 'drizzle-orm';

describe('Plugins DB Integration Tests', () => {

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
EOF_1787723353_5291

mkdir -p "shared/schemas/src"
echo "作成: shared/schemas/src/plugins.ts"
cat << 'EOF_1787723353_3868' > "shared/schemas/src/plugins.ts"
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
EOF_1787723353_3868

mkdir -p "shared/schemas/src"
echo "作成: shared/schemas/src/users.ts"
cat << 'EOF_1787723353_16845' > "shared/schemas/src/users.ts"
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
EOF_1787723353_16845

mkdir -p "shared/schemas/src"
echo "作成: shared/schemas/src/users.test.ts"
cat << 'EOF_1787723353_22216' > "shared/schemas/src/users.test.ts"
import { describe, it, expect } from 'vitest';
import { db } from '@shared/server';
import { users } from './users';
import { eq } from 'drizzle-orm';

describe('Users DB Integration Tests', () => {

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
EOF_1787723353_22216

mkdir -p "shared"
echo "作成: shared/tsconfig.json"
cat << 'EOF_1787723353_27089' > "shared/tsconfig.json"
{
    "extends": "../tsconfig.json",
    "include": [
        "**/src/*"
    ]
}
EOF_1787723353_27089

mkdir -p "shared"
echo "作成: shared/vitest.config.ts"
cat << 'EOF_1787723353_31034' > "shared/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true
    },
    test: {
        globals: true,
        // fileParallelism: false,                         // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['../vitest-clear.ts'],            // ② 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1787723353_31034

mkdir -p "shared/server"
echo "作成: shared/server/package.json"
cat << 'EOF_1787723353_30574' > "shared/server/package.json"
{
    "name": "@shared/server",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "main": "./index.ts",
    "types": "./index.ts",
    "exports": {
        ".": "./index.ts",
        "./auth": "./auth/*.ts",
        "./db": "./db/*.ts",
        "./utils": "./utils/*.ts"
    },
    "scripts": {
        "build": "tsc",
        "db:push": "drizzle-kit push",
        "db:seed": "tsx db/seed.ts",
        "typecheck": "tsc --noEmit"
    },
    "dependencies": {
        "bcryptjs": "^3.0.3",
        "drizzle-orm": "^0.45.2",
        "glob": "^13.0.6",
        "jose": "^6.2.8",
        "postgres": "^3.4.9"
    },
    "devDependencies": {
        "@types/bcryptjs": "^2.4.6",
        "drizzle-kit": "^0.31.10"
    }
}
EOF_1787723353_30574

mkdir -p "shared/server"
echo "作成: shared/server/index.ts"
cat << 'EOF_1787723353_16897' > "shared/server/index.ts"
export * from './db'
export * from './utils'
EOF_1787723353_16897

mkdir -p "shared/server/db"
echo "作成: shared/server/db/index.ts"
cat << 'EOF_1787723353_25177' > "shared/server/db/index.ts"
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import { env } from '@shared/functions';
import * as schema from '@shared/schemas';

const activeQueryClient = postgres(env.DATABASE_URL);
const db = drizzle(activeQueryClient, { schema });
export { activeQueryClient, db };

// 1. スキーマオブジェクト全体を export
export { schema };

// 2. 個別のテーブルも直接参照できるように directly re-export
export * from '@shared/schemas';
EOF_1787723353_25177

mkdir -p "shared/server/db"
echo "作成: shared/server/db/seed.ts"
cat << 'EOF_1787723353_23307' > "shared/server/db/seed.ts"
import { db, users } from './index';
import { hashPassword } from '@plugins/auth-local';
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

// 実行と終了の制御
async function main() {
    try {
        await seed();
        console.log('🎉 シード処理が完了しました');
    } catch (err) {
        console.error('❌ シード処理に失敗しました:', err);
        process.exitCode = 1;
    } finally {
        // 必要に応じてここで db.client.end() などの切断処理を行うか、直接プロセスを終了します
        process.exit();
    }
}

main();
EOF_1787723353_23307

mkdir -p "shared/server/utils"
echo "作成: shared/server/utils/index.ts"
cat << 'EOF_1787723353_21659' > "shared/server/utils/index.ts"
export * from './path';
EOF_1787723353_21659

mkdir -p "shared/server/utils"
echo "作成: shared/server/utils/path.test.ts"
cat << 'EOF_1787723353_26721' > "shared/server/utils/path.test.ts"
import { describe, it, expect } from 'vitest';
import path from 'node:path';
import fs from 'node:fs';
import { getProjectRootDir, resolveFromProjectRoot } from './path';

describe('path utils', () => {
    it('getProjectRootDir がプロジェクトのルートディレクトリ（package.json が存在する場所）を返すこと', () => {
        const rootDir = getProjectRootDir();

        // ルートディレクトリとして正しく判定されているか（ルートの package.json の存在確認）
        const rootPackageJsonPath = path.join(rootDir, 'package.json');
        expect(fs.existsSync(rootPackageJsonPath)).toBe(true);
    });

    it('resolveFromProjectRoot がルートからの相対パスを正しい絶対パスに変換すること', () => {
        const resolvedPath = resolveFromProjectRoot('shared', 'core');
        const expectedPath = path.resolve(getProjectRootDir(), 'shared/core');

        expect(resolvedPath).toBe(expectedPath);
    });
});
EOF_1787723353_26721

mkdir -p "shared/server/utils"
echo "作成: shared/server/utils/path.ts"
cat << 'EOF_1787723353_373' > "shared/server/utils/path.ts"
// shared/core/src/utils/path.ts
import path from 'node:path';
import { fileURLToPath } from 'node:url';

/**
 * モノレポのプロジェクトルート（/workspace 等）を安全かつ環境依存なしで取得する
 */
export function getProjectRootDir(): string {
    // ESM 環境での自ファイル位置取得
    const filename = fileURLToPath(import.meta.url);
    const dirname = path.dirname(filename);

    // shared/core/src/utils から見たプロジェクトルートディレクトリを算出
    return path.resolve(dirname, '../../../');
}

/**
 * プロジェクトルートからの相対パスを受け取り、OS依存のない絶対パスを返す
 */
export function resolveFromProjectRoot(...paths: string[]): string {
    return path.resolve(getProjectRootDir(), ...paths);
}
EOF_1787723353_373

mkdir -p "shared/server"
echo "作成: shared/server/vitest.config.ts"
cat << 'EOF_1787723353_3172' > "shared/server/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        setupFiles: ['../../vitest-clear.ts'],               // ② 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1787723353_3172

mkdir -p "shared/server"
echo "作成: shared/server/drizzle.config.ts"
cat << 'EOF_1787723353_10817' > "shared/server/drizzle.config.ts"
import { defineConfig } from 'drizzle-kit';
import { env } from '@shared/functions';

export default defineConfig({
    schema: '../schemas/index.ts',
    out: './drizzle',
    dialect: 'postgresql',
    dbCredentials: {
        url: env.DATABASE_URL,
    },
});
EOF_1787723353_10817

mkdir -p "shared/functions"
echo "作成: shared/functions/package.json"
cat << 'EOF_1787723353_8745' > "shared/functions/package.json"
{
    "name": "@shared/functions",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "main": "./index.ts",
    "types": "./index.ts",
    "exports": {
        ".": "./index.ts",
        "./constants": "./constants.ts"
    },
    "scripts": {
        "build": "tsc",
        "typecheck": "tsc --noEmit"
    },
    "dependencies": {
        "postgres": "^3.4.9"
    },
    "devDependencies": {
        "drizzle-kit": "^0.31.10"
    }
}
EOF_1787723353_8745

mkdir -p "shared/functions"
echo "作成: shared/functions/index.ts"
cat << 'EOF_1787723353_19536' > "shared/functions/index.ts"
export * from './src/auth-registry'
export * from './src/constants'
export * from './src/env'
export * from './src/registry'
EOF_1787723353_19536

mkdir -p "shared/functions"
echo "作成: shared/functions/vitest.config.ts"
cat << 'EOF_1787723353_23206' > "shared/functions/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
    },
});
EOF_1787723353_23206

mkdir -p "shared/functions/src"
echo "作成: shared/functions/src/constants.ts"
cat << 'EOF_1787723353_31094' > "shared/functions/src/constants.ts"
export const AUTH_TOKEN_KEY = 'auth_token';
EOF_1787723353_31094

mkdir -p "shared/functions/src"
echo "作成: shared/functions/src/auth-registry.ts"
cat << 'EOF_1787723353_7869' > "shared/functions/src/auth-registry.ts"

export interface AuthUser {
    id: string | number;
    email?: string;
    name: string;
    role?: string;
}

export interface AuthPlugin {
    name: string;
    authenticate(credentials: Record<string, any>): Promise<AuthUser>;
}

/**
 * 認証プラグインのレジストリ管理
 */
export class AuthPluginRegistry {
    private static plugins = new Map<string, AuthPlugin>();

    static register(plugin: AuthPlugin) {
        this.plugins.set(plugin.name, plugin);
    }

    static get(name: string): AuthPlugin {
        const plugin = this.plugins.get(name);
        if (!plugin) {
            throw new Error(`認証プラグイン "${name}" が登録されていません。`);
        }
        return plugin;
    }
}

EOF_1787723353_7869

mkdir -p "shared/functions/src"
echo "作成: shared/functions/src/registry.ts"
cat << 'EOF_1787723353_32065' > "shared/functions/src/registry.ts"
// shared/core/src/plugins/registry.ts
import { Hono } from 'hono';

export interface PluginNavItem {
    id: string;             // タブ選択等で識別するためのID (例: 'users')
    label: string;          // 表示名
    path: string;           // パス
    icon?: string;          // アイコン
    roles?: string[];       // 表示権限 (例: ['admin'])。未指定時は全ユーザー表示
}

export interface PluginManifest {
    id: string;             // 一意キー (例: 'user-management')
    name: string;           // 表示名
    description?: string;   // 説明
    routes?: Hono;          // プラグインが提供する Hono ルーター（UI専用登録時は省略可能）
    navItems?: PluginNavItem[]; // フロントエンド表示用メニュー情報
    requiredRole?: string;  // 💡 API 全体に適用するアクセス制限ロール (例: 'admin')
}

export class PluginRegistry {
    private static plugins = new Map<string, PluginManifest>();

    static clear() {
        this.plugins = new Map<string, PluginManifest>();
    }

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

EOF_1787723353_32065

mkdir -p "shared/functions/src"
echo "作成: shared/functions/src/env.test.ts"
cat << 'EOF_1787723353_17991' > "shared/functions/src/env.test.ts"
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

describe('.env', () => {
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
        JWT_SECRET: 'super-secret-jwt-key-with-at-least-32-chars!',
        CORS_ORIGIN: 'http://localhost:3000',
        AUTH_PROVIDER: 'local',
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

        it('AUTH_PROVIDER が ad の場合、LDAP_URL と LDAP_DOMAIN が揃っていれば検証に成功すること', () => {
            const adEnv = {
                ...validMockServerEnv,
                AUTH_PROVIDER: 'ad',
                LDAP_URL: 'ldap://dc.example.com:389',
                LDAP_DOMAIN: 'example.com',
            };

            const result = parseServerEnv(adEnv);
            expect(result.AUTH_PROVIDER).toBe('ad');
            expect(result.LDAP_URL).toBe('ldap://dc.example.com:389');
            expect(result.LDAP_DOMAIN).toBe('example.com');
        });

        it('AUTH_PROVIDER が ad で、LDAP_URL または LDAP_DOMAIN が欠けている場合、例外がスローされること', () => {
            const invalidAdEnv = {
                ...validMockServerEnv,
                AUTH_PROVIDER: 'ad',
                // LDAP_URL がない、LDAP_DOMAIN がない状態
            };

            expect(() => parseServerEnv(invalidAdEnv)).toThrow('[Server] 環境変数の検証に失敗しました');
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
                CORS_ORIGIN: 'http://localhost:3000',
                DATABASE_URL: 'postgresql://postgres:my-secret-password@localhost:5432/app_db',
                JWT_SECRET: 'super-secret-jwt-key-with-at-least-32-chars!',
                AUTH_PROVIDER: 'local',
            };

            const formatted = formatEnvForLog(mockParsedServerEnv);

            // マスクされているかの検証
            expect(formatted).not.toContain('my-secret-password');
            expect(formatted).not.toContain('test-password');
            expect(formatted).not.toContain('super-secret-jwt-key-with-at-least-32-chars!');

            expect(formatted).toContain('postgresql://postgres:***@localhost:5432/app_db');
            expect(formatted).toContain('"JWT_SECRET": "***"');
        });
    });

});
EOF_1787723353_17991

mkdir -p "shared/functions/src"
echo "作成: shared/functions/src/env.ts"
cat << 'EOF_1787723353_22216' > "shared/functions/src/env.ts"
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
        PORT: z.coerce.number().int().positive()
            .default(DEFAULT_BACKEND_PORT),
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

        // サーバー側では必須（optional 化の妥協は不要）
        JWT_SECRET: z.string().min(32, { message: 'JWT_SECRET は32文字以上である必要があります' }),

        // 認証プロバイダ選択・AD用設定 ---
        AUTH_PROVIDER: z.enum(['local', 'ad'])
            .default('local'),
        LDAP_URL: z.string().optional(),
        LDAP_DOMAIN: z.string().optional(),
    })
    .superRefine((data, ctx) => {
        if (data.NODE_ENV === 'production' && !data.DATABASE_URL) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                path: ['DATABASE_URL'],
                message: '本番環境では DATABASE_URL の指定が必須です',
            });
        }
        if (data.AUTH_PROVIDER === 'ad' && (!data.LDAP_URL || !data.LDAP_DOMAIN)) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                path: ['LDAP_URL'],
                message: 'AUTH_PROVIDER が ad の場合、LDAP_URL および LDAP_DOMAIN の指定は必須です',
            });
        }
    })
    .transform((data) => ({
        ...data,
        API_BASE_URL: data.API_BASE_URL ?? `http://localhost:${data.PORT}`,
        CORS_ORIGIN: data.CORS_ORIGIN ?? `http://localhost:${DEFAULT_FRONTEND_PORT}`,
        DATABASE_URL: data.DATABASE_URL
            ?? (data.NODE_ENV !== 'production' ? 'postgresql://postgres:postgres@db:5432/app_db' : ''),
    }));

export type ClientEnv = z.infer<typeof clientEnvSchema>;
export type ServerEnv = z.infer<typeof serverEnvSchema>;

// ==========================================
// 2. 環境別の安全な評価・生成処理
// ==========================================

/** クライアント環境変数のパース (Vite 環境) */
function getClientEnv(): ClientEnv {
    const metaEnv = typeof import.meta !== 'undefined'
        ? (import.meta as { env?: Record<string, string> }).env
        : undefined;
    const targetEnv = metaEnv
        ? metaEnv
        : ((typeof process !== 'undefined' && process.env) ? process.env : {});
    const result = clientEnvSchema.safeParse(targetEnv);
    if (!result.success) {
        throw new Error(`[Client] 環境変数の検証に失敗しました:\n${JSON.stringify(result.error.format(), null, 2)}`);
    }
    return result.data;
}

/** サーバー環境変数のパース (Node.js 環境) */
function getServerEnv(): ServerEnv {
    const targetEnv = typeof process !== 'undefined' && process.env ? process.env : {};
    const result = serverEnvSchema.safeParse(targetEnv);
    if (!result.success) {
        throw new Error(`[Server] 環境変数の検証に失敗しました:\n${JSON.stringify(result.error.format(), null, 2)}`);
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
            throw new Error('❌ [Security Alert] フロントエンドからサーバー環境変数を参照することはできません。');
        },
    }));

export function formatEnvForLog(targetEnv: ServerEnv = env): string {
    const maskedEnv = { ...targetEnv };
    if (maskedEnv.DATABASE_URL) maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL.replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    if (maskedEnv.JWT_SECRET) maskedEnv.JWT_SECRET = '***';
    return JSON.stringify(maskedEnv, null, 2);
}
EOF_1787723353_22216

mkdir -p "shared/errors"
echo "作成: shared/errors/package.json"
cat << 'EOF_1787723353_17935' > "shared/errors/package.json"
{
    "name": "@shared/errors",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "main": "./index.ts",
    "types": "./index.ts",
    "exports": {
        ".": "./index.ts"
    },
    "scripts": {
        "build": "tsc",
        "typecheck": "tsc --noEmit"
    },
    "dependencies": {
        "postgres": "^3.4.9"
    },
    "devDependencies": {
        "drizzle-kit": "^0.31.10"
    }
}
EOF_1787723353_17935

mkdir -p "shared/errors"
echo "作成: shared/errors/index.ts"
cat << 'EOF_1787723353_6804' > "shared/errors/index.ts"
export * from './src/types';
export * from './src/app-error';
export * from './src/bad-request-error';
export * from './src/forbidden-error';
export * from './src/internal-server-error';
export * from './src/not-found-error';
export * from './src/unauthorized-error';
export * from './src/validation-error';
EOF_1787723353_6804

mkdir -p "shared/errors"
echo "作成: shared/errors/vitest.config.ts"
cat << 'EOF_1787723353_6529' > "shared/errors/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
    },
});
EOF_1787723353_6529

mkdir -p "shared/errors/src"
echo "作成: shared/errors/src/unauthorized-error.ts"
cat << 'EOF_1787723353_23611' > "shared/errors/src/unauthorized-error.ts"
import { AppError } from './app-error';

export class UnauthorizedError extends AppError {
    constructor(message = 'Authentication token is missing or invalid') {
        super(401, 'unauthorized', 'Unauthorized', message);
    }
}
EOF_1787723353_23611

mkdir -p "shared/errors/src"
echo "作成: shared/errors/src/app-error.ts"
cat << 'EOF_1787723353_2641' > "shared/errors/src/app-error.ts"
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
EOF_1787723353_2641

mkdir -p "shared/errors/src"
echo "作成: shared/errors/src/bad-request-error.ts"
cat << 'EOF_1787723353_26151' > "shared/errors/src/bad-request-error.ts"
import { AppError } from './app-error';

export class BadRequestError extends AppError {
    constructor(message = 'The request was invalid or cannot be served') {
        super(400, 'bad-request', 'Bad Request', message);
    }
}
EOF_1787723353_26151

mkdir -p "shared/errors/src"
echo "作成: shared/errors/src/types.ts"
cat << 'EOF_1787723353_16825' > "shared/errors/src/types.ts"
export interface InvalidParam {
    name: string;
    reason: string;
}

// RFC 9457 エラーレスポンス用インターフェース
export interface ProblemDetails {
    type: string;
    title: string;
    status: number;
    detail: string;
    instance: string;
    invalidParams?: InvalidParam[];
}
EOF_1787723353_16825

mkdir -p "shared/errors/src"
echo "作成: shared/errors/src/forbidden-error.ts"
cat << 'EOF_1787723353_14615' > "shared/errors/src/forbidden-error.ts"
import { AppError } from './app-error';

export class ForbiddenError extends AppError {
    constructor(message = 'You do not have permission to access this resource') {
        super(403, 'forbidden', 'Forbidden', message);
    }
}
EOF_1787723353_14615

mkdir -p "shared/errors/src"
echo "作成: shared/errors/src/validation-error.ts"
cat << 'EOF_1787723353_13737' > "shared/errors/src/validation-error.ts"
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
EOF_1787723353_13737

mkdir -p "shared/errors/src"
echo "作成: shared/errors/src/not-found-error.ts"
cat << 'EOF_1787723353_6738' > "shared/errors/src/not-found-error.ts"
import { AppError } from './app-error';

export class NotFoundError extends AppError {
    constructor(message = 'The requested resource was not found') {
        super(404, 'not-found', 'Not Found', message);
    }
}
EOF_1787723353_6738

mkdir -p "shared/errors/src"
echo "作成: shared/errors/src/internal-server-error.ts"
cat << 'EOF_1787723353_19321' > "shared/errors/src/internal-server-error.ts"
import { AppError } from './app-error';

export class InternalServerError extends AppError {
    constructor(message = 'An unexpected error occurred') {
        super(500, 'internal-server-error', 'Internal Server Error', message);
    }
}
EOF_1787723353_19321

mkdir -p "shared/client"
echo "作成: shared/client/package.json"
cat << 'EOF_1787723353_24062' > "shared/client/package.json"
{
    "name": "@shared/client",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "main": "./index.ts",
    "types": "./index.ts",
    "exports": {
        ".": "./index.ts",
        "./components/*": "./src/components/*.tsx",
        "./lib/*": "./src/lib/*.ts"
    },
    "scripts": {
        "build": "tsc",
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
        "postgres": "^3.4.9",
        "sonner": "^2.0.7",
        "tailwind-merge": "^3.0.2"
    },
    "devDependencies": {
        "@testing-library/jest-dom": "^6.9.1",
        "@testing-library/user-event": "^14.6.3",
        "@types/react": "^18.2.55",
        "@types/react-dom": "^18.2.19",
        "drizzle-kit": "^0.31.10",
        "react": "^18.2.0",
        "react-dom": "^18.2.0",
        "typescript": "^5.3.3"
    }
}
EOF_1787723353_24062

mkdir -p "shared/client"
echo "作成: shared/client/index.ts"
cat << 'EOF_1787723353_26515' > "shared/client/index.ts"
export * from './src/lib/utils';
export * from './src/components/button';
export * from './src/components/layout';
export * from './src/components/toaster';

export { clientEnvSchema, clientEnv } from '@shared/functions'
export type { ClientEnv } from '@shared/functions'

export * from '@shared/functions'
EOF_1787723353_26515

mkdir -p "shared/client"
echo "作成: shared/client/tsconfig.json"
cat << 'EOF_1787723353_13143' > "shared/client/tsconfig.json"
{
    "extends": "../../tsconfig.json",
    "compilerOptions": {
        "types": [
            "vitest/globals",
            "@testing-library/jest-dom"
        ]
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1787723353_13143

mkdir -p "shared/client"
echo "作成: shared/client/vitest.config.ts"
cat << 'EOF_1787723353_24630' > "shared/client/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'jsdom',
        // fileParallelism: false,                 // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['../../vitest-clear.ts', './src/vitest-setup.ts'],  // 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1787723353_24630

mkdir -p "shared/client/src"
echo "作成: shared/client/src/vitest-setup.ts"
cat << 'EOF_1787723353_19925' > "shared/client/src/vitest-setup.ts"
import '@testing-library/jest-dom/vitest';
EOF_1787723353_19925

mkdir -p "shared/client/src/components"
echo "作成: shared/client/src/components/button.tsx"
cat << 'EOF_1787723353_24958' > "shared/client/src/components/button.tsx"
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
EOF_1787723353_24958

mkdir -p "shared/client/src/components"
echo "作成: shared/client/src/components/toaster.tsx"
cat << 'EOF_1787723353_209' > "shared/client/src/components/toaster.tsx"
import { Toaster as SonnerToaster, toast } from 'sonner';
import { ProblemDetails } from '@shared/errors';

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
// export interface ProblemDetails {
//     type?: string;
//     title?: string;
//     status?: number;
//     detail?: string;
//     instance?: string;
//     [key: string]: unknown;
// }

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
EOF_1787723353_209

mkdir -p "shared/client/src/components"
echo "作成: shared/client/src/components/button.test.tsx"
cat << 'EOF_1787723353_10026' > "shared/client/src/components/button.test.tsx"
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
EOF_1787723353_10026

mkdir -p "shared/client/src/components/layout"
echo "作成: shared/client/src/components/layout/index.ts"
cat << 'EOF_1787723353_28329' > "shared/client/src/components/layout/index.ts"
export * from './AppLayout';
export * from './SidebarNav';
EOF_1787723353_28329

mkdir -p "shared/client/src/components/layout"
echo "作成: shared/client/src/components/layout/AppLayout.tsx"
cat << 'EOF_1787723353_14179' > "shared/client/src/components/layout/AppLayout.tsx"
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
EOF_1787723353_14179

mkdir -p "shared/client/src/components/layout"
echo "作成: shared/client/src/components/layout/SidebarNav.tsx"
cat << 'EOF_1787723353_31892' > "shared/client/src/components/layout/SidebarNav.tsx"
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
EOF_1787723353_31892

mkdir -p "shared/client/src/components"
echo "作成: shared/client/src/components/layout.test.tsx"
cat << 'EOF_1787723353_16171' > "shared/client/src/components/layout.test.tsx"
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
EOF_1787723353_16171

mkdir -p "shared/client/src/components"
echo "作成: shared/client/src/components/toaster.test.tsx"
cat << 'EOF_1787723353_32720' > "shared/client/src/components/toaster.test.tsx"
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
EOF_1787723353_32720

mkdir -p "shared/client/src/lib"
echo "作成: shared/client/src/lib/utils.ts"
cat << 'EOF_1787723353_20940' > "shared/client/src/lib/utils.ts"
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
EOF_1787723353_20940

echo "作成: plan.md"
cat << 'EOF_1787723353_19197' > "plan.md"
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
EOF_1787723353_19197

mkdir -p ".devcontainer/scripts"
echo "作成: .devcontainer/scripts/init-test-db.sh"
cat << 'EOF_1787723353_13563' > ".devcontainer/scripts/init-test-db.sh"
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE $POSTGRES_DB_TEST;
EOSQL
EOF_1787723353_13563

mkdir -p ".devcontainer"
echo "作成: .devcontainer/Dockerfile"
cat << 'EOF_1787723353_6879' > ".devcontainer/Dockerfile"
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone
EOF_1787723353_6879

mkdir -p ".devcontainer"
echo "作成: .devcontainer/devcontainer.json"
cat << 'EOF_1787723353_25429' > ".devcontainer/devcontainer.json"
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
EOF_1787723353_25429

mkdir -p ".devcontainer"
echo "作成: .devcontainer/docker-compose.yml"
cat << 'EOF_1787723353_5735' > ".devcontainer/docker-compose.yml"

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
      - /workspace/shared/node_modules
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
      # POSTGRES_DB_TEST: app_db_test
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      # - ./scripts/init-test-db.sh:/docker-entrypoint-initdb.d/init-multiple-databases.sh
      # 起動時に app_db_test も自動作成するスクリプトをマウント

volumes:
  postgres-data:
EOF_1787723353_5735

echo "作成: tsconfig.json"
cat << 'EOF_1787723353_5585' > "tsconfig.json"
{
    "compilerOptions": {
        "target": "ESNext",
        "useDefineForClassFields": true,
        "lib": [
            "DOM",
            "DOM.Iterable",
            "ESNext"
        ],
        "allowJs": false,
        "skipLibCheck": true,
        "esModuleInterop": true,
        "allowSyntheticDefaultImports": true,
        "strict": true,
        "forceConsistentCasingInFileNames": true,
        "module": "ESNext",
        "moduleResolution": "bundler",
        "resolveJsonModule": true,
        "isolatedModules": true,
        "noEmit": true,
        "jsx": "react-jsx",
        /* ── パスエイリアス（新構造のフォルダ構成に対応） ── */
        "baseUrl": ".",
        "paths": {
            "@apps/*": [
                "apps/*"
            ],
            "@features/*": [
                "features/*"
            ],
            "@plugins/*": [
                "plugins/*"
            ],
            "@shared/*": [
                "shared/*"
            ],
            "@shared/client": [
                "shared/client/index.ts"
            ],
            "@shared/client/*": [
                "shared/client/src/*"
            ],
            "@shared/errors": [
                "shared/errors/index.ts"
            ],
            "@shared/errors/*": [
                "shared/errors/src/*"
            ],
            "@shared/functions": [
                "shared/functions/index.ts"
            ],
            "@shared/functions/*": [
                "shared/functions/src/*"
            ],
            "@shared/schemas": [
                "shared/schemas/index.ts"
            ],
            "@shared/schemas/*": [
                "shared/schemas/src/*"
            ],
            "@shared/server": [
                "shared/server/index.ts"
            ],
            "@shared/server/*": [
                "shared/server/*"
            ]
        }
    },
    "include": [
        "apps/**/*",
        "features/**/*",
        "plugins/**/*",
        "shared/**/*"
    ],
    "exclude": [
        "node_modules",
        "dist",
        "build"
    ]
}
EOF_1787723353_5585

mkdir -p "plugins/auth-ad"
echo "作成: plugins/auth-ad/package.json"
cat << 'EOF_1787723353_8194' > "plugins/auth-ad/package.json"
{
    "name": "@plugins/auth-ad",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "main": "./index.ts",
    "scripts": {
        "build": "tsc",
        "test": "vitest run",
        "typecheck": "tsc --noEmit"
    },
    "dependencies": {
        "ldapts": "^8.2.0"
    }
}
EOF_1787723353_8194

mkdir -p "plugins/auth-ad"
echo "作成: plugins/auth-ad/index.ts"
cat << 'EOF_1787723353_23594' > "plugins/auth-ad/index.ts"
import { Client } from 'ldapts';
import { AuthPlugin, AuthUser, env } from '@shared/functions';

export class ActiveDirectoryAuthPlugin implements AuthPlugin {
    name = 'ad';

    async authenticate(credentials: Record<string, any>): Promise<AuthUser> {
        const { username, password, email } = credentials;
        const loginId = username || email;

        if (!loginId || !password) {
            throw new Error('ユーザー名（またはメールアドレス）とパスワードを入力してください。');
        }

        const ldapUrl = env.LDAP_URL;
        const ldapDomain = env.LDAP_DOMAIN;

        if (!ldapUrl || !ldapDomain) {
            throw new Error('LDAP_URL または LDAP_DOMAIN が設定されていません。');
        }

        const client = new Client({ url: ldapUrl });

        try {
            const accountName = loginId.split('@')[0];
            const userPrincipalName = `${accountName}@${ldapDomain}`;

            await client.bind(userPrincipalName, password);

            return {
                id: accountName,
                email: loginId.includes('@') ? loginId : `${accountName}@${ldapDomain}`,
                name: accountName,
                role: 'user',
            };
        } catch (error) {
            throw new Error('Active Directory authentication failed');
        } finally {
            await client.unbind().catch(() => { });
        }
    }
}
EOF_1787723353_23594

mkdir -p "plugins/auth-ad"
echo "作成: plugins/auth-ad/vitest.config.ts"
cat << 'EOF_1787723353_12472' > "plugins/auth-ad/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'node',
        // fileParallelism: false,                 // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['../../vitest-clear.ts'],  // 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1787723353_12472

mkdir -p "plugins/auth-local"
echo "作成: plugins/auth-local/package.json"
cat << 'EOF_1787723353_31413' > "plugins/auth-local/package.json"
{
    "name": "@plugins/auth-local",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "main": "./index.ts",
    "scripts": {
        "build": "tsc",
        "typecheck": "tsc --noEmit"
    },
    "dependencies": {
        "bcryptjs": "^3.0.3",
        "jose": "^6.2.8"
    },
    "devDependencies": {
        "@types/bcryptjs": "^2.4.6"
    }
}
EOF_1787723353_31413

mkdir -p "plugins/auth-local"
echo "作成: plugins/auth-local/index.ts"
cat << 'EOF_1787723353_22506' > "plugins/auth-local/index.ts"
import { eq } from 'drizzle-orm';
import { db, users } from '@shared/server';
import { AuthPlugin, AuthUser } from '@shared/functions';
import { verifyPassword } from './src/auth-utils';

export class LocalAuthPlugin implements AuthPlugin {
    name = 'local';

    async authenticate(credentials: Record<string, any>): Promise<AuthUser> {
        const { email, password } = credentials; // ログインIDとして email を想定
        if (!email || !password) {
            throw new Error('メールアドレスとパスワードを入力してください。');
        }

        const user = await db.query.users.findFirst({
            where: eq(users.email, email),
        });

        if (!user) {
            throw new Error('Invalid local credentials');
        }

        const isPasswordValid = await verifyPassword(password, user.passwordHash);
        if (!isPasswordValid) {
            throw new Error('Invalid local credentials');
        }

        return {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
        };
    }
}

export * from './src/auth-utils';
EOF_1787723353_22506

mkdir -p "plugins/auth-local"
echo "作成: plugins/auth-local/vitest.config.ts"
cat << 'EOF_1787723353_16900' > "plugins/auth-local/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'node',
        // fileParallelism: false,                 // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['../../vitest-clear.ts'],  // 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1787723353_16900

mkdir -p "plugins/auth-local/src"
echo "作成: plugins/auth-local/src/auth-utils.ts"
cat << 'EOF_1787723353_21767' > "plugins/auth-local/src/auth-utils.ts"
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
EOF_1787723353_21767

mkdir -p "plugins/auth-local/src"
echo "作成: plugins/auth-local/src/auth-utils.test.ts"
cat << 'EOF_1787723353_15507' > "plugins/auth-local/src/auth-utils.test.ts"
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
EOF_1787723353_15507

echo "作成: vitest.config.ts"
cat << 'EOF_1787723353_12284' > "vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        reporters: ['tree'],

        // ディレクトリではなく「vitest.config.ts を持つファイル」をワイルドカードで直接指定する
        projects: [
            'apps/*/vitest.config.ts',
            'features/*/vitest.config.ts',
            'shared/*/vitest.config.ts',
            'plugins/*/vitest.config.ts'
        ],

        exclude: ['node_modules', 'dist', '.next', 'coverage'],

        coverage: {
            provider: 'v8',
            include: ['**/*.{ts,tsx}'],
            exclude: ['test/**/*'],
        },
    },
});
EOF_1787723353_12284

echo "作成: vitest-clear.ts"
cat << 'EOF_1787723353_7433' > "vitest-clear.ts"
import { vi, beforeEach } from 'vitest';
import { newDb } from 'pg-mem';
import { drizzle } from 'drizzle-orm/node-postgres';
import { applyIntegrationsToPool } from 'drizzle-pgmem';
import * as actualSchema from '@shared/schemas'; // パスはプロジェクトに合わせて調整してください

// 1. メモリDBインスタンスの作成
const mem = newDb({
    autoCreateForeignKeyIndices: true,
});

const { Pool } = mem.adapters.createPg();
const pool = new Pool();

applyIntegrationsToPool(pool);

const memDb = drizzle(pool, { schema: actualSchema });

// 2. 💡 テーブルの初期作成（ここはファイル読み込み時に一度だけ実行する。DROPは絶対に書かない）
mem.public.none(`
  CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL
  );

  CREATE TABLE IF NOT EXISTS plugins (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL
  );
`);

// 3. モックの設定
vi.mock('@shared/server', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@shared/server')>();
    return {
        ...actual,
        db: memDb,
        activeQueryClient: pool,
    };
});

// 4. 💡 各テスト実行前の処理（テーブル構造は壊さず、データとシーケンスだけをきれいにする）
beforeEach(() => {
    mem.public.none(`
    DELETE FROM users;
    DELETE FROM plugins;
  `);

    // SERIALのカウンターを1に戻す
    try {
        mem.public.none(`ALTER SEQUENCE users_id_seq RESTART WITH 1;`);
    } catch (e) {
        // 無視
    }
});
EOF_1787723353_7433

mkdir -p "features/user-management"
echo "作成: features/user-management/package.json"
cat << 'EOF_1787723353_20615' > "features/user-management/package.json"
{
    "name": "@features/user-management",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "main": "./index.ts",
    "exports": {
        ".": "./index.ts",
        "./*": "./src/*.ts"
    },
    "scripts": {
        "build": "tsc",
        "test": "vitest run",
        "typecheck": "tsc --noEmit"
    },
    "dependencies": {
        "@shared/client": "*",
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
EOF_1787723353_20615

mkdir -p "features/user-management"
echo "作成: features/user-management/vitest-setup.ts"
cat << 'EOF_1787723353_20858' > "features/user-management/vitest-setup.ts"
import '@testing-library/jest-dom/vitest';
EOF_1787723353_20858

mkdir -p "features/user-management"
echo "作成: features/user-management/index.ts"
cat << 'EOF_1787723353_25459' > "features/user-management/index.ts"
import { PluginRegistry } from '@shared/functions';
import { userRoutes } from './src/routes';

export { UserManagementTable, registerUserManagementPlugin } from './src/ui';

PluginRegistry.register({
    id: 'user-management',
    name: 'ユーザー管理機能',
    description: 'ユーザー一覧の表示、ロール変更およびアカウント有効/無効の管理を行います',
    routes: userRoutes,
    requiredRole: 'admin', // 💡 プラグイン自体の認可仕様として admin 権限を宣言
    navItems: [
        {
            id: 'users',
            label: 'ユーザー管理',
            path: '/admin/users',
            icon: 'users',
            roles: ['admin'],
        },
    ],
});
EOF_1787723353_25459

mkdir -p "features/user-management"
echo "作成: features/user-management/vitest.config.ts"
cat << 'EOF_1787723353_11784' > "features/user-management/vitest.config.ts"
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
        // fileParallelism: false,                 // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['./vitest-setup.ts', '../../vitest-clear.ts'],     // 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1787723353_11784

mkdir -p "features/user-management/src"
echo "作成: features/user-management/src/routes.test.ts"
cat << 'EOF_1787723353_18593' > "features/user-management/src/routes.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { db, users } from '@shared/server';
import { eq } from 'drizzle-orm';
import { userRoutes } from './routes';

describe('User Management Plugin API', () => {
    const app = new Hono();
    app.route('/', userRoutes);

    // テスト内で動的に取得したユーザーの ID を保持する変数
    let adminId: number;
    let userId: number;

    beforeEach(async () => {
        await db.delete(users);

        // id を指定せず、DBの自動採番（SERIAL）に任せて挿入
        const insertedUsers = await db.insert(users).values([
            {
                name: '管理者',
                email: 'admin@example.com',
                passwordHash: 'hashed',
                role: 'admin',
                isActive: true,
            },
            {
                name: '一般ユーザー',
                email: 'user@example.com',
                passwordHash: 'hashed',
                role: 'user',
                isActive: true,
            },
        ]).returning();

        // 挿入されたレコードから実際の ID を取得して変数に格納
        adminId = insertedUsers[0].id;
        userId = insertedUsers[1].id;
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
                password: 'securePassword123', // ルート側が必要としている場合は追加
            }),
        });

        if (res.status === 500) {
            const errorText = await res.text();
            console.error('--- POST 500 ERROR DETAILS ---', errorText);
        }

        expect(res.status).toBe(201);
        const body = await res.json();
        expect(body.user.email).toBe('plugin_new@example.com');
    });

    it('PATCH /:id/role - ユーザーのロールを変更できること', async () => {
        // 固定の '2' ではなく、変数（userId）の動的なIDを使う
        const res = await app.request(`/${userId}/role`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ role: 'admin' }),
        });

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body.user.role).toBe('admin');
    });

    it('PATCH /:id/status - アカウント有効/無効を切り替えられること', async () => {
        // 固定の '2' ではなく、変数（userId）の動的なIDを使う
        const res = await app.request(`/${userId}/status`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ isActive: false }),
        });

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body.user.isActive).toBe(false);
    });

    it('DELETE /:id - ユーザーを削除できること', async () => {
        // 固定の '2' ではなく、変数（userId）の動的なIDを使う
        const res = await app.request(`/${userId}`, {
            method: 'DELETE',
        });
        expect(res.status).toBe(200);
    });
});
EOF_1787723353_18593

mkdir -p "features/user-management/src/api"
echo "作成: features/user-management/src/api/user-management-api.ts"
cat << 'EOF_1787723353_13506' > "features/user-management/src/api/user-management-api.ts"
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
EOF_1787723353_13506

mkdir -p "features/user-management/src"
echo "作成: features/user-management/src/routes.ts"
cat << 'EOF_1787723353_22515' > "features/user-management/src/routes.ts"
import { Hono } from 'hono';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { db, users } from '@shared/server';
import { ValidationError, BadRequestError, NotFoundError } from '@shared/errors';
import { hashPassword } from '@plugins/auth-local';
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
        id: users.id,
        name: users.name,
        email: users.email,
        role: users.role,
        isActive: users.isActive,
        createdAt: users.createdAt,
    }).from(users);

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

        const [existingUser] = await db.select().from(users).where(eq(users.email, body.email));
        if (existingUser) {
            throw new BadRequestError('指定されたメールアドレスは既に登録されています');
        }

        const defaultPassword = `InitPass_${Math.random().toString(36).slice(-8)}`;
        const passwordHash = await hashPassword(defaultPassword);

        const [newUser] = await db.insert(users).values({
            name: body.name,
            email: body.email,
            passwordHash,
            role: body.role,
            isActive: true,
        }).returning({
            id: users.id,
            name: users.name,
            email: users.email,
            role: users.role,
            isActive: users.isActive,
            createdAt: users.createdAt,
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
            .update(users)
            .set({ role })
            .where(eq(users.id, id))
            .returning({
                id: users.id,
                name: users.name,
                email: users.email,
                role: users.role,
                isActive: users.isActive,
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
            .update(users)
            .set({ isActive })
            .where(eq(users.id, id))
            .returning({
                id: users.id,
                name: users.name,
                email: users.email,
                role: users.role,
                isActive: users.isActive,
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
        .delete(users)
        .where(eq(users.id, id))
        .returning({
            id: users.id,
            name: users.name,
            email: users.email,
        });

    if (deletedUsers.length === 0) {
        throw new NotFoundError('ユーザーが見つかりません');
    }

    return c.json({ message: 'ユーザーを削除しました', user: deletedUsers[0] });
});
EOF_1787723353_22515

mkdir -p "features/user-management/src"
echo "作成: features/user-management/src/ui.ts"
cat << 'EOF_1787723353_11799' > "features/user-management/src/ui.ts"
import { PluginRegistry } from '@shared/functions';
import { UserManagementTable } from './components/UserManagementTable';

export { UserManagementTable };

export function registerUserManagementPlugin() {
    PluginRegistry.register({
        id: 'user-management',
        name: 'ユーザー管理機能',
        description: 'ユーザー一覧の表示、ロール変更およびアカウント有効/無効の管理を行います',
        navItems: [
            {
                id: 'users',
                label: 'ユーザー管理',
                path: '/admin/users',
                icon: 'users',
                roles: ['admin'],
            },
        ],
    });
}
EOF_1787723353_11799

mkdir -p "features/user-management/src/components"
echo "作成: features/user-management/src/components/UserManagementTable.test.tsx"
cat << 'EOF_1787723353_27067' > "features/user-management/src/components/UserManagementTable.test.tsx"
import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { UserManagementTable } from './UserManagementTable';

// @shared/client のモック
vi.mock('@shared/client', () => ({
    toast: {
        success: vi.fn(),
        error: vi.fn(),
    },
    showErrorToast: vi.fn(),
    AUTH_TOKEN_KEY: 'test-auth-token',
}));

// fetch のモック
const globalFetch = vi.fn();
(globalThis as any).fetch = globalFetch;

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
EOF_1787723353_27067

mkdir -p "features/user-management/src/components"
echo "作成: features/user-management/src/components/CreateUserModal.tsx"
cat << 'EOF_1787723353_22215' > "features/user-management/src/components/CreateUserModal.tsx"
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
EOF_1787723353_22215

mkdir -p "features/user-management/src/components"
echo "作成: features/user-management/src/components/UserManagementTable.tsx"
cat << 'EOF_1787723353_10966' > "features/user-management/src/components/UserManagementTable.tsx"
import React, { useEffect, useState } from 'react';
import { toast, showErrorToast } from '@shared/client';
import { CreateUserModal } from './CreateUserModal';
import { AUTH_TOKEN_KEY } from '@shared/client';

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
EOF_1787723353_10966

mkdir -p "features"
echo "作成: features/tsconfig.json"
cat << 'EOF_1787723353_24666' > "features/tsconfig.json"
{
    "extends": "../tsconfig.json",
    "compilerOptions": {
        "types": [
            "@testing-library/jest-dom"
        ]
    },
    "include": [
        "./**/*"
    ]
}
EOF_1787723353_24666

echo "作成: plan-step9.md"
cat << 'EOF_1787723353_13222' > "plan-step9.md"
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
EOF_1787723353_13222

echo "作成: tree.txt"
cat << 'EOF_1787723353_4891' > "tree.txt"
.
├── apps
│   ├── api
│   │   ├── package.json
│   │   ├── src
│   │   │   ├── auto-loader
│   │   │   │   ├── hono-auto-loader.test.ts
│   │   │   │   └── hono-auto-loader.ts
│   │   │   ├── index.test.ts
│   │   │   ├── index.ts
│   │   │   ├── middlewares
│   │   │   │   ├── auth-middleware.test.ts
│   │   │   │   ├── auth-middleware.ts
│   │   │   │   ├── logger.test.ts
│   │   │   │   ├── logger.ts
│   │   │   │   ├── rbac-middleware.test.ts
│   │   │   │   └── rbac-middleware.ts
│   │   │   └── routes
│   │   │       ├── auth.test.ts
│   │   │       ├── auth.ts
│   │   │       ├── health.test.ts
│   │   │       ├── health.ts
│   │   │       ├── system.test.ts
│   │   │       └── system.ts
│   │   ├── tsconfig.json
│   │   └── vitest.config.ts
│   └── web
│       ├── dist
│       │   ├── assets
│       │   │   ├── index-Bxv8XRWV.css
│       │   │   └── index-D1d7Gzju.js
│       │   └── index.html
│       ├── index.html
│       ├── package.json
│       ├── src
│       │   ├── App.test.tsx
│       │   ├── App.tsx
│       │   ├── components
│       │   │   ├── ForbiddenPage.test.tsx
│       │   │   ├── ForbiddenPage.tsx
│       │   │   ├── Header.tsx
│       │   │   ├── LoginForm.test.tsx
│       │   │   ├── LoginForm.tsx
│       │   │   ├── ProtectedRoute.test.tsx
│       │   │   └── ProtectedRoute.tsx
│       │   ├── context
│       │   │   ├── AuthContext.test.tsx
│       │   │   └── AuthContext.tsx
│       │   ├── env.test.ts
│       │   ├── index.css
│       │   ├── lib
│       │   │   ├── apiClient.test.ts
│       │   │   └── apiClient.ts
│       │   └── main.tsx
│       ├── tsconfig.json
│       ├── vite.config.ts
│       └── vitest.config.ts
├── cat_files.sh
├── create_restorer.sh
├── cr.sh
├── doc.md
├── features
│   ├── tsconfig.json
│   ├── vitest.config.ts
│   └── user-management
│       ├── package.json
│       └── src
│           ├── api
│           │   └── user-management-api.ts
│           ├── components
│           │   ├── CreateUserModal.tsx
│           │   ├── UserManagementTable.test.tsx
│           │   └── UserManagementTable.tsx
│           ├── index.ts
│           ├── routes.test.ts
│           ├── routes.ts
│           └── ui.ts
├── package.json
├── package-lock.json
├── plugins
│   ├── auth-ad
│   │   ├── package.json
│   │   └── src
│   │       └── index.ts
│   └── auth-local
│       ├── index.ts
│       ├── package.json
│       └── src
│           ├── auth-utils.test.ts
│           └── auth-utils.ts
├── README.md
├── restore_project.sh
├── shared
│   ├── client
│   │   ├── index.ts
│   │   ├── package.json
│   │   ├── src
│   │   │   ├── components
│   │   │   │   ├── button.test.tsx
│   │   │   │   ├── button.tsx
│   │   │   │   ├── layout
│   │   │   │   │   ├── AppLayout.tsx
│   │   │   │   │   ├── index.ts
│   │   │   │   │   └── SidebarNav.tsx
│   │   │   │   ├── layout.test.tsx
│   │   │   │   ├── toaster.test.tsx
│   │   │   │   └── toaster.tsx
│   │   │   └── lib
│   │   │       └── utils.ts
│   │   ├── tsconfig.json
│   │   └── vitest.config.ts
│   ├── errors
│   │   ├── index.ts
│   │   ├── package.json
│   │   └── src
│   │       ├── app-error.ts
│   │       ├── bad-request-error.ts
│   │       ├── forbidden-error.ts
│   │       ├── internal-server-error.ts
│   │       ├── not-found-error.ts
│   │       ├── types.ts
│   │       ├── unauthorized-error.ts
│   │       └── validation-error.ts
│   ├── functions
│   │   ├── index.ts
│   │   ├── package.json
│   │   └── src
│   │       ├── auth-registry.ts
│   │       ├── constants.ts
│   │       ├── env.test.ts
│   │       ├── env.ts
│   │       └── registry.ts
│   ├── schemas
│   │   ├── index.ts
│   │   ├── package.json
│   │   └── src
│   │       ├── plugins.test.ts
│   │       ├── plugins.ts
│   │       ├── users.test.ts
│   │       └── users.ts
│   ├── server
│   │   ├── db
│   │   │   ├── index.ts
│   │   │   └── seed.ts
│   │   ├── drizzle.config.ts
│   │   ├── drizzle-test.config.ts
│   │   ├── index.ts
│   │   ├── package.json
│   │   └── utils
│   │       ├── index.ts
│   │       ├── path.test.ts
│   │       └── path.ts
│   ├── tsconfig.json
│   └── vitest.config.ts
├── SUMMRY.md
├── tsconfig.json
└── vitest.config.ts
EOF_1787723353_4891

echo "作成: doc.md"
cat << 'EOF_1787723353_16222' > "doc.md"
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
EOF_1787723353_16222

echo "作成: SUMMRY.md"
cat << 'EOF_1787723353_6269' > "SUMMRY.md"
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
EOF_1787723353_6269

mkdir -p "apps/web"
echo "作成: apps/web/package.json"
cat << 'EOF_1787723353_21425' > "apps/web/package.json"
{
    "name": "@app/web",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "scripts": {
        "dev": "vite",
        "build": "tsc && vite build",
        "typecheck": "tsc --noEmit"
    },
    "dependencies": {
        "@shared/client": "*",
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
EOF_1787723353_21425

mkdir -p "apps/web"
echo "作成: apps/web/vitest-setup.ts"
cat << 'EOF_1787723353_30660' > "apps/web/vitest-setup.ts"
import '@testing-library/jest-dom/vitest';
EOF_1787723353_30660

mkdir -p "apps/web"
echo "作成: apps/web/index.html"
cat << 'EOF_1787723353_21951' > "apps/web/index.html"
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
EOF_1787723353_21951

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.json"
cat << 'EOF_1787723353_4843' > "apps/web/tsconfig.json"
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
            "vitest/globals",
            "@testing-library/jest-dom"
        ]
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1787723353_4843

mkdir -p "apps/web"
echo "作成: apps/web/vitest.config.ts"
cat << 'EOF_1787723353_10028' > "apps/web/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'jsdom',
        fileParallelism: false,                 // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['./vitest-setup.ts'],      // 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1787723353_10028

mkdir -p "apps/web/src"
echo "作成: apps/web/src/index.css"
cat << 'EOF_1787723353_27162' > "apps/web/src/index.css"
@import "tailwindcss";

/* モノレポ内の共有 UI パッケージも Tailwind のスキャン対象に指定 */
@source "../../../shared/client/src";

/* 拡張する機能の置き場所にも、UI が記述される可能性があるので、その場所も Tailwind のスキャン対象に指定 */
@source "../../../features";
EOF_1787723353_27162

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.test.tsx"
cat << 'EOF_1787723353_17638' > "apps/web/src/App.test.tsx"
import { render, screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import React from 'react';
import { App } from './App';
import { PluginRegistry } from '@shared/functions';

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

// UserManagementTable のモック（配列の `.map()` エラーを防ぐため、安全な描画を行う）
vi.mock('@features/user-management/src/ui', () => ({
    UserManagementTable: () => <div data-testid="user-management-table">ユーザー管理テーブル画面</div>,
    registerUserManagementPlugin: vi.fn(),
}));

// @shared/client（環境変数やトースト関連）の部分モック
vi.mock('@shared/client', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@shared/client')>();
    return {
        ...actual,
        clientEnv: {
            ...actual.clientEnv,
            VITE_APP_TITLE: 'テストアプリ',
        },
        toast: {
            success: vi.fn(),
        },
        showErrorToast: vi.fn(),
    };
});

// グローバル fetch のモック
const globalFetch = vi.fn();
(globalThis as any).fetch = globalFetch;

describe('App Component Integration Tests', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        PluginRegistry.clear();

        // ユーザー管理プラグインの初期登録
        PluginRegistry.register({
            id: 'user-management',
            name: 'ユーザー管理',
            navItems: [
                {
                    id: 'users',
                    label: 'ユーザー管理',
                    path: '#users',
                    roles: ['admin'],
                },
            ],
        });

        // デフォルトの fetch 成功レスポンスを設定
        globalFetch.mockResolvedValue({
            ok: true,
            json: async () => [],
        });
    });

    afterEach(() => {
        cleanup();
    });

    it('初期表示としてダッシュボードとタイトルが正しくレンダリングされること', () => {
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'test@example.com', role: 'user' },
            logout: vi.fn(),
        });

        render(<App />);

        // 初期表示でダッシュボードの見出しが存在すること
        expect(screen.getByText('テストアプリ')).toBeDefined();
        expect(screen.getByRole('heading', { name: 'ダッシュボード' })).toBeDefined();
        expect(screen.getByText('test@example.com')).toBeDefined();
    });

    it('admin ユーザーの場合、サイドナビに「ユーザー管理」が表示され、クリックすると管理画面に切り替わること', async () => {
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'admin@example.com', role: 'admin' },
            logout: vi.fn(),
        });

        render(<App />);

        // 描画時点でレジストリが登録されているため、同期的に getByRole でナビゲーション要素が取得できる
        const userMgmtNav = screen.getByRole('link', { name: 'ユーザー管理' });
        expect(userMgmtNav).toBeDefined();

        // クリックしてユーザー管理画面を表示
        fireEvent.click(userMgmtNav);

        // 画面切り替えの確認
        await waitFor(() => {
            expect(screen.getByTestId('user-management-table')).toBeDefined();
        });
    });

    it('一般ユーザー（user）の場合、サイドナビに「ユーザー管理」が表示されないこと', () => {
        mockUseAuth.mockReturnValue({
            user: { id: 2, email: 'user@example.com', role: 'user' },
            logout: vi.fn(),
        });

        render(<App />);

        expect(screen.queryByRole('link', { name: 'ユーザー管理' })).toBeNull();
    });

    it('「403 権限エラー画面を表示」ボタンを押すとForbiddenPageに切り替わり、「ダッシュボードへ戻る」で復帰すること', async () => {
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'admin@example.com', role: 'admin' },
            logout: vi.fn(),
        });

        render(<App />);

        // 403画面へ遷移するボタンを押下
        const forbiddenButton = screen.getByRole('button', { name: '403 権限エラー画面を表示' });
        fireEvent.click(forbiddenButton);

        // 403画面が表示されていることの確認
        await waitFor(() => {
            expect(screen.getByText('403')).toBeDefined();
        });

        // 「ダッシュボードへ戻る」ボタンを押下
        const backButton = screen.getByRole('button', { name: 'ダッシュボードへ戻る' });
        fireEvent.click(backButton);

        // ダッシュボードの見出しが再び表示されていること
        await waitFor(() => {
            expect(screen.getByRole('heading', { name: 'ダッシュボード' })).toBeDefined();
        });
    });

    it('ログアウトボタンを押すと logout 関数が呼び出されること', () => {
        const handleLogout = vi.fn();
        mockUseAuth.mockReturnValue({
            user: { id: 1, email: 'admin@example.com', role: 'admin' },
            logout: handleLogout,
        });

        render(<App />);

        const logoutButton = screen.getByRole('button', { name: 'ログアウト' });
        fireEvent.click(logoutButton);

        expect(handleLogout).toHaveBeenCalledTimes(1);
    });
});

EOF_1787723353_17638

mkdir -p "apps/web/src"
echo "作成: apps/web/src/main.tsx"
cat << 'EOF_1787723353_9085' > "apps/web/src/main.tsx"
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF_1787723353_9085

mkdir -p "apps/web/src"
echo "作成: apps/web/src/env.test.ts"
cat << 'EOF_1787723353_28538' > "apps/web/src/env.test.ts"
import { describe, it, expect } from 'vitest';
import { clientEnv } from '@shared/client';

describe('Web Environment Variables (Pattern A)', () => {
    it('shared/core の clientEnv から正しく設定値および動的補完値が取得できること', () => {
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
EOF_1787723353_28538

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.test.tsx"
cat << 'EOF_1787723353_26127' > "apps/web/src/context/AuthContext.test.tsx"
import { renderHook, act, waitFor } from '@testing-library/react';
import { describe, it, expect, beforeEach, vi, Mock } from 'vitest';
import { AuthProvider, useAuth } from './AuthContext';
import React from 'react';
import { apiClient, getStoredToken, setStoredToken, removeStoredToken } from '../lib/apiClient';

// apiClient のモック設定
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
EOF_1787723353_26127

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.tsx"
cat << 'EOF_1787723353_1663' > "apps/web/src/context/AuthContext.tsx"
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

EOF_1787723353_1663

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/ProtectedRoute.test.tsx"
cat << 'EOF_1787723353_16387' > "apps/web/src/components/ProtectedRoute.test.tsx"
import '@testing-library/jest-dom';
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
EOF_1787723353_16387

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/Header.tsx"
cat << 'EOF_1787723353_5865' > "apps/web/src/components/Header.tsx"
import { clientEnv } from '@shared/client';

export const Header = () => {
  return (
    <header>
      <h1>{clientEnv.VITE_APP_TITLE}</h1>
    </header>
  );
};
EOF_1787723353_5865

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/ForbiddenPage.test.tsx"
cat << 'EOF_1787723353_29916' > "apps/web/src/components/ForbiddenPage.test.tsx"
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
EOF_1787723353_29916

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/ProtectedRoute.tsx"
cat << 'EOF_1787723353_25628' > "apps/web/src/components/ProtectedRoute.tsx"
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
EOF_1787723353_25628

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.tsx"
cat << 'EOF_1787723353_6716' > "apps/web/src/components/LoginForm.tsx"
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
EOF_1787723353_6716

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/ForbiddenPage.tsx"
cat << 'EOF_1787723353_14130' > "apps/web/src/components/ForbiddenPage.tsx"
import React from 'react';
import { Button } from '@shared/client';

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
EOF_1787723353_14130

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.test.tsx"
cat << 'EOF_1787723353_14666' > "apps/web/src/components/LoginForm.test.tsx"
import '@testing-library/jest-dom';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
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
EOF_1787723353_14666

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.tsx"
cat << 'EOF_1787723353_14190' > "apps/web/src/App.tsx"
import React, { useState } from 'react';
import { AppLayout, HeaderContent, SidebarNav, Button, Toaster, toast, showErrorToast } from '@shared/client';
import { clientEnv } from '@shared/client';
import { PluginRegistry } from '@shared/functions';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { ForbiddenPage } from './components/ForbiddenPage';

import { UserManagementTable, registerUserManagementPlugin } from '@features/user-management/src/ui';

registerUserManagementPlugin();

const AppContent: React.FC = () => {
    const { user, logout } = useAuth();
    const [currentTab, setCurrentTab] = useState<string>('dashboard');

    console.log('登録済みプラグイン:', PluginRegistry.getAll());
    console.log('ログインユーザー情報:', user);

    const baseNavItems = [
        {
            label: 'ダッシュボード',
            href: '#',
            active: currentTab === 'dashboard',
            onClick: (e: React.MouseEvent) => {
                e.preventDefault();
                setCurrentTab('dashboard');
            },
        },
    ];

    const pluginNavItems = PluginRegistry.getAll().flatMap((plugin) => {
        if (!plugin.navItems) return [];

        return plugin.navItems
            .filter((item) => {
                if (item.roles && user?.role) {
                    return item.roles.includes(user.role);
                }
                return true;
            })
            .map((item) => ({
                label: item.label,
                href: item.path,
                active: currentTab === item.id,
                onClick: (e: React.MouseEvent) => {
                    e.preventDefault();
                    setCurrentTab(item.id);
                },
            }));
    });

    const navItems = [...baseNavItems, ...pluginNavItems];

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
                <AppContent />
            </ProtectedRoute>
        </AuthProvider>
    );
}

export default App;
EOF_1787723353_14190

mkdir -p "apps/web/src/lib"
echo "作成: apps/web/src/lib/apiClient.test.ts"
cat << 'EOF_1787723353_1293' > "apps/web/src/lib/apiClient.test.ts"
// apps/web/src/lib/apiClient.test.ts
import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { apiClient, ApiError } from "./apiClient";
import { AUTH_TOKEN_KEY } from '@shared/client';

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
EOF_1787723353_1293

mkdir -p "apps/web/src/lib"
echo "作成: apps/web/src/lib/apiClient.ts"
cat << 'EOF_1787723353_29029' > "apps/web/src/lib/apiClient.ts"
import { clientEnv } from "@shared/client";
import { AUTH_TOKEN_KEY } from '@shared/client';

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
EOF_1787723353_29029

mkdir -p "apps/web"
echo "作成: apps/web/vite.config.ts"
cat << 'EOF_1787723353_6343' > "apps/web/vite.config.ts"
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
                '@shared/client': path.resolve(import.meta.dirname, '../../shared/client'),
                '@features-user-management': path.resolve(import.meta.dirname, '../../features/user-management/src'),
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
            },
        },
    };
});
EOF_1787723353_6343

mkdir -p "apps/api"
echo "作成: apps/api/package.json"
cat << 'EOF_1787723353_31395' > "apps/api/package.json"
{
    "name": "@app/api",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "scripts": {
        "build": "tsc",
        "dev": "tsx watch --env-file=../../.env src/index.ts",
        "typecheck": "tsc --noEmit"
    },
    "dependencies": {
        "@hono/node-server": "^2.0.5",
        "@hono/zod-validator": "^0.9.0",
        "@shared/server": "*",
        "@types/node": "^26.2.0",
        "drizzle-orm": "^0.45.2",
        "hono": "^4.0.0",
        "zod": "^4.4.3"
    },
    "devDependencies": {
        "tsx": "^4.7.1",
        "typescript": "^5.3.3"
    }
}
EOF_1787723353_31395

mkdir -p "apps/api"
echo "作成: apps/api/tsconfig.json"
cat << 'EOF_1787723353_4664' > "apps/api/tsconfig.json"
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
EOF_1787723353_4664

mkdir -p "apps/api"
echo "作成: apps/api/vitest.config.ts"
cat << 'EOF_1787723353_14609' > "apps/api/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'node',
        // fileParallelism: false,                 // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['../../vitest-clear.ts'],  // 各テスト実行前にテーブルデータを全消去
    },
});
EOF_1787723353_14609

mkdir -p "apps/api/src/auto-loader"
echo "作成: apps/api/src/auto-loader/hono-auto-loader.test.ts"
cat << 'EOF_1787723353_3438' > "apps/api/src/auto-loader/hono-auto-loader.test.ts"
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Hono } from 'hono';
import { sign } from 'hono/jwt';

import { db, plugins } from '@shared/server';
import { loadFeatureModules } from './hono-auto-loader';
import { env, PluginRegistry } from '@shared/functions';
import { AppError } from '@shared/errors';

describe('hono-auto-loader', () => {
    const createTestApp = () => {
        const app = new Hono();
        app.onError((err, c) => {
            if (err instanceof AppError) {
                return c.json({ error: err.message }, err.status as any);
            }
            return c.json({ error: 'Internal Server Error' }, 500);
        });
        return app;
    };

    // 💡 ヘルパー: JWT 生成
    const createToken = async (role: string = 'user') => {
        return await sign({ sub: 'user-123', role }, env.JWT_SECRET);
    };

    beforeEach(async () => {
        PluginRegistry.clear();
        try {
            await db.delete(plugins);
        } catch (e) {
            // 無視
        }
    });

    describe('DB ステータス制御とロード処理', () => {
        it('1. DBで有効(enabled: true)のプラグインは正常にマウントされアクセスできること', async () => {
            const pluginId = 'test-plugin-enabled';
            const dummyApp = new Hono();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            await db.insert(plugins).values({
                id: pluginId,
                name: '標準プラグイン',
                enabled: true,
            });

            const app = createTestApp();
            await loadFeatureModules(app, 'features/*/src/index.ts');

            const token = await createToken('user');
            const res = await app.request(`/api/${pluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            expect(res.status).toBe(200);
        });

        it('2. DBで無効(enabled: false)のプラグインはスキップされ 404 になること', async () => {
            const pluginId = 'test-plugin-disabled';
            const dummyApp = new Hono();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            await db.insert(plugins).values({
                id: pluginId,
                name: '標準プラグイン',
                enabled: false,
            });

            const app = createTestApp();
            await loadFeatureModules(app, 'features/*/src/index.ts');

            const token = await createToken('user');
            const res = await app.request(`/api/${pluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            expect(res.status).toBe(404);
        });

        it('3. DB未登録の場合はデフォルト有効として処理されること', async () => {
            const pluginId = 'test-plugin-unregistered';
            const dummyApp = new Hono();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            const app = createTestApp();
            await loadFeatureModules(app, 'features/*/src/index.ts');

            const token = await createToken('user');
            const res = await app.request(`/api/${pluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            expect(res.status).toBe(200);
        });

        it('4. DBクエリ例外時でもクラッシュせずフォールバック動作すること', async () => {
            const pluginId = 'test-plugin-fallback';
            const dummyApp = new Hono();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            const selectSpy = vi.spyOn(db, 'select').mockImplementationOnce(() => {
                throw new Error('DB Connection Error');
            });

            const app = createTestApp();
            await loadFeatureModules(app, 'features/*/src/index.ts');

            const token = await createToken('user');
            const res = await app.request(`/api/${pluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });

            expect(res.status).toBe(200);
            selectSpy.mockRestore();
        });

        it('5. routes 未定義のプラグインはエラーなくスキップされること', async () => {
            const pluginId = 'test-ui-only-plugin';
            PluginRegistry.register({ id: pluginId, name: 'UI専用プラグイン' });

            const app = createTestApp();
            await expect(loadFeatureModules(app, 'features/*/src/index.ts')).resolves.not.toThrow();
        });
    });

    describe('認証・認可ミドルウェアの適用', () => {
        it('6. トークンなしの場合 401 Unauthorized になること', async () => {
            const pluginId = 'test-plugin-auth';
            const dummyApp = new Hono();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            const app = createTestApp();
            await loadFeatureModules(app, 'features/*/src/index.ts');

            const res = await app.request(`/api/${pluginId}/hello`);
            expect(res.status).toBe(401);
        });

        it('7. requiredRole の認可が正しく機能すること (一般ユーザー: 403, 管理者: 200)', async () => {
            const pluginId = 'test-rbac-plugin';
            const rbacApp = new Hono();
            rbacApp.get('/admin-only', (c) => c.json({ message: 'admin content' }));
            PluginRegistry.register({
                id: pluginId,
                name: '権限テスト用プラグイン',
                routes: rbacApp,
                requiredRole: 'admin',
            });

            const app = createTestApp();
            await loadFeatureModules(app, 'features/*/src/index.ts');

            // 一般ユーザー -> 403
            const userToken = await createToken('user');
            const resUser = await app.request(`/api/${pluginId}/admin-only`, {
                headers: { Authorization: `Bearer ${userToken}` },
            });
            expect(resUser.status).toBe(403);

            // 管理者 -> 200
            const adminToken = await createToken('admin');
            const resAdmin = await app.request(`/api/${pluginId}/admin-only`, {
                headers: { Authorization: `Bearer ${adminToken}` },
            });
            expect(resAdmin.status).toBe(200);
        });
    });
});
EOF_1787723353_3438

mkdir -p "apps/api/src/auto-loader"
echo "作成: apps/api/src/auto-loader/hono-auto-loader.ts"
cat << 'EOF_1787723353_23872' > "apps/api/src/auto-loader/hono-auto-loader.ts"
import { Hono } from 'hono';
import { glob } from 'glob';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { env } from '@shared/functions';
import { getProjectRootDir } from '@shared/server';
import { getActivePlugins } from '../utils/auto-loader-helper';
import { authMiddleware } from '../middlewares/auth-middleware';
import { rbacMiddleware } from '../middlewares/rbac-middleware';

export async function loadFeatureModules(app: Hono, pattern: string) {
    // 💡 プロジェクトルートを環境に依存せず確実に取得
    const rootDir = getProjectRootDir();

    // rootDir を起点に Glob 検索を実行
    const files = await glob(pattern, { cwd: rootDir });

    // 1. 各機能モジュールを動的インポート
    for (const file of files) {
        const absolutePath = path.resolve(rootDir, file);
        const moduleUrl = pathToFileURL(absolutePath).href;
        await import(moduleUrl);
    }

    // 2. DB から登録済みプラグインの有効/無効ステータスを取得
    const pluginStatuses = await getActivePlugins();

    // 3. レジストリに登録されたプラグインをチェックし、有効なもののみマウント
    for (const { plugin, isEnabled } of pluginStatuses) {
        if (isEnabled) {
            if (plugin.routes !== undefined) {
                const basePath = `/api/${plugin.id}`;

                // 認証ミドルウェアの適用
                app.use(`${basePath}/*`, authMiddleware(env.JWT_SECRET));

                // 要求ロール（requiredRole）が指定されている場合は RBAC ガードを適用
                if (plugin.requiredRole) {
                    app.use(`${basePath}/*`, rbacMiddleware([plugin.requiredRole]));
                }

                // API パス: /api/{plugin-id} 配下にマウント
                app.route(basePath, plugin.routes);
                console.log(`[Auto-Loader] ✅ Loaded & Mounted Plugin: ${plugin.id}`);
            }
        } else {
            console.log(`[Auto-Loader] ⏸️ Skipped Disabled Plugin: ${plugin.id}`);
        }
    }
}
EOF_1787723353_23872

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.ts"
cat << 'EOF_1787723353_29109' > "apps/api/src/index.ts"
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { serve } from '@hono/node-server';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { AppError, ProblemDetails, ValidationError } from '@shared/errors';
import { env, isTest, formatEnvForLog } from '@shared/functions';
import { AuthPluginRegistry } from '@shared/functions';
import { loadFeatureModules } from './auto-loader/hono-auto-loader';
import { LocalAuthPlugin } from '@plugins/auth-local';
import { ActiveDirectoryAuthPlugin } from '@plugins/auth-ad';
import { authRouter } from './routes/auth';
import { healthRouter } from './routes/health';
import { systemRouter } from './routes/plugin';
import { loggerMiddleware } from './middlewares/logger';

// コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
if (!isTest) {
    console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog());
}

// 3. プラグインの登録
AuthPluginRegistry.register(new LocalAuthPlugin());
AuthPluginRegistry.register(new ActiveDirectoryAuthPlugin());

/**
 * アプリケーションのインスタンスを非同期で生成・初期化する関数
 */
export async function createApp() {
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

    // プラグイン/フィーチャーモジュールの動的読み込み（非同期処理の完了を待つ）
    await loadFeatureModules(app, 'features/*/index.ts');

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
                    const invalidParams = result.error.issues.map((issue) => ({
                        name: issue.path.join('.'),
                        reason: issue.message,
                    }));
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

    return app;
}

// -----------------------------------------------------------------------------
// サーバーバインド & 起動処理 (本番用)
// -----------------------------------------------------------------------------
if (!isTest) {
    createApp().then((app) => {
        const port = env.PORT;
        console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);
        serve({
            fetch: app.fetch,
            port,
            hostname: '0.0.0.0',
        });
    });
}

// デフォルトエクスポート（必要に応じて型や古いインポートとの互換用）
const defaultApp = new Hono();
export default defaultApp;
EOF_1787723353_29109

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.test.ts"
cat << 'EOF_1787723354_28056' > "apps/api/src/index.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import { createApp } from './index';

describe('API Error Handling (RFC 9457)', () => {
    let app: Awaited<ReturnType<typeof createApp>>;

    beforeEach(async () => {
        app = await createApp();
    });

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
    let app: Awaited<ReturnType<typeof createApp>>;

    beforeEach(async () => {
        app = await createApp();
    });

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
    let app: Awaited<ReturnType<typeof createApp>>;

    beforeEach(async () => {
        app = await createApp();
    });

    it('未認証の状態で /api/user-management にアクセスした際、401 Unauthorized が返ること', async () => {
        const res = await app.request('/api/user-management');
        expect(res.status).toBe(401);
    });
});
EOF_1787723354_28056

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/plugin.ts"
cat << 'EOF_1787723354_27233' > "apps/api/src/routes/plugin.ts"
import { Hono } from 'hono';
import { getActivePlugins } from '../utils/auto-loader-helper';

export const systemRouter = new Hono();

/**
 * GET /api/system/plugins
 * 有効化（enabled: true）されているプラグインの一覧および
 * フロントエンド表示に必要なナビゲーション（navItems）を返却するAPI
 */
systemRouter.get('/plugins', async (c) => {
    const pluginStatuses = await getActivePlugins();

    const activePlugins = pluginStatuses
        .filter(({ isEnabled }) => isEnabled)
        .map(({ plugin }) => ({
            id: plugin.id,
            name: plugin.name,
            description: plugin.description,
            navItems: plugin.navItems ?? [],
        }));

    return c.json({
        plugins: activePlugins,
    });
});
EOF_1787723354_27233

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/health.test.ts"
cat << 'EOF_1787723354_7872' > "apps/api/src/routes/health.test.ts"
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { createApp } from '../index';
import { db } from '@shared/server';

describe('Health Check API (Step 6.1)', () => {
    let app: Awaited<ReturnType<typeof createApp>>;

    beforeEach(async () => {
        vi.clearAllMocks();
        vi.restoreAllMocks();
        // 非同期でアプリの初期化（ルートのロード完了）を待つ
        app = await createApp();
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

EOF_1787723354_7872

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.ts"
cat << 'EOF_1787723354_30810' > "apps/api/src/routes/auth.ts"
import { Hono } from 'hono';
import { z } from 'zod';
import { UnauthorizedError } from '@shared/errors';
import { signJwt } from '@plugins/auth-local';
import { authMiddleware } from '../middlewares/auth-middleware';
import { getActiveAuthPlugin } from '../services/auth-service';

const loginSchema = z.object({
    email: z.string().optional(),
    username: z.string().optional(),
    password: z.string().min(1),
}).refine((data) => data.email || data.username, {
    message: 'メールアドレスまたはユーザー名が必要です。',
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
            throw new UnauthorizedError('Invalid credentials format.');
        }

        const authPlugin = getActiveAuthPlugin();

        try {
            const authUser = await authPlugin.authenticate({
                email: result.data.email || result.data.username,
                username: result.data.username || result.data.email,
                password: result.data.password,
            });

            const token = await signJwt(
                {
                    userId: authUser.id,
                    email: authUser.email || '',
                    role: authUser.role || 'user',
                },
                jwtSecret
            );

            return c.json({
                token,
                user: {
                    id: authUser.id,
                    email: authUser.email || authUser.name,
                    role: authUser.role || 'user',
                },
            });
        } catch {
            throw new UnauthorizedError('Invalid credentials.');
        }
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


// import { Hono } from 'hono';
// import { z } from 'zod';
// import { eq } from 'drizzle-orm';
// import { db, users } from '@shared/server';
// import { UnauthorizedError } from '@shared/errors';
// import { verifyPassword, signJwt } from '@plugins/auth-local';
// import { authMiddleware } from '../middlewares/auth-middleware';

// // ログインリクエストのバリデーションスキーマ
// const loginSchema = z.object({
//     email: z.string().email(),
//     password: z.string().min(1),
// });

// /**
//  * 認証関連の API ルーター
//  */
// export function authRouter(jwtSecret: string) {
//     const app = new Hono();

//     // ----------------------------------------------------
//     // 1. POST /login (ログイン & トークン発行)
//     // ----------------------------------------------------
//     app.post('/login', async (c) => {
//         const body = await c.req.json();
//         const result = loginSchema.safeParse(body);

//         if (!result.success) {
//             throw new UnauthorizedError('Invalid email or password format.');
//         }

//         const { email, password } = result.data;

//         // DB からユーザーを検索
//         const user = await db.query.users.findFirst({
//             where: eq(users.email, email),
//         });

//         if (!user) {
//             // セキュリティ上「ユーザーが存在しない」メッセージは出さず 401 を返す
//             throw new UnauthorizedError('Invalid credentials.');
//         }

//         // パスワードの照合
//         const isPasswordValid = await verifyPassword(password, user.passwordHash);
//         if (!isPasswordValid) {
//             throw new UnauthorizedError('Invalid credentials.');
//         }

//         // JWT アクセストークンの発行
//         const token = await signJwt(
//             {
//                 userId: user.id,
//                 email: user.email,
//                 role: user.role,
//             },
//             jwtSecret
//         );

//         return c.json({
//             token,
//             user: {
//                 id: user.id,
//                 email: user.email,
//                 role: user.role,
//             },
//         });
//     });

//     // ----------------------------------------------------
//     // 2. GET /me (ログインユーザー情報取得)
//     // ----------------------------------------------------
//     app.get('/me', authMiddleware(jwtSecret), async (c) => {
//         const currentUser = c.get('user');

//         return c.json({
//             user: {
//                 id: currentUser.userId,
//                 email: currentUser.email,
//                 role: currentUser.role,
//             },
//         });
//     });

//     return app;
// }
EOF_1787723354_30810

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/plugin.test.ts"
cat << 'EOF_1787723354_29367' > "apps/api/src/routes/plugin.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { PluginRegistry } from '@shared/functions';
import { systemRouter } from './plugin';

describe('GET /api/system/plugins', () => {
    beforeEach(() => {
        PluginRegistry.register({
            id: 'sample-plugin',
            name: 'サンプル',
            routes: new Hono(),
            navItems: [{ id: 'sample-plugin', label: 'サンプル画面', path: '/sample' }],
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
EOF_1787723354_29367

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/health.ts"
cat << 'EOF_1787723354_30396' > "apps/api/src/routes/health.ts"
import { Hono } from 'hono';
import { db } from '@shared/server';
import { AppError } from '@shared/errors';
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
EOF_1787723354_30396

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.test.ts"
cat << 'EOF_1787723354_5614' > "apps/api/src/routes/auth.test.ts"
import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { authRouter } from './auth';
import { db, users } from '@shared/server';
import { AppError } from '@shared/errors';
import { hashPassword } from '@plugins/auth-local';

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
EOF_1787723354_5614

mkdir -p "apps/api/src/utils"
echo "作成: apps/api/src/utils/auto-loader-helper.ts"
cat << 'EOF_1787723354_31025' > "apps/api/src/utils/auto-loader-helper.ts"
// apps/api/src/utils/plugin-helper.ts
import { db, schema } from '@shared/server';
import { PluginRegistry } from '@shared/functions';

export async function getActivePlugins() {
    const dbPluginsMap = new Map<string, boolean>();
    try {
        const dbPlugins = await db.select().from(schema.plugins);
        dbPlugins.forEach((p: { id: string; enabled: any }) => {
            dbPluginsMap.set(p.id, Boolean(p.enabled));
        });
    } catch (error) {
        console.warn('[Plugin Helper] DB query failed or table not found. Defaulting all plugins to enabled.');
    }

    return PluginRegistry.getAll().map((plugin) => {
        const isEnabled = dbPluginsMap.has(plugin.id)
            ? dbPluginsMap.get(plugin.id)!
            : true;

        return {
            plugin,
            isEnabled,
        };
    });
}
EOF_1787723354_31025

mkdir -p "apps/api/src/services"
echo "作成: apps/api/src/services/auth-service.ts"
cat << 'EOF_1787723354_14902' > "apps/api/src/services/auth-service.ts"
import { env, AuthPlugin, AuthPluginRegistry } from '@shared/functions';
import { LocalAuthPlugin } from '@plugins/auth-local';
import { ActiveDirectoryAuthPlugin } from '@plugins/auth-ad';

// プラグインの自動登録
AuthPluginRegistry.register(new LocalAuthPlugin());
AuthPluginRegistry.register(new ActiveDirectoryAuthPlugin());

/**
 * 環境変数に応じたアクティブな認証プラグインを取得する
 */
export function getActiveAuthPlugin(): AuthPlugin {
    const providerName = env.AUTH_PROVIDER; // 'local' または 'ad'
    return AuthPluginRegistry.get(providerName);
}
EOF_1787723354_14902

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.ts"
cat << 'EOF_1787723354_1288' > "apps/api/src/middlewares/auth-middleware.ts"
import type { MiddlewareHandler } from 'hono';
import { verifyJwt } from '@plugins/auth-local';
import { UnauthorizedError } from '@shared/errors';

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
EOF_1787723354_1288

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.test.ts"
cat << 'EOF_1787723354_1667' > "apps/api/src/middlewares/auth-middleware.test.ts"
import { describe, it, expect } from 'vitest';
import { Hono } from 'hono';

import { authMiddleware } from './auth-middleware';
import { AppError } from '@shared/errors';
import { signJwt } from '@plugins/auth-local';

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
EOF_1787723354_1667

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/rbac-middleware.test.ts"
cat << 'EOF_1787723354_26002' > "apps/api/src/middlewares/rbac-middleware.test.ts"
import { describe, it, expect } from 'vitest';
import { Hono } from 'hono';

import { authMiddleware } from './auth-middleware';
import { rbacMiddleware } from './rbac-middleware';
import { AppError } from '@shared/errors';
import { signJwt } from '@plugins/auth-local';

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
EOF_1787723354_26002

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/logger.test.ts"
cat << 'EOF_1787723354_5001' > "apps/api/src/middlewares/logger.test.ts"
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
EOF_1787723354_5001

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/rbac-middleware.ts"
cat << 'EOF_1787723354_1264' > "apps/api/src/middlewares/rbac-middleware.ts"
import type { MiddlewareHandler } from 'hono';
import { ForbiddenError, UnauthorizedError } from '@shared/errors';

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
EOF_1787723354_1264

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/logger.ts"
cat << 'EOF_1787723354_14233' > "apps/api/src/middlewares/logger.ts"
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
EOF_1787723354_14233

echo "作成: README.md"
cat << 'EOF_1787723354_31810' > "README.md"
# 📖 プロジェクト基本仕様書 (Project Architecture Specification) - v2.7

## 1. システム概要 (Overview)

本プロジェクトは、TypeScript をベースとしたモノレポ構成の Web アプリケーションです。
バックエンドには軽量・高速な Web フレームワーク（**Hono**）、フロントエンドにはコンポーネント指向 UI ライブラリ（**React + Vite + Tailwind CSS**）、データベース操作には型安全な ORM（**Drizzle ORM / PostgreSQL**）を採用しています。

共通ロジックや拡張機能（認証・UI コンポーネント・業務モジュール等）を独立したモジュール群へ分離し、クライアント側では型安全な API クライアントと Context による認証状態管理を組み合わせることで、保守性と拡張性を高めたコンポーザブルなアーキテクチャを実現します。

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

### 3.1 共有レイヤーおよびモジュールの構成方針

システムの各領域（実行体、業務機能、プラグイン、共通基盤）の関心を分離（疎結合化）しています。開発者は定められた層構造に従って安全に機能を拡張します。

| ディレクトリ名 | レイヤー区分 | 役割・含まれる機能 |
| --- | --- | --- |
| **`apps/`** | アプリケーション層 | 実行体となるサーバーサイドアプリケーション（`api`）およびクライアントサイドアプリケーション（`web`） |
| **`features/`** | 業務ドメイン層 | 特定の業務機能を単位ごとにカプセル化し、独立した追加・削除・テストを可能化（`user-management` 等） |
| **`plugins/`** | プラグイン層 | 運用環境や顧客要件に応じて切り替え・拡張される機能（`auth-local`, `auth-ad` 等） |
| **`shared/`** | 共通基盤層 | システム全域で利用される共有モジュール群（`client`, `errors`, `functions`, `schemas`, `server`） |

### 3.2 拡張ルールと依存方向 (Extension Rules)

1. **機能追加の手順:**
新しいドメイン機能や連携モジュールを追加する際は、`features/` または `plugins/` 配下に新規ディレクトリを作成し、ルートのワークスペース管理に登録します。
2. **単方向依存の徹底:**
依存の方向は常に上位（`apps/`）から下位（`shared/`, `plugins/`, `features/`）の方向に限定します。下位モジュールから上位アプリケーションへの逆参照は厳禁とします。

---

## 4. ディレクトリ構造 & 全ファイル一覧 (Directory & File Structure)

プロジェクトに存在する**すべてのファイル・フォルダを網羅**したディレクトリ構造です。コンポーネントやロジックとそのテストはコロケーション（同一ディレクトリ配置）を基本原則とします。

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
│   │   │   ├── auto-loader/
│   │   │   │   ├── hono-auto-loader.ts      # Feature モジュール自動探索・DBステータス連動マウント機能
│   │   │   │   └── hono-auto-loader.test.ts # 動的モジュール探索・RBAC・DB ステータス制御統合テスト
│   │   │   ├── middlewares/      # ミドルウェア層
│   │   │   │   ├── auth-middleware.ts      # JWT 検証・コンテキスト設定ミドルウェア
│   │   │   │   ├── auth-middleware.test.ts # 認証ミドルウェア単体・統合テスト
│   │   │   │   ├── rbac-middleware.ts      # ロールベース認可ミドルウェア (requireRole)
│   │   │   │   ├── rbac-middleware.test.ts # 認可ミドルウェア単体・統合テスト (403 Forbidden 検証)
│   │   │   │   ├── logger.ts               # リクエストロガー
│   │   │   │   └── logger.test.ts          # リクエストロガー単体テスト
│   │   │   └── routes/           # アプリケーション固有のコア API ルーティング
│   │   │       ├── auth.ts         # 認証 API ルート (/login, /me)
│   │   │       ├── auth.test.ts    # 認証 API 統合テスト (ログイン・プロファイル取得)
│   │   │       ├── health.ts       # ヘルスチェック API ルート (/healthz)
│   │   │       ├── health.test.ts  # ヘルスチェック API 統合テスト (DB 接続確認・503 エラーハンドリング)
│   │   │       ├── system.ts       # システム系 API ルート
│   │   │       └── system.test.ts  # システム系 API 統合テスト
│   │   ├── package.json          # API サーバー用依存関係・スクリプト
│   │   ├── tsconfig.json         # API サーバー用 TypeScript 設定
│   │   └── vitest.config.ts      # API サーバー用 Vitest 設定
│   │
│   └── web/                      # クライアントサイド Web アプリケーション (React / Vite)
│       ├── public/               # 静的アセット (favicon 等)
│       ├── src/
│       │   ├── App.tsx           # ルート UI コンポーネント (ルーティング・ProtectedRoute 適用)
│       │   ├── App.test.tsx      # ルート UI 単体テスト
│       │   ├── main.tsx          # React レンダリングエントリーポイント (index.cssインポート必須)
│       │   ├── index.css         # Tailwind CSS v4 エントリーポイント (@import "tailwindcss"; @source ...)
│       │   ├── env.test.ts       # クライアント用環境変数保護・型定義テスト
│       │   ├── context/          # 認証状態管理・コンテキスト層
│       │   │   ├── AuthContext.tsx    # AuthContext / AuthProvider / useAuth フック実装
│       │   │   └── AuthContext.test.tsx # AuthContext の単体テスト (ログイン/ログアウト/トークン永続化)
│       │   ├── components/       # アプリケーション固有の UI コンポーネント
│       │   │   ├── Header.tsx      # ヘッダーコンポーネント
│       │   │   ├── LoginForm.tsx   # ログインフォームコンポーネント (useAuth 連携)
│       │   │   ├── LoginForm.test.tsx # ログインフォームの単体テスト
│       │   │   ├── ProtectedRoute.tsx # 未認証ユーザー制限・リダイレクトガードコンポーネント
│       │   │   ├── ProtectedRoute.test.tsx # ProtectedRoute 単体テスト
│       │   │   ├── ForbiddenPage.tsx  # 403 権限不足エラー画面コンポーネント
│       │   │   └── ForbiddenPage.test.tsx # 403 画面単体テスト
│       │   ├── lib/              # フロントエンド共通ユーティリティ・ライブラリ
│       │   │   ├── apiClient.ts    # Fetch ベースの型安全 API クライアント (RFC 9457 エラーパース・トークン付与)
│       │   │   └── apiClient.test.ts # apiClient の単体・モックテスト
│       │   └── test/
│       │       └── setup.ts      # React Testing Library 用グローバルセットアップ
│       ├── index.html            # HTML エントリーテンプレート
│       ├── package.json          # Web アプリ用依存関係・スクリプト
│       ├── tsconfig.json         # Web アプリ用 TypeScript 設定 (@shared/client の include パス指定含む)
│       ├── tsconfig.node.json    # Vite 設定用 TypeScript 補助設定
│       ├── vite.config.ts        # Vite 設定 (API プロキシ・環境変数読み込み・Vitest 設定)
│       └── vitest.config.ts      # Web アプリ用 Vitest 設定
│
├── features/                     # 業務ドメイン機能モジュール群 (自動探索・マウント対象)
│   └── user-management/          # ユーザー管理業務ドメインモジュール
│       ├── src/
│       │   ├── index.ts          # ユーザー管理モジュールエントリーポイント (PluginRegistry 登録)
│       │   ├── routes.ts         # ユーザー管理 API ルーティング実装
│       │   ├── routes.test.ts    # ユーザー管理 API 単体・統合テスト
│       │   ├── ui.ts             # フロントエンド共有用コンポーネント一括エクスポート
│       │   ├── api/              # クライアント用 API 呼び出しモジュール
│       │   │   └── user-management-api.ts # ユーザー管理 API クライアント関数群
│       │   ├── components/       # ユーザー管理専用 React UI コンポーネント
│       │   │   ├── CreateUserModal.tsx      # ユーザー新規作成モーダル
│       │   │   ├── UserManagementTable.tsx  # ユーザー一覧・操作テーブル
│       │   │   └── UserManagementTable.test.tsx # テーブルコンポーネント単体テスト
│       │   └── test/             # モジュール個別テスト環境設定
│       │       ├── global-setup.ts
│       │       └── setup.ts
│       ├── package.json          # @app/feature-user-management 依存関係・スクリプト
│       ├── tsconfig.json         # ユーザー管理モジュール用 TypeScript 設定
│       └── vitest.config.ts      # ユーザー管理モジュール用 Vitest 単体テスト設定
│
├── plugins/                      # 切り替え可能なプラグイン群
│   ├── auth-ad/                  # Active Directory 認証連携モジュール
│   │   ├── src/index.ts
│   │   └── package.json
│   └── auth-local/               # ローカルデータベース認証モジュール
│       ├── index.ts              # パッケージエントリーポイント
│       ├── package.json          # ローカル認証モジュール用依存関係
│       └── src/
│           ├── auth-utils.ts     # Bcrypt パスワードハッシュ化 & Jose JWT ユーティリティ
│           └── auth-utils.test.ts# パスワードハッシュ・JWT 署名/検証の単体テスト
│
├── shared/                       # 共有パッケージ層 (ライブラリ・モジュール)
│   ├── client/                   # 共有 UI コンポーネントパッケージ (@shared/client)
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── button.tsx      # CVA 準拠 Button コンポーネント
│   │   │   │   ├── button.test.tsx # Button 単体テスト (コロケーション)
│   │   │   │   ├── layout/         # 共通レイアウトコンポーネント群
│   │   │   │   │   ├── AppLayout.tsx # アプリケーション共通レイアウト
│   │   │   │   │   ├── SidebarNav.tsx # サイドバーナビゲーション
│   │   │   │   │   └── index.ts    # レイアウト一括エクスポート
│   │   │   │   ├── layout.test.tsx # Layout 単体テスト (コロケーション)
│   │   │   │   ├── toaster.tsx     # Sonner Toast プロバイダー & RFC 9457 エラーハンドラー
│   │   │   │   └── toaster.test.tsx # Toast & showErrorToast 単体テスト (コロケーション)
│   │   │   ├── lib/
│   │   │   │   └── utils.ts      # clsx + tailwind-merge による cn ユーティリティ
│   │   │   └── test/
│   │   │       └── setup.ts      # jest-dom マッチャー拡張セットアップ
│   │   ├── index.ts              # UI パッケージエクスポート統合
│   │   ├── package.json          # @shared/client 依存関係 (clsx, tailwind-merge, cva, sonner)
│   │   ├── tsconfig.json         # UI パッケージ用 TS 設定 (jest-dom / vitest 型拡張)
│   │   └── vitest.config.ts      # UI パッケージ用 Vitest 設定
│   │
│   ├── errors/                   # システム標準エラー構造・RFC 9457 定義パッケージ (@shared/errors)
│   │   ├── src/
│   │   │   ├── types.ts          # エラー型定義 (`ProblemDetails`, `InvalidParam`)
│   │   │   ├── app-error.ts      # 基底例外クラス (`AppError`)
│   │   │   ├── bad-request-error.ts     # 400 例外 (`BadRequestError`)
│   │   │   ├── forbidden-error.ts       # 403 例外 (`ForbiddenError`)
│   │   │   ├── internal-server-error.ts # 500 例外 (`InternalServerError`)
│   │   │   ├── not-found-error.ts       # 404 例外 (`NotFoundError`)
│   │   │   ├── unauthorized-error.ts    # 401 例外 (`UnauthorizedError`)
│   │   │   └── validation-error.ts      # バリデーション例外 (`ValidationError`)
│   │   ├── index.ts              # 共通エラー一括エクスポート
│   │   └── package.json          # 共通エラーパッケージ用依存関係
│   │
│   ├── functions/                # システム共通ユーティリティ・関数群パッケージ (@shared/functions)
│   │   ├── src/
│   │   │   ├── env.ts            # Zod による環境変数定義・検証関数 (CORS_ORIGIN / API_BASE_URL 自動変換等)
│   │   │   ├── env.test.ts       # 環境変数検証の単体テスト
│   │   │   ├── constants.ts      # 共通定数定義
│   │   │   ├── registry.ts       # プラグイン（PluginRegistry）の一括登録・保持機構
│   │   │   └── auth-registry.ts  # 認証レジストリ関連ロジック
│   │   ├── index.ts              # 共通関数パッケージエクスポート
│   │   └── package.json          # 共通関数パッケージ用依存関係
│   │
│   ├── schemas/                  # データベーススキーマ定義パッケージ (@shared/schemas)
│   │   ├── src/
│   │   │   ├── users.ts          # users テーブルスキーマ定義
│   │   │   ├── users.test.ts     # Users テーブル CRUD & Unique 制約 DB 統合テスト
│   │   │   ├── plugins.ts        # plugins テーブルスキーマ定義
│   │   │   └── plugins.test.ts   # Plugins テーブルテスト
│   │   ├── index.ts              # スキーマ一括エクスポート
│   │   └── package.json          # スキーマパッケージ用依存関係
│   │
│   ├── server/                   # サーバーサイド共通基盤パッケージ (@shared/server)
│   │   ├── src/
│   │   │   ├── db/
│   │   │   │   ├── index.ts      # シングルトン / 動的 DB 接続管理 (`db`, `activeQueryClient`)
│   │   │   │   └── seed.ts       # DB 初期データシードスクリプト
│   │   │   └── utils/
│   │   │       ├── path.ts       # ESM 準拠プロジェクトルート取得 (`getProjectRootDir`)・絶対パス解決関数
│   │   │       └── path.test.ts  # パス解決ユーティリティの環境独立性検証テスト
│   │   ├── index.ts              # サーバー基盤エクスポート
│   │   ├── drizzle.config.ts     # 通常開発/マイグレーション用 Drizzle 構成
│   │   ├── drizzle-test.config.ts# テストDB専用 ORM 構成ファイル
│   │   ├── package.json          # サーバー基盤用依存関係
│   │   └── vitest.config.ts      # サーバー基盤用 Vitest 設定
│   │
│   ├── tsconfig.json             # shared レイヤー共通 TypeScript 設定
│   └── vitest.config.ts          # shared レイヤー共通 Vitest 設定

```

---

## 5. データベース & ORM 仕様 (Database & ORM)

### 5.1 ORM の設計と接続管理

* **型安全性の保障:** アプリケーションコードとデータベース構造の不一致を防ぐため、完全な TypeScript サポートを持つ ORM (Drizzle ORM + `postgres` ライブラリ) を採用します。
* **動的接続・マルチクライアント管理:**
`shared/server/src/db/index.ts` にて `NODE_ENV === 'test'` の条件に応じて開発用（`DATABASE_URL`）とテスト用（`TEST_DATABASE_URL`）の接続を自動切替します。

```typescript
// shared/server/src/db/index.ts (要約コード)
export const queryClient = postgres(env.DATABASE_URL);
export const queryTestClient = postgres(env.TEST_DATABASE_URL);

export const dev_db = drizzle(queryClient, { schema });
export const test_db = drizzle(queryTestClient, { schema });

// テスト環境判定による動的エクスポート
export const db = isTest ? test_db : dev_db;
export const activeQueryClient = isTest ? queryTestClient : queryClient;

```

### 5.2 スキーマ定義 (Single Source of Truth)

データベースの構造は、`shared/schemas/src/` 配下（`users.ts`, `plugins.ts` 等）を正として定義します。

```typescript
// shared/schemas/src/users.ts & plugins.ts (要約コード)
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  role: text('role').notNull().default('user'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const plugins = pgTable('plugins', {
  id: serial('id').primaryKey(),
  name: text('name').notNull().unique(),
  enabled: boolean('enabled').notNull().default(true),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

```

#### ① `users` テーブル仕様

| カラム名 | DB論理名 | 型 | 制約 | 説明 |
| --- | --- | --- | --- | --- |
| `id` | `id` | `serial` | PRIMARY KEY | ユーザー識別子 |
| `name` | `name` | `text` | NOT NULL | ユーザー表示名 |
| `email` | `email` | `text` | NOT NULL, UNIQUE | メールアドレス（ログインID） |
| `passwordHash` | `password_hash` | `text` | NOT NULL | `bcryptjs` でハッシュ化されたパスワード |
| `role` | `role` | `text` | NOT NULL, Default: `'user'` | システム権限 (`user`, `admin` 等) |
| `createdAt` | `created_at` | `timestamp` | NOT NULL, Default: `now()` | レコード作成日時 |

#### ② `plugins` テーブル仕様

| カラム名 | DB論理名 | 型 | 制約 | 説明 |
| --- | --- | --- | --- | --- |
| `id` | `id` | `serial` | PRIMARY KEY | プラグインレコード識別子 |
| `name` | `name` | `text` | NOT NULL, UNIQUE | モジュール名（`sample`, `user-management` 等） |
| `enabled` | `enabled` | `boolean` | NOT NULL, Default: `true` | 有効/無効 フラグ |
| `createdAt` | `created_at` | `timestamp` | NOT NULL, Default: `now()` | レコード登録日時 |
| `updatedAt` | `updated_at` | `timestamp` | NOT NULL, Default: `now()` | レコード更新日時 |

---

## 6. API & エラーレスポンス仕様 (API & Error Handling)

### 6.1 統一エラーレスポンス仕様 (RFC 9457 準拠)

エラーレスポンスの構造を統一し、クライアント側（フロントエンド）でのエラー処理を明確化するため、最新標準である **RFC 9457 (Problem Details for HTTP APIs)** に完全準拠した構造を採用します（実装は `shared/errors/` に集約）。

無意味なダミー URI やハードコードを排除するため、特定の拡張ドキュメント URI を割り当てないエラーの `type` プロパティには、RFC 9457 の標準規格規定値である **`"about:blank"`** を一律に設定します。

| フィールド名 | キー名 | 役割・説明 | 設定例 |
| --- | --- | --- | --- |
| **エラー分類 URI** | `type` | エラーの種類を識別する URI（既定値: `"about:blank"`） | `"about:blank"` |
| **タイトル** | `title` | エラーの概要 | `"Bad Request"`, `"Unauthorized"`, `"Forbidden"` |
| **ステータスコード** | `status` | HTTP ステータスコード | `400`, `401`, `403`, `404`, `500`, `503` |
| **詳細メッセージ** | `detail` | 発生原因の具体的な説明 | `"You do not have permission to access this resource."` |
| **発生パス** | `instance` | エラーが発生したリクエスト URI パス | `"/api/auth/login"` |

---

### 6.2 認証・認可 API 仕様 (Authentication & Authorization API Spec)

ベース URL: `/api/auth`

#### ① ログイン & トークン発行 (`POST /api/auth/login`)

* **認証:** 不要
* **リクエスト (`application/json`):**

```json
{ "email": "test@example.com", "password": "password123" }

```

* **レスポンス (200 OK):**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { "id": 1, "email": "test@example.com", "role": "user" }
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
{ "user": { "id": 1, "email": "test@example.com", "role": "user" } }

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

* **正常時 (200 OK):** `{ "status": "ok", "db": "connected" }`
* **DB障害時 (503 Service Unavailable - RFC 9457):**

```json
{
  "type": "about:blank",
  "title": "Service Unavailable",
  "status": 503,
  "detail": "Database connection failed",
  "instance": "/healthz"
}

```

---

## 7. フロントエンド状態管理 & API 通信仕様 (Frontend State & Client Spec)

* **API クライアント (`apiClient.ts`):** Fetch ラッパー。JWT ヘッダー自動セット、および `!response.ok` 発生時に RFC 9457 オブジェクトを抽出してスロー。
* **認証コンテキスト (`AuthContext.tsx` / `useAuth`):** ログイン/ログアウト処理、ローカルストレージと連携したトークン保持・自動復元機能。
* **保護ルートガード (`ProtectedRoute.tsx`):** 未認証アクセス時にログインページへ安全に自動リダイレクト。
* **トースト通知 (`toaster.tsx`):** `apiClient` で発生したエラーを受け取り Sonner Toast でユーザーへ視覚的に通知。

---

## 8. セキュリティ & 環境変数仕様 (Security & Environment Variables)

### 8.1 定義されている環境変数

環境変数の定義・検証スキーマは `shared/functions/src/env.ts` に集約されています。

| 変数名 | 対象領域 | 型 / 制約 | 意図・役割 / 動的補完 |
| --- | --- | --- | --- |
| `NODE_ENV` | API | `'development'` | `'test'` | `'production'` | 実行環境の動作モード指定 |
| `PORT` | API | 数値 (デフォルト: `3001`) | API サーバーが待受を行うポート番号 |
| `API_BASE_URL` | API | URL形式文字列 (オプショナル) | 未定義時は `http://localhost:${PORT}` を自動補完 |
| `CORS_ORIGIN` | API | 文字列 (オプショナル) | 未定義時は `http://localhost:3000` を自動設定 |
| `DATABASE_URL` | API | URL形式文字列 | 開発・本番データベースへの接続 URI |
| `TEST_DATABASE_URL` | API | URL形式文字列 | テスト専用データベースへの接続 URI |
| `JWT_SECRET` | API | 32文字以上の文字列 | JWT アクセストークンの署名・検証キー |
| `VITE_PORT` | Web | 数値・文字列 | 開発用 Web サーバーの待受ポート |
| `VITE_API_TARGET_URL` | Web | URL形式文字列 | 開発時の API 転送先 (DevProxy ターゲット) |
| `VITE_APP_TITLE` | Web | 文字列 | アプリケーションの表示タイトル |

---

## 9. 動的モジュール読み込み仕様 (Dynamic Auto-Loader)

`apps/api/src/auto-loader/hono-auto-loader.ts` が DB の `plugins` テーブルの `enabled` フラグを参照し、`features/` 配下の機能モジュールを動的にインポートして Hono ルーティングへ展開します。

```typescript
// apps/api/src/auto-loader/hono-auto-loader.ts (要約コード)
const projectRoot = getProjectRootDir();
const absolutePath = path.resolve(projectRoot, file);
const moduleUrl = pathToFileURL(absolutePath).href; // OS非依存のURL変換

// 動的インポートとHonoインスタンスへのマウント
const module = await import(/* @vite-ignore */ moduleUrl);

```

---

## 10. テストアーキテクチャ & ライフサイクル (Testing Architecture)

* **テストランナー:** Vitest
* **配置方針:** コロケーション（実装ファイルと同階層に `.test.ts` を配置）
* **自動クリーンアップ & 非同期管理:**

1. **Global Setup:** テスト開始前にテスト用 DB のスキーマを自動同期（`shared/server/drizzle-test.config.ts`）。
2. **Setup Files:** 各テストケース実行前に DB データを全消去。
3. **Teardown:** 各 DB テストの `afterAll` で `activeQueryClient.end()` を呼び出しコネクション開放。

---

## 11. 実行スクリプト リファレンス (Scripts)

```bash
# 開発サーバー起動（API + Web 並行起動）
npm run dev

# 全パッケージのテスト実行（TDD）
npm test

# テスト用 DB スキーマ手動適用
npm run db:push:test

```
EOF_1787723354_31810

echo "作成: .env"
cat << 'EOF_1787723354_20946' > ".env"
# バックエンド用
PORT=3001
API_BASE_URL=http://localhost:3001
DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db
TEST_DATABASE_URL=postgresql://postgres:postgres@db:5432/app_db_test
JWT_SECRET=your-super-secret-jwt-key-must-be-at-least-32-bytes-long
TZ=Asia/Tokyo

# 認証プロバイダ (local または ad)
AUTH_PROVIDER=local

# AUTH_PROVIDER=ad の場合 Active Directory (LDAP) サーバー設定
LDAP_URL=ldap://your-dc-server.example.com:389
LDAP_DOMAIN=example.com

# フロントエンド用 (VITE_ プレフィックスを付ける)
# /workspace/apps/web/src/env.ts と同期する
VITE_PORT=3000
VITE_API_TARGET_URL=http://127.0.0.1:3001
VITE_APP_TITLE=マイアプリケーション
EOF_1787723354_20946

echo -e "\n復元が完了しました！"
