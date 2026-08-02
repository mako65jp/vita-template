#!/bin/bash
set -e

echo "🚀 DockerfileベースのDevContainer環境を再構築します..."

# 1. ディレクトリ構造の作成
mkdir -p .devcontainer
mkdir -p apps/api/src/routes
mkdir -p apps/web/src/components
mkdir -p packages/core/src/auth
mkdir -p packages/core/src/db
mkdir -p packages/core/src/registry
mkdir -p packages/plugins/auth-local/src
mkdir -p packages/plugins/auth-ad/src
mkdir -p packages/features/sample/src

# 2. DevContainer 設定
cat << 'EOF' > .devcontainer/devcontainer.json
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
EOF

# 3. .devcontainer/Dockerfile の作成
cat << 'EOF' > .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>
EOF

# 4. docker-compose.yml (image 指定を build 指定へ変更)
cat << 'EOF' > .devcontainer/docker-compose.yml
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
EOF

# 5. ルート package.json
cat << 'EOF' > package.json
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
    "dev": "concurrently \"npm run dev:api\" \"npm run dev:web\"",
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
EOF

# 6. TS & Vitest 設定
cat << 'EOF' > tsconfig.json
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
EOF

cat << 'EOF' > vitest.config.ts
import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    globals: true,
    environment: 'node',
  },
});
EOF

# 7. コアパッケージ (packages/core)
cat << 'EOF' > packages/core/package.json
{
  "name": "@app/core",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "dependencies": {
    "@prisma/client": "^5.9.1",
    "glob": "^10.3.10",
    "hono": "^4.0.0"
  },
  "devDependencies": {
    "prisma": "^5.9.1"
  }
}
EOF

cat << 'EOF' > packages/core/src/index.ts
export * from './auth/auth-registry.ts';
export * from './registry/hono-auto-loader.ts';
export * from './db/client.ts';
EOF

cat << 'EOF' > packages/core/src/auth/auth-registry.ts
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
EOF

cat << 'EOF' > packages/core/src/registry/hono-auto-loader.ts
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
EOF

cat << 'EOF' > packages/core/src/db/client.ts
import { PrismaClient } from '@prisma/client';

export const db = new PrismaClient();
EOF

# 8. プラグイン (packages/plugins)
cat << 'EOF' > packages/plugins/auth-local/package.json
{
  "name": "@app/plugins-auth-local",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF

cat << 'EOF' > packages/plugins/auth-local/src/index.ts
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
EOF

cat << 'EOF' > packages/plugins/auth-ad/package.json
{
  "name": "@app/plugins-auth-ad",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF

cat << 'EOF' > packages/plugins/auth-ad/src/index.ts
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
EOF

# 9. サンプル機能 & テスト
cat << 'EOF' > packages/features/sample/package.json
{
  "name": "@app/features-sample",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF

cat << 'EOF' > packages/features/sample/src/index.ts
import { Hono } from 'hono';

export default function createSampleFeature() {
  const app = new Hono();

  app.get('/sample', (c) => {
    return c.json({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });

  return app;
}
EOF

cat << 'EOF' > packages/features/sample/src/index.test.ts
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
EOF

# 10. API アプリ (apps/api)
cat << 'EOF' > apps/api/package.json
{
  "name": "@app/api",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
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
EOF

cat << 'EOF' > apps/api/src/routes/auth.ts
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
EOF

cat << 'EOF' > apps/api/src/index.ts
import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { loadFeatureModules } from '@app/core/registry/hono-auto-loader.ts';
import { AuthRegistry } from '@app/core/auth/auth-registry.ts';
import { LocalAuthPlugin } from '@app/plugins/auth-local/src/index.ts';
import { ActiveDirectoryAuthPlugin } from '@app/plugins/auth-ad/src/index.ts';
import authRouter from './routes/auth.ts';

AuthRegistry.register(new LocalAuthPlugin());
AuthRegistry.register(new ActiveDirectoryAuthPlugin());

const app = new Hono();

app.route('/api/auth', authRouter);
await loadFeatureModules(app, 'packages/features/*/src/index.ts');

const port = 3001;
console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);

serve({
  fetch: app.fetch,
  port,
  hostname: '0.0.0.0'
});

export default app;
EOF

# 11. Web アプリ (apps/web)
cat << 'EOF' > apps/web/package.json
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
EOF

cat << 'EOF' > apps/web/tsconfig.json
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
EOF

cat << 'EOF' > apps/web/vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [react(), tsconfigPaths()],
  server: {
    host: '0.0.0.0',
    port: 3000,
    proxy: {
      '/api': 'http://127.0.0.1:3001',
      '/sample': 'http://127.0.0.1:3001',
    },
  },
});
EOF

cat << 'EOF' > apps/web/index.html
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
EOF

# 11. Web アプリ (apps/web)

# (前略)

cat << 'EOF' > apps/web/src/main.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

cat << 'EOF' > apps/web/src/components/LoginForm.tsx
import React, { useState } from 'react';

export const LoginForm: React.FC = () => {
  // ... (省略)
};
EOF

cat << 'EOF' > apps/web/src/App.tsx
import React from 'react';
import { LoginForm } from './components/LoginForm.tsx';

export default function App() {
  return (
    <div>
      <h1>DevContainer + Docker Compose モノレポ アプリ</h1>
      <LoginForm />
    </div>
  );
}
EOF

echo "✨ セットアップ完了！"
