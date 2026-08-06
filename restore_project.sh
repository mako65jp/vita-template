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
cat << 'EOF_1786009069_24304' > "package.json"
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
    "db:push:all": "npm run db:push:all --workspaces --if-present",
    "coverage": "vitest run --coverage",
    "seed:user": "npx tsx --env-file=.env packages/core/src/seed-dev-user.ts",
    "seed:all": "npm run seed:user"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^6.0.5",
    "@vitest/coverage-v8": "^4.1.10",
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
EOF_1786009069_24304

echo "作成: .gitignore"
cat << 'EOF_1786009069_9011' > ".gitignore"
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
EOF_1786009069_9011

echo "作成: plan.md"
cat << 'EOF_1786009069_3234' > "plan.md"
# 📋 共通ひな形機能 一覧表（最新進捗版）

### 凡例

* ✅ **完了:** 機能要件およびテストがすべて実装・通過済み
* 🟡 **一部実装:** 基礎実装はあるが、詳細なテストや一部機能が未完成
* ⏳ **未実装:** まだ手をつけていない状態

---

| 機能名 | 担当パッケージ | 機能優先順位 | TDD優先順位 | 現状 | 実績と現状の対応 |
| --- | --- | --- | --- | --- | --- |
| **統一エラーハンドリング** | `apps/api` / `packages/core` | 🔴 **高** | **Step 1** | ✅ **完了** | RFC 9457（`about:blank`）準拠。404 / 500 / 共通例外の単体・統合テスト完了。 |
| **Zod リクエスト検証** | `apps/api` / `packages/core` | 🔴 **高** | **Step 2** | ✅ **完了** | 不正 payload 時に `invalidParams` を含む 400 Bad Request 返却のテスト完了。 |
| **DB スキーマ & ORM** | `apps/api` / `packages/core` | 🔴 **高** | **Step 3** | ✅ **完了** | `users` テーブル定義、`TEST_DATABASE_URL` 動的切替、CRUD / Unique 制約の DB 統合テスト完了。 |
| **認証・認可基盤 (Auth)** | `packages/plugins/auth-*` / `apps/api` | 🔴 **高** | **Step 4** | ✅ **完了** | JWT/ハッシュ化、`/login`, `/me` API、および `ForbiddenError` (403) を含む **RBAC (権限制御) ミドルウェアの単体・結合テストまで全完了。** |
| **構造化ロギング & ヘルス** | `apps/api` | 🟡 **中** | **Step 5** | ✅ **完了** | JSON ログ、機密情報マスク（`DATABASE_URL`等）、`/healthz` (503 DB切断テスト) 完了。 |
| **UI 基本コンポーネント** | `apps/web` / `packages/ui` | 🟡 **中** | **Step 6** | ✅ **完了** | Tailwind CSS v4 導入、共通 Layout（Header/Sidebar）、Sonner+RFC 9457 Toast 通知、Vitest+RTL テスト（コロケーション構成）完了。 |
| **ストレージ抽象化** | `packages/core` / `apps/api` | 🟢 **低** | **Step 7** | ⏳ **未実装** | 完全未着手。（ローカル / S3 保存機能、モックテスト） |
| **メール・通知基盤** | `packages/core` | 🟢 **低** | **Step 8** | ⏳ **未実装** | 完全未着手。（Nodemailer / Resend 連携、HTML テンプレートテスト） |

---
EOF_1786009069_3234

mkdir -p ".devcontainer/scripts"
echo "作成: .devcontainer/scripts/init-test-db.sh"
cat << 'EOF_1786009069_31667' > ".devcontainer/scripts/init-test-db.sh"
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE $POSTGRES_DB_TEST;
EOSQL
EOF_1786009069_31667

mkdir -p ".devcontainer"
echo "作成: .devcontainer/Dockerfile"
cat << 'EOF_1786009069_31402' > ".devcontainer/Dockerfile"
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone
    
EOF_1786009069_31402

mkdir -p ".devcontainer"
echo "作成: .devcontainer/devcontainer.json"
cat << 'EOF_1786009069_7708' > ".devcontainer/devcontainer.json"
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
EOF_1786009069_7708

mkdir -p ".devcontainer"
echo "作成: .devcontainer/docker-compose.yml"
cat << 'EOF_1786009069_2579' > ".devcontainer/docker-compose.yml"

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
EOF_1786009069_2579

echo "作成: tsconfig.json"
cat << 'EOF_1786009069_24929' > "tsconfig.json"
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
      "@app/ui/*": [
        "packages/ui/src/*"
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
EOF_1786009069_24929

echo "作成: vitest.config.ts"
cat << 'EOF_1786009069_9539' > "vitest.config.ts"
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
      'apps/web',
      // 'apps/web/vitest.config.ts',
    ],

    // 除外するファイル/フォルダ
    exclude: ['node_modules', 'dist', '.next', 'coverage'],

    coverage: {
      provider: 'v8', // or 'istanbul'
      include: ['**/*.{ts,tsx}']
    },

  },
});
EOF_1786009069_9539

mkdir -p "packages/ui"
echo "作成: packages/ui/package.json"
cat << 'EOF_1786009069_9166' > "packages/ui/package.json"
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
EOF_1786009069_9166

mkdir -p "packages/ui"
echo "作成: packages/ui/tsconfig.json"
cat << 'EOF_1786009069_30598' > "packages/ui/tsconfig.json"
{
    "compilerOptions": {
        "target": "ES2022",
        "module": "ESNext",
        "moduleResolution": "bundler",
        "jsx": "react-jsx",
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true,
        "baseUrl": ".",
        "paths": {
            "@app/ui/*": [
                "./src/*"
            ]
        },
        "types": [
            "vitest/globals",
            "@testing-library/jest-dom"
        ]
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1786009069_30598

mkdir -p "packages/ui"
echo "作成: packages/ui/vitest.config.ts"
cat << 'EOF_1786009069_16147' > "packages/ui/vitest.config.ts"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    test: {
        globals: true,
        environment: 'jsdom',
        setupFiles: ['./src/test/setup.ts'],
    },
});
EOF_1786009069_16147

mkdir -p "packages/ui/src"
echo "作成: packages/ui/src/index.ts"
cat << 'EOF_1786009069_24663' > "packages/ui/src/index.ts"
export * from './lib/utils';
export * from './components/button';
export * from './components/layout';
export * from './components/toaster';
EOF_1786009069_24663

mkdir -p "packages/ui/src/test"
echo "作成: packages/ui/src/test/setup.ts"
cat << 'EOF_1786009069_8696' > "packages/ui/src/test/setup.ts"
import '@testing-library/jest-dom';
EOF_1786009069_8696

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/button.tsx"
cat << 'EOF_1786009069_6178' > "packages/ui/src/components/button.tsx"
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
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);
Button.displayName = 'Button';
EOF_1786009069_6178

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/toaster.tsx"
cat << 'EOF_1786009069_28100' > "packages/ui/src/components/toaster.tsx"
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
EOF_1786009069_28100

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/layout.tsx"
cat << 'EOF_1786009069_4148' > "packages/ui/src/components/layout.tsx"
import * as React from 'react';
import { cn } from '../lib/utils';

interface LayoutProps {
    children: React.ReactNode;
    sidebar?: React.ReactNode;
    header?: React.ReactNode;
    className?: string;
}

export function AppLayout({ children, sidebar, header, className }: LayoutProps) {
    return (
        <div className="flex min-h-screen flex-col bg-gray-50 text-gray-900">
            {/* Header */}
            {header && (
                <header className="sticky top-0 z-40 border-b border-gray-200 bg-white/80 backdrop-blur">
                    {header}
                </header>
            )}

            <div className="flex flex-1">
                {/* Sidebar */}
                {sidebar && (
                    <aside className="w-64 shrink-0 border-r border-gray-200 bg-white p-4 hidden md:block">
                        {sidebar}
                    </aside>
                )}

                {/* Main Content */}
                <main className={cn('flex-1 p-6 max-w-7xl mx-auto w-full', className)}>
                    {children}
                </main>
            </div>
        </div>
    );
}

export function HeaderContent({ title }: { title: string }) {
    return (
        <div className="flex h-16 items-center justify-between px-6">
            <h1 className="text-xl font-bold tracking-tight text-gray-900">{title}</h1>
            <div className="flex items-center gap-4">
                <span className="text-sm text-gray-500">Dev App</span>
            </div>
        </div>
    );
}

export function SidebarNav({ items }: { items: { label: string; href: string; active?: boolean }[] }) {
    return (
        <nav className="flex flex-col gap-1">
            {items.map((item) => (
                <a
                    key={item.href}
                    href={item.href}
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
EOF_1786009069_4148

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/button.test.tsx"
cat << 'EOF_1786009069_17191' > "packages/ui/src/components/button.test.tsx"
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
EOF_1786009069_17191

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/layout.test.tsx"
cat << 'EOF_1786009069_32004' > "packages/ui/src/components/layout.test.tsx"
import { render, screen } from '@testing-library/react';
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
        expect(screen.getByRole('link', { name: 'メニュー1' })).toBeInTheDocument();
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
EOF_1786009069_32004

mkdir -p "packages/ui/src/components"
echo "作成: packages/ui/src/components/toaster.test.tsx"
cat << 'EOF_1786009069_12891' > "packages/ui/src/components/toaster.test.tsx"
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
EOF_1786009069_12891

mkdir -p "packages/ui/src/lib"
echo "作成: packages/ui/src/lib/utils.ts"
cat << 'EOF_1786009069_21079' > "packages/ui/src/lib/utils.ts"
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
EOF_1786009069_21079

mkdir -p "packages/plugins/auth-ad"
echo "作成: packages/plugins/auth-ad/package.json"
cat << 'EOF_1786009069_17570' > "packages/plugins/auth-ad/package.json"
{
  "name": "@app/plugins-auth-ad",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1786009069_17570

mkdir -p "packages/plugins/auth-ad/src"
echo "作成: packages/plugins/auth-ad/src/index.ts"
cat << 'EOF_1786009069_21672' > "packages/plugins/auth-ad/src/index.ts"
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
EOF_1786009069_21672

mkdir -p "packages/plugins/auth-local"
echo "作成: packages/plugins/auth-local/package.json"
cat << 'EOF_1786009069_16208' > "packages/plugins/auth-local/package.json"
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
EOF_1786009069_16208

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/index.ts"
cat << 'EOF_1786009069_17879' > "packages/plugins/auth-local/src/index.ts"
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
EOF_1786009069_17879

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/auth-utils.ts"
cat << 'EOF_1786009069_12685' > "packages/plugins/auth-local/src/auth-utils.ts"
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
EOF_1786009069_12685

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/auth-utils.test.ts"
cat << 'EOF_1786009069_28970' > "packages/plugins/auth-local/src/auth-utils.test.ts"
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
EOF_1786009069_28970

mkdir -p "packages/core"
echo "作成: packages/core/package.json"
cat << 'EOF_1786009069_25742' > "packages/core/package.json"
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
EOF_1786009069_25742

mkdir -p "packages/core"
echo "作成: packages/core/drizzle-test.config.ts"
cat << 'EOF_1786009069_7477' > "packages/core/drizzle-test.config.ts"
import { defineConfig } from 'drizzle-kit';
import { env } from './src/config/env';

export default defineConfig({
    schema: './src/db/schema.ts',
    out: './drizzle',
    dialect: 'postgresql',
    dbCredentials: {
        url: env.TEST_DATABASE_URL,
    },
});
EOF_1786009069_7477

mkdir -p "packages/core"
echo "作成: packages/core/vitest.config.ts"
cat << 'EOF_1786009069_5064' > "packages/core/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    test: {
        globalSetup: ['./src/test/global-setup.ts'],    // ① テスト前に自動で db:push:test
        setupFiles: ['./src/test/setup.ts'],            // ② 各テスト実行前にテーブルデータを全消去
        fileParallelism: false,                         // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
    },
});
EOF_1786009069_5064

mkdir -p "packages/core/src/registry"
echo "作成: packages/core/src/registry/hono-auto-loader.ts"
cat << 'EOF_1786009069_24372' > "packages/core/src/registry/hono-auto-loader.ts"
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
    const module = await import(moduleUrl);

    if (module.default && typeof module.default === 'function') {
      const route = module.default();
      app.route('/', route);
      console.log(`[Auto-Loader] Loaded Feature module: ${file}`);
    }
  }
}
EOF_1786009069_24372

mkdir -p "packages/core/src"
echo "作成: packages/core/src/index.ts"
cat << 'EOF_1786009069_3149' > "packages/core/src/index.ts"
export * from './auth/auth-registry';
export * from './registry/hono-auto-loader';
export * from './db';
export * from './config/env';
export * from './errors';
EOF_1786009069_3149

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.test.ts"
cat << 'EOF_1786009069_26224' > "packages/core/src/config/env.test.ts"
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { envSchema, formatEnvForLog } from './env';

// 💡 テスト専用の検証用ヘルパー関数
function parseEnv(targetEnv: Record<string, string | undefined>) {
    const result = envSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        throw new Error(`環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

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

        const env = parseEnv(process.env);

        expect(env.DATABASE_URL).toBe('postgresql://postgres:postgres@localhost:5432/app_db');
        expect(env.PORT).toBe(3001); // 文字列から数値へ変換されること
        expect(env.NODE_ENV).toBe('development');
    });

    it('PORT が指定されていない場合、デフォルト値 3001 を使用すること', () => {
        process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/app_db';
        delete process.env.PORT;

        const env = parseEnv(process.env);

        expect(env.PORT).toBe(3001);
    });

    it('DATABASE_URL が存在しない場合、エラーをスローすること', () => {
        delete process.env.DATABASE_URL;

        expect(() => parseEnv(process.env)).toThrowError('環境変数の検証に失敗しました');
    });

    it('PORT に数値以外の文字列が渡された場合、エラーをスローすること', () => {
        process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/app_db';
        process.env.PORT = 'not-a-number';

        expect(() => parseEnv(process.env)).toThrowError();
    });
});

describe('formatEnvForLog', () => {
    it('DATABASE_URL などのパスワード部分がマスク処理されて文字列化されること', () => {
        const mockEnv = {
            NODE_ENV: 'development' as const,
            PORT: 3001,
            DATABASE_URL: 'postgresql://postgres:secret_pass@localhost:5432/app_db',
            TEST_DATABASE_URL: 'postgresql://postgres:secret_pass@localhost:5432/app_db_test',
            JWT_SECRET: 'JWT_SECRET must be at least 32 characters long',
        };

        const formatted = formatEnvForLog(mockEnv);

        // ダブルクォーテーション付きの "PORT": 3001 を検証
        expect(formatted).toContain('"PORT": 3001');
        expect(formatted).not.toContain('secret_pass'); // パスワードが露出していないこと
        expect(formatted).toContain('***'); // マスクされていること
    });
});
EOF_1786009069_26224

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.ts"
cat << 'EOF_1786009069_20305' > "packages/core/src/config/env.ts"
import { z } from 'zod';

// ==========================================
// 1. バックエンド用 (Node.js) スキーマ & 関数
// ==========================================
export const envSchema = z
    .object({
        NODE_ENV: z.enum(['development', 'test', 'production'])
            .default('development'),
        PORT: z.coerce.number()
            .default(3001),
        API_BASE_URL: z.string().url().optional(),
        DATABASE_URL: z.string().url({ message: 'DATABASE_URL は有効なURL形式である必要があります' }),
        TEST_DATABASE_URL: z.string().url({ message: 'TEST_DATABASE_URL は有効なURL形式である必要があります' })
            .default('postgresql://postgres:postgres@localhost:5432/app_db_test'),
        JWT_SECRET: z.string().min(32)
            .default('super-secret-jwt-key-for-testing-purposes-123456'),
    })
    .transform((data) => ({
        ...data,
        // API_BASE_URL が明示的に与えられていない場合は PORT から動的に補完
        API_BASE_URL: data.API_BASE_URL ?? `http://localhost:${data.PORT}`,
    }));

export type Env = z.infer<typeof envSchema>;

// テスト時も含めて安全に検証したオブジェクトを取得
export const env: Env = typeof window !== 'undefined' ? ({} as Env) : validateEnv();

function validateEnv(targetEnv: Record<string, string | undefined> = process.env): Env {
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
 * 引数を渡さない場合は内部の `env` を使用
 */
export function formatEnvForLog(targetEnv: Env = env): string {
    const maskedEnv = { ...targetEnv };

    if (maskedEnv.DATABASE_URL) {
        maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL.replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    }
    if (maskedEnv.TEST_DATABASE_URL) {
        maskedEnv.TEST_DATABASE_URL = maskedEnv.TEST_DATABASE_URL.replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    }
    if (maskedEnv.JWT_SECRET) {
        maskedEnv.JWT_SECRET = '***';
    }

    return JSON.stringify(maskedEnv, null, 2);
}

// ==========================================
// 2. フロントエンド用 (Vite / Browser) スキーマ
// ==========================================
export const clientEnvSchema = z.object({
    VITE_PORT: z.string().optional()
        .default('3000'),
    VITE_API_TARGET_URL: z.string().url().optional()
        .default('http://127.0.0.1:3001'),
    VITE_APP_TITLE: z.string().optional()
        .default('My App'),
});

export type ClientEnv = z.infer<typeof clientEnvSchema>;
EOF_1786009069_20305

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/index.ts"
cat << 'EOF_1786009069_24313' > "packages/core/src/db/index.ts"
import { drizzle } from 'drizzle-orm/postgres-js';

import postgres from 'postgres';
import * as schema from './schema';
import { env } from '../config/env';

const isTest = env.NODE_ENV === 'test';

// 開発用（本番用）PostgreSQL 接続クライアントの作成
const queryClient = postgres(env.DATABASE_URL);
export const dev_db = drizzle(queryClient, { schema });

// テスト用PostgreSQL 接続クライアントの作成
const queryTestClient = postgres(env.TEST_DATABASE_URL);
export const test_db = drizzle(queryTestClient, { schema });

// テスト用と開発用（本番用）の接続クライアント動的に選択
export const db = isTest ? test_db : dev_db;

// テスト終了時などにコネクションを安全に破棄するためのクライアント
export const activeQueryClient = isTest ? queryTestClient : queryClient;

// 💡 スキーマも外部から参照できるように export します
export { schema };
EOF_1786009069_24313

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/schema.ts"
cat << 'EOF_1786009069_27279' > "packages/core/src/db/schema.ts"
import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
    id: serial('id').primaryKey(),
    name: text('name').notNull(),
    email: text('email').notNull().unique(),
    passwordHash: text('password_hash').notNull(),
    role: text('role').notNull().default('user'),
    createdAt: timestamp('created_at').defaultNow().notNull(),
});
EOF_1786009069_27279

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/users.test.ts"
cat << 'EOF_1786009069_10598' > "packages/core/src/db/users.test.ts"
import { describe, it, expect, afterAll, beforeEach } from 'vitest';
import { db, activeQueryClient } from './index';
import { users } from './schema';
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
        expect(inserted.createdAt).toBeInstanceOf(Date);

        // IDで検索して同一データが取得できるか
        const [found] = await db.select().from(users).where(eq(users.id, inserted.id));
        expect(found).toBeDefined();
        expect(found.email).toBe(newUser.email);
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
EOF_1786009069_10598

mkdir -p "packages/core/src/auth"
echo "作成: packages/core/src/auth/auth-registry.ts"
cat << 'EOF_1786009069_8820' > "packages/core/src/auth/auth-registry.ts"
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
EOF_1786009069_8820

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/unauthorized-error.ts"
cat << 'EOF_1786009069_22265' > "packages/core/src/errors/unauthorized-error.ts"
import { AppError } from './app-error';

export class UnauthorizedError extends AppError {
    constructor(message = 'Authentication token is missing or invalid') {
        super(401, 'unauthorized', 'Unauthorized', message);
    }
}
EOF_1786009069_22265

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/index.ts"
cat << 'EOF_1786009069_31922' > "packages/core/src/errors/index.ts"
export * from './types';
export * from './app-error';
export * from './not-found-error';
export * from './internal-server-error';
export * from './validation-error';
export * from './unauthorized-error';
export * from './forbidden-error';
EOF_1786009069_31922

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/app-error.ts"
cat << 'EOF_1786009069_31408' > "packages/core/src/errors/app-error.ts"
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
EOF_1786009069_31408

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/types.ts"
cat << 'EOF_1786009069_29081' > "packages/core/src/errors/types.ts"
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
EOF_1786009069_29081

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/forbidden-error.ts"
cat << 'EOF_1786009069_216' > "packages/core/src/errors/forbidden-error.ts"
import { AppError } from './app-error';

export class ForbiddenError extends AppError {
    constructor(message = 'You do not have permission to access this resource') {
        super(403, 'forbidden', 'Forbidden', message);
    }
}
EOF_1786009069_216

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/validation-error.ts"
cat << 'EOF_1786009069_31509' > "packages/core/src/errors/validation-error.ts"
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
EOF_1786009069_31509

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/not-found-error.ts"
cat << 'EOF_1786009069_11374' > "packages/core/src/errors/not-found-error.ts"
import { AppError } from './app-error';

export class NotFoundError extends AppError {
    constructor(message = 'The requested resource was not found') {
        super(404, 'not-found', 'Not Found', message);
    }
}
EOF_1786009069_11374

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/internal-server-error.ts"
cat << 'EOF_1786009069_19156' > "packages/core/src/errors/internal-server-error.ts"
import { AppError } from './app-error';

export class InternalServerError extends AppError {
    constructor(message = 'An unexpected error occurred') {
        super(500, 'internal-server-error', 'Internal Server Error', message);
    }
}
EOF_1786009069_19156

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/setup.ts"
cat << 'EOF_1786009069_289' > "packages/core/src/test/setup.ts"
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
EOF_1786009069_289

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/global-setup.ts"
cat << 'EOF_1786009069_24307' > "packages/core/src/test/global-setup.ts"
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
EOF_1786009069_24307

mkdir -p "packages/core/src"
echo "作成: packages/core/src/seed-dev-user.ts"
cat << 'EOF_1786009069_11891' > "packages/core/src/seed-dev-user.ts"
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
EOF_1786009069_11891

mkdir -p "packages/core"
echo "作成: packages/core/drizzle.config.ts"
cat << 'EOF_1786009069_26918' > "packages/core/drizzle.config.ts"
import { defineConfig } from 'drizzle-kit';
import { env } from './src/config/env';

export default defineConfig({
    schema: './src/db/schema.ts',
    out: './drizzle',
    dialect: 'postgresql',
    dbCredentials: {
        url: env.DATABASE_URL,
    },
});
EOF_1786009069_26918

mkdir -p "packages/features/sample"
echo "作成: packages/features/sample/package.json"
cat << 'EOF_1786009069_12270' > "packages/features/sample/package.json"
{
  "name": "@app/features-sample",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1786009069_12270

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.ts"
cat << 'EOF_1786009069_8366' > "packages/features/sample/src/index.ts"
import { Hono } from 'hono';

export default function createSampleFeature() {
  const app = new Hono();

  app.get('/sample', (c) => {
    return c.json({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });

  return app;
}
EOF_1786009069_8366

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.test.ts"
cat << 'EOF_1786009069_18235' > "packages/features/sample/src/index.test.ts"
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
EOF_1786009069_18235

echo "作成: doc.md"
cat << 'EOF_1786009069_25905' > "doc.md"
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
EOF_1786009069_25905

echo "作成: SUMMRY.md"
cat << 'EOF_1786009069_31734' > "SUMMRY.md"
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
EOF_1786009069_31734

mkdir -p "apps/web"
echo "作成: apps/web/package.json"
cat << 'EOF_1786009069_28839' > "apps/web/package.json"
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
EOF_1786009069_28839

mkdir -p "apps/web"
echo "作成: apps/web/index.html"
cat << 'EOF_1786009069_5490' > "apps/web/index.html"
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
EOF_1786009069_5490

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.json"
cat << 'EOF_1786009069_2757' > "apps/web/tsconfig.json"
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
      "@app/core": [
        "../../packages/core/src/index.ts"
      ],
      "@app/core/*": [
        "../../packages/core/src/*"
      ],
      "@app/ui": [
        "../../packages/ui/src/index.ts"
      ],
      "@app/ui/*": [
        "../../packages/ui/src/*"
      ]
    }
  },
  "include": [
    "src",
    "../../packages/ui/src/**/*"
  ],
  "references": [
    {
      "path": "./tsconfig.node.json"
    }
  ]
}
EOF_1786009069_2757

mkdir -p "apps/web"
echo "作成: apps/web/vitest.config.ts"
cat << 'EOF_1786009069_22043' > "apps/web/vitest.config.ts"
import { defineConfig, mergeConfig } from 'vitest/config';
import viteConfig from './vite.config';

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
EOF_1786009069_22043

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.node.json"
cat << 'EOF_1786009069_1595' > "apps/web/tsconfig.node.json"
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
EOF_1786009069_1595

mkdir -p "apps/web/src"
echo "作成: apps/web/src/index.css"
cat << 'EOF_1786009069_26548' > "apps/web/src/index.css"
@import "tailwindcss";

/* モノレポ内の共有 UI パッケージも Tailwind のスキャン対象に指定 */
@source "../../../packages/ui/src";
EOF_1786009069_26548

mkdir -p "apps/web/src/test"
echo "作成: apps/web/src/test/setup.ts"
cat << 'EOF_1786009069_11385' > "apps/web/src/test/setup.ts"
import '@testing-library/jest-dom';
EOF_1786009069_11385

mkdir -p "apps/web/src"
echo "作成: apps/web/src/main.tsx"
cat << 'EOF_1786009069_12501' > "apps/web/src/main.tsx"
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF_1786009069_12501

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.test.tsx"
cat << 'EOF_1786009069_24242' > "apps/web/src/context/AuthContext.test.tsx"
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
EOF_1786009069_24242

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.tsx"
cat << 'EOF_1786009069_30971' > "apps/web/src/context/AuthContext.tsx"
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
EOF_1786009069_30971

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.tsx"
cat << 'EOF_1786009069_25924' > "apps/web/src/components/LoginForm.tsx"
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
EOF_1786009069_25924

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.test.tsx"
cat << 'EOF_1786009069_4801' > "apps/web/src/components/LoginForm.test.tsx"
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
EOF_1786009069_4801

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.tsx"
cat << 'EOF_1786009069_11617' > "apps/web/src/App.tsx"
import { AppLayout, HeaderContent, SidebarNav, Button, Toaster, toast, showErrorToast } from '@app/ui';

export function App() {
  const navItems = [
    { label: 'ダッシュボード', href: '#', active: true },
    { label: 'プロジェクト一覧', href: '#' },
    { label: '設定', href: '#' },
  ];

  // 成功通知テスト
  const handleSuccessToast = () => {
    toast.success('処理が完了しました', {
      description: 'データが正常に保存されました。',
    });
  };

  // RFC 9457 形式のエラー通知テスト
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

  return (
    <AppLayout
      header={<HeaderContent title="管理システム" />}
      sidebar={<SidebarNav items={navItems} />}
    >
      {/* Toast のプロバイダー配置 */}
      <Toaster />

      <div className="flex flex-col gap-6">
        <div className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-900 mb-2">Toast 通知・エラー表示テスト</h2>
          <p className="text-sm text-gray-600 mb-4">
            ボタンをクリックして Toast 通知および RFC 9457 エラーハンドリングの動作を確認してください。
          </p>
          <div className="flex gap-2">
            <Button variant="default" onClick={handleSuccessToast}>
              成功 Toast を表示
            </Button>
            <Button variant="destructive" onClick={handleRfcErrorToast}>
              RFC 9457 エラー Toast を表示
            </Button>
          </div>
        </div>
      </div>
    </AppLayout>
  );
}

export default App;
EOF_1786009069_11617

mkdir -p "apps/web/src"
echo "作成: apps/web/src/env.ts"
cat << 'EOF_1786009069_28264' > "apps/web/src/env.ts"
import { clientEnvSchema, type ClientEnv } from '@app/core';

// Vite の import.meta.env を Zod で検証・補完
export const env: ClientEnv = clientEnvSchema.parse({
    VITE_PORT: import.meta.env.VITE_PORT,
    VITE_API_TARGET_URL: import.meta.env.VITE_API_TARGET_URL,
    VITE_APP_TITLE: import.meta.env.VITE_APP_TITLE,
});
EOF_1786009069_28264

mkdir -p "apps/web"
echo "作成: apps/web/vite.config.ts"
cat << 'EOF_1786009069_17131' > "apps/web/vite.config.ts"
import { defineConfig } from 'vitest/config';
import { loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
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

        plugins: [react(), tailwindcss()],
        resolve: {
            tsconfigPaths: true
        },

        server: {
            host: true,
            port: webPort,
            proxy: {
                '/api': apiTarget,
                '/sample': apiTarget,
            },
        },
    };
});
EOF_1786009069_17131

mkdir -p "apps/api"
echo "作成: apps/api/package.json"
cat << 'EOF_1786009069_32104' > "apps/api/package.json"
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
EOF_1786009069_32104

mkdir -p "apps/api"
echo "作成: apps/api/tsconfig.json"
cat << 'EOF_1786009069_12893' > "apps/api/tsconfig.json"
{
    "extends": "../../tsconfig.json",
    "compilerOptions": {
        "target": "ES2022",
        "module": "ESNext",
        "moduleResolution": "bundler",
        "outDir": "./dist",
        "types": [
            "node"
        ],
        "baseUrl": ".",
        "paths": {
            "@app/core": [
                "../../packages/core/src/index.ts"
            ],
            "@app/core/*": [
                "../../packages/core/src/*"
            ]
        }
    },
    "include": [
        "src/**/*"
    ]
}
EOF_1786009069_12893

mkdir -p "apps/api"
echo "作成: apps/api/vitest.config.ts"
cat << 'EOF_1786009070_17989' > "apps/api/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
  },
});
EOF_1786009070_17989

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.ts"
cat << 'EOF_1786009070_26418' > "apps/api/src/index.ts"
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { env, formatEnvForLog } from '@app/core';
import { AppError, ProblemDetails, ValidationError } from '@app/core';
import { loadFeatureModules } from '@app/core';
import { AuthRegistry } from '@app/core';
import { LocalAuthPlugin } from '@app/plugins-auth-local';
import { ActiveDirectoryAuthPlugin } from '@app/plugins-auth-ad';
import { authRouter } from './routes/auth';
import { healthRouter } from './routes/health';
import { loggerMiddleware } from './middlewares/logger';

// コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
if (env.NODE_ENV !== 'test') {
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

// -----------------------------------------------------------------------------
// テスト専用ルート (NODE_ENV === 'test' の場合のみ有効化)
// -----------------------------------------------------------------------------
if (env.NODE_ENV === 'test') {
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

// プラグイン/フィーチャーモジュールの動的読み込み
await loadFeatureModules(app, 'packages/features/*/src/index.ts');

// -----------------------------------------------------------------------------
// テスト専用バリデーションルート (NODE_ENV === 'test' の場合のみ)
// -----------------------------------------------------------------------------
if (env.NODE_ENV === 'test') {
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

// 💡 テスト環境（NODE_ENV === 'test'）以外の場合のみ、実際の HTTP サーバーを起動する
if (env.NODE_ENV !== 'test') {
    console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);
    serve({
        fetch: app.fetch,
        port,
        hostname: '0.0.0.0',
    });
}

export default app;
EOF_1786009070_26418

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.test.ts"
cat << 'EOF_1786009070_20870' > "apps/api/src/index.test.ts"
import { describe, it, expect } from 'vitest';
import app from './index';

describe('API Error Handling (RFC 9457)', () => {
    it('未定義のルートにアクセスした場合、404エラーがRFC9457形式で返ること', async () => {
        const res = await app.request('/api/non-existent-route');
        expect(res.status).toBe(404);

        const body = await res.json();
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

        const body = await res.json();
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

        const body = await res.json();
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
EOF_1786009070_20870

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/health.test.ts"
cat << 'EOF_1786009070_19994' > "apps/api/src/routes/health.test.ts"
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import app from '../index';
import { db } from '@app/core';

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
EOF_1786009070_19994

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.ts"
cat << 'EOF_1786009070_26570' > "apps/api/src/routes/auth.ts"
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
EOF_1786009070_26570

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/health.ts"
cat << 'EOF_1786009070_16945' > "apps/api/src/routes/health.ts"
import { Hono } from 'hono';
import { db, AppError } from '@app/core';
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
EOF_1786009070_16945

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.test.ts"
cat << 'EOF_1786009070_14559' > "apps/api/src/routes/auth.test.ts"
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
EOF_1786009070_14559

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.ts"
cat << 'EOF_1786009070_26323' > "apps/api/src/middlewares/auth-middleware.ts"
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
EOF_1786009070_26323

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.test.ts"
cat << 'EOF_1786009070_27571' > "apps/api/src/middlewares/auth-middleware.test.ts"
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
EOF_1786009070_27571

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/rbac-middleware.test.ts"
cat << 'EOF_1786009070_20407' > "apps/api/src/middlewares/rbac-middleware.test.ts"
// apps/api/src/middlewares/rbac-middleware.test.ts
import { describe, it, expect } from 'vitest';
import { Hono } from 'hono';
import { authMiddleware } from './auth-middleware';
import { requireRole } from './rbac-middleware';
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
        app.use('/admin/*', requireRole(['admin']));

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
        const body = await res.json();
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
        const body = await res.json();
        expect(body.message).toBe('Admin Dashboard');
    });
});
EOF_1786009070_20407

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/logger.test.ts"
cat << 'EOF_1786009070_28135' > "apps/api/src/middlewares/logger.test.ts"
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
EOF_1786009070_28135

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/rbac-middleware.ts"
cat << 'EOF_1786009070_14400' > "apps/api/src/middlewares/rbac-middleware.ts"
// apps/api/src/middlewares/rbac-middleware.ts
import type { MiddlewareHandler } from 'hono';
import { ForbiddenError, UnauthorizedError } from '@app/core';

/**
 * 許可されたロールのみアクセスを許可する RBAC ミドルウェア
 * @param allowedRoles 許可するロールの配列 (例: ['admin'])
 */
export function requireRole(allowedRoles: string[]): MiddlewareHandler {
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
EOF_1786009070_14400

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/logger.ts"
cat << 'EOF_1786009070_423' > "apps/api/src/middlewares/logger.ts"
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
EOF_1786009070_423

echo "作成: README.md"
cat << 'EOF_1786009070_6005' > "README.md"
# 📖 プロジェクト基本仕様書 (Project Architecture Specification) - v2.4

## 1. システム概要 (Overview)

本プロジェクトは、TypeScript をベースとしたモノレポ構成の Web アプリケーションです。
バックエンドには軽量・高速な Web フレームワーク（**Hono**）、フロントエンドにはコンポーネント指向 UI ライブラリ（**React + Vite + Tailwind CSS**）、データベース操作には型安全な ORM（**Drizzle ORM / PostgreSQL**）を採用しています。
共通ロジックや拡張機能（認証・UI コンポーネント・業務モジュール等）を独立したパッケージへ分離することで、保守性と拡張性を高めたコンポーザブルなアーキテクチャを実現します。

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
| **`packages/core`** | 共通基盤 | システム全域で利用される不変的な「基盤ルール」を集約 | 型定義、環境変数検証、DB接続・スキーマ定義、共通エラー定義 (RFC 9457)、動的ローダー | 上位のビジネスロジックや特定アプリへの依存厳禁 |
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

プロジェクト全体のフォルダおよびファイル構造です。各モジュールごとのテスト配置と役割分担を整理しています。コンポーネントとそのテストはコロケーション（同一ディレクトリ配置）を基本原則とします。

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
│   │   │   ├── index.ts          # API エントリーポイント (ルーティング統括・共通エラーハンドラー・RFC 9457)
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
│       │   ├── App.tsx           # ルート UI コンポーネント
│       │   ├── App.test.tsx      # ルート UI 単体テスト
│       │   ├── main.tsx          # React レンダリングエントリーポイント (index.cssインポート必須)
│       │   ├── index.css         # Tailwind CSS v4 エントリーポイント (@import "tailwindcss"; @source ...)
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
    │   │   │   ├── env.ts        # Zod による環境変数定義・検証関数 (API_BASE_URL 自動変換等)
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
4. **フロントエンド連携:** フロントエンド側では `showErrorToast` ユーティリティ（`packages/ui`）により、レスポンスの RFC 9457 JSON（`title`, `detail`）を自動抽出し、Sonner Toast として表示。

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

## 7. セキュリティ & 環境変数仕様 (Security & Environment Variables)

### 7.1 定義されている環境変数

| 変数名 | 対象領域 | 型 / 制約 | 意図・役割 / 動的補完 |
| --- | --- | --- | --- |
| `NODE_ENV` | API | `'development'` | `'test'` | `'production'` | 実行環境の動作モード指定 |
| `PORT` | API | 数値 (デフォルト: `3001`) | API サーバーが待受を行うポート番号 |
| `API_BASE_URL` | API | URL形式文字列 (オプショナル) | API のベース URL。未定義の場合は `PORT` の値から `http://localhost:${PORT}` を Zod transform により自動生成 |
| `DATABASE_URL` | API | URL形式文字列 | 開発・本番データベースへの接続 URI |
| `TEST_DATABASE_URL` | API | URL形式文字列 | テスト専用データベースへの接続 URI |
| `JWT_SECRET` | API | 32文字以上の文字列 | JWT アクセストークンの署名・検証に使用するシークレットキー |
| `VITE_PORT` | Web | 数値・文字列 | 開発用 Web サーバーの待受ポート |
| `VITE_API_TARGET_URL` | Web | URL形式文字列 | 開発時の API 転送先 (DevProxy ターゲット) |
| `VITE_APP_TITLE` | Web | 文字列 | アプリケーションの表示タイトル |

### 7.2 セキュリティ設計

1. **フェイルファスト（Fail-Fast）原則:** 起動時に Zod で環境変数を検証し、不備があれば即座に起動を停止。
2. **`API_BASE_URL` の動的連動:** ハードコードを排除し、環境変数または `PORT` から動的に計算されたベース URL を使用。
3. **ログマスク処理:** 接続パスワード等を含む文字列（`DATABASE_URL`, `TEST_DATABASE_URL`）はシステムログ出力時に自動でマスク（`***` 化）。
4. **パスワードハッシュ & トークン:** 平文保存を禁止し、`bcryptjs` でハッシュ化。トークン生成には `jose` を使用。
5. **権制度制御（RBAC）:** ロールベースアクセス制御 (`requireRole`) により、無効または権限不足のリクエストに対して 403 Forbidden（RFC 9457）を厳格に返却。
6. **曖昧なエラーメッセージ:** ログイン失敗時は理由を区別せず一律 `Invalid credentials.` (401) を返却し、アカウント列挙攻撃を防止。
7. **CORS & クライアント環境変数:** Web アプリからの通信は CORS 設定で許可。ブラウザ公開環境変数は `VITE_` プレフィックスに限定し `apps/web/src/env.ts` 経由でカプセル化。

---

## 8. 動的モジュール読み込み仕様 (Dynamic Auto-Loader)

### 8.1 機能の自動検出とルーティング登録

* 各 Feature パッケージが持つ API ルート（Hono インスタンス）を個別に手動インポートする手間を省くため、指定ディレクトリ配下のモジュールを動的に探索・一括登録する自動ローダー機構（`hono-auto-loader.ts`）を導入します。

### 8.2 クロスプラットフォーム＆モジュール互換性の保障

* OS 間（Windows / Linux / macOS）のファイルパス記法差異や、ビルドツール（Vite / Node.js ESM）の URL 解釈エラーを回避するため、`pathToFileURL` を用いて変換します。

```typescript
// packages/core/src/registry/hono-auto-loader.ts
const absolutePath = path.resolve(file);
const moduleUrl = pathToFileURL(absolutePath).href; // URI形式へ安全に変換
const module = await import(/* @vite-ignore */ moduleUrl); // 不要な静的解析警告を抑止

```

---

## 9. テストアーキテクチャ & ライフサイクル (Testing Architecture)

テストの信頼性と再現性を維持するため、**「テスト実行時の環境の自動セットアップ」** と **「テストケース間の相互干渉防止」**、および **「コロケーション（同一ディレクトリ）テスト配置」** を導入しています。

### 9.1 テスト基盤と疎結合アサーション

* **テストランナー:** Vitest（高速なインメモリ実行およびモジュール連携環境を提供）
* **テスト配置方針（コロケーション）:** UI コンポーネントおよび個別のユニットモジュールに対するテストコードは、実装ファイルと同じディレクトリに併設（例: `button.tsx` と `button.test.tsx`）。リファクタリング時の影響範囲を限定化します。
* **モックの適切なクリーンアップ:** 各テスト実行前に `beforeEach` で `vi.restoreAllMocks()` / `vi.clearAllMocks()` を実行し、モックの状態リークを防止。
* **疎結合アサーション方針:** テストコードがプロダクトコードの内部実装（ドキュメント URL 構造等）に過剰に結合するのを防ぐため、アサーションには `toMatchObject` または正確なエラー構造の同一性検証を用い、脆いテスト（Fragile Test）化を防止します。

### 9.2 テスト自動化ライフサイクル

1. **テスト開始前の DB スキーマ自動同期 (Global Setup):**
全テスト実行直前に `globalSetup` が `drizzle-test.config.ts` を用いてテスト用 DB（`TEST_DATABASE_URL`）のスキーマを自動同期。
2. **テストケース間の完全な状態隔離 (Setup Files):**
各テスト実行直前に `packages/core/src/test/setup.ts` 等でデータベース内のデータを自動一括消去。
3. **DOM マッチャーの型拡張:**
フロントエンドテスト（`apps/web`, `packages/ui`）では `@testing-library/jest-dom` および `@testing-library/user-event` を読み込み、`toBeInTheDocument` や `toBeDisabled` などの標準 DOM アサーションを完全型安全に利用可能化。
4. **テスト終了後のコネクション安全開放:**
各 DB 統合テストの `afterAll` フックにて `activeQueryClient.end()` を呼び出し、PostgreSQL コネクションの切り忘れを防止。

---

## 10. 実行スクリプト リファレンス (Scripts)

プロジェクト内で利用する標準的なコマンドです。

### 10.1 開発サーバー起動

すべてのアプリケーション（API・Web）を開発モードで並行起動します。

```bash
npm run dev

```

### 10.2 全テストの自動実行 (TDD)

すべてのパッケージの単体テスト、DB 連携テスト、ミドルウェア・API 統合テスト、UI コンポーネントテストを一括実行します。

```bash
npm test

```

### 10.3 テスト用 DB スキーマの手動同期

テスト環境のデータベース構造を手動で最新状態へ更新したい場合に実行します。

```bash
npm run db:push:test

```
EOF_1786009070_6005

echo "作成: .env"
cat << 'EOF_1786009070_16133' > ".env"
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
EOF_1786009070_16133

echo -e "\n復元が完了しました！"
