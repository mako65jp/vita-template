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
cat << 'EOF_1785916429_877' > "package.json"
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
EOF_1785916429_877

echo "作成: .gitignore"
cat << 'EOF_1785916429_31390' > ".gitignore"
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
EOF_1785916429_31390

echo "作成: plan.md"
cat << 'EOF_1785916429_24359' > "plan.md"
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
EOF_1785916429_24359

mkdir -p ".devcontainer/scripts"
echo "作成: .devcontainer/scripts/init-test-db.sh"
cat << 'EOF_1785916429_8060' > ".devcontainer/scripts/init-test-db.sh"
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE $POSTGRES_DB_TEST;
EOSQL
EOF_1785916429_8060

mkdir -p ".devcontainer"
echo "作成: .devcontainer/Dockerfile"
cat << 'EOF_1785916429_26913' > ".devcontainer/Dockerfile"
FROM mcr.microsoft.com/devcontainers/typescript-node:1-20-bookworm

# パッケージの追加インストールなどが必要な場合はここに記述可能
# RUN apt-get update && apt-get install -y <package_name>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo "Asia/Tokyo" > /etc/timezone
    
EOF_1785916429_26913

mkdir -p ".devcontainer"
echo "作成: .devcontainer/devcontainer.json"
cat << 'EOF_1785916429_22669' > ".devcontainer/devcontainer.json"
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
EOF_1785916429_22669

mkdir -p ".devcontainer"
echo "作成: .devcontainer/docker-compose.yml"
cat << 'EOF_1785916429_18542' > ".devcontainer/docker-compose.yml"


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
EOF_1785916429_18542

echo "作成: tsconfig.json"
cat << 'EOF_1785916429_25972' > "tsconfig.json"
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
EOF_1785916429_25972

mkdir -p "coverage"
echo "作成: coverage/coverage-final.json"
cat << 'EOF_1785916429_4295' > "coverage/coverage-final.json"
{"/workspace/apps/api/src/env.ts": {"path":"/workspace/apps/api/src/env.ts","statementMap":{"0":{"start":{"line":3,"column":18},"end":{"line":6,"column":null}},"1":{"start":{"line":9,"column":19},"end":{"line":9,"column":null}},"2":{"start":{"line":10,"column":4},"end":{"line":12,"column":null}},"3":{"start":{"line":11,"column":8},"end":{"line":11,"column":null}},"4":{"start":{"line":13,"column":4},"end":{"line":13,"column":null}}},"fnMap":{"0":{"name":"validateEnv","decl":{"start":{"line":8,"column":16},"end":{"line":8,"column":28}},"loc":{"start":{"line":8,"column":83},"end":{"line":14,"column":null}},"line":8}},"branchMap":{"0":{"loc":{"start":{"line":8,"column":28},"end":{"line":8,"column":83}},"type":"default-arg","locations":[{"start":{"line":8,"column":70},"end":{"line":8,"column":83}}],"line":8},"1":{"loc":{"start":{"line":10,"column":4},"end":{"line":12,"column":null}},"type":"if","locations":[{"start":{"line":10,"column":4},"end":{"line":12,"column":null}},{"start":{},"end":{}}],"line":10}},"s":{"0":1,"1":2,"2":2,"3":1,"4":1},"f":{"0":2},"b":{"0":[2],"1":[1,1]},"meta":{"lastBranch":2,"lastFunction":1,"lastStatement":5,"seen":{"s:3:18:6:Infinity":0,"f:8:16:8:28":0,"b:8:70:8:83":0,"s:9:19:9:Infinity":1,"b:10:4:12:Infinity:undefined:undefined:undefined:undefined":1,"s:10:4:12:Infinity":2,"s:11:8:11:Infinity":3,"s:13:4:13:Infinity":4},"fnNames":{}}}
,"/workspace/apps/api/src/index.ts": {"path":"/workspace/apps/api/src/index.ts","statementMap":{"0":{"start":{"line":14,"column":12},"end":{"line":14,"column":24}},"1":{"start":{"line":17,"column":0},"end":{"line":19,"column":null}},"2":{"start":{"line":18,"column":4},"end":{"line":18,"column":null}},"3":{"start":{"line":22,"column":0},"end":{"line":22,"column":null}},"4":{"start":{"line":23,"column":0},"end":{"line":23,"column":null}},"5":{"start":{"line":25,"column":12},"end":{"line":25,"column":null}},"6":{"start":{"line":30,"column":0},"end":{"line":34,"column":null}},"7":{"start":{"line":31,"column":4},"end":{"line":33,"column":null}},"8":{"start":{"line":32,"column":8},"end":{"line":32,"column":null}},"9":{"start":{"line":40,"column":0},"end":{"line":40,"column":null}},"10":{"start":{"line":42,"column":0},"end":{"line":42,"column":null}},"11":{"start":{"line":47,"column":0},"end":{"line":70,"column":null}},"12":{"start":{"line":48,"column":25},"end":{"line":51,"column":null}},"13":{"start":{"line":53,"column":4},"end":{"line":69,"column":null}},"14":{"start":{"line":56,"column":12},"end":{"line":64,"column":null}},"15":{"start":{"line":58,"column":38},"end":{"line":61,"column":null}},"16":{"start":{"line":58,"column":74},"end":{"line":61,"column":18}},"17":{"start":{"line":63,"column":16},"end":{"line":63,"column":null}},"18":{"start":{"line":67,"column":12},"end":{"line":67,"column":null}},"19":{"start":{"line":75,"column":0},"end":{"line":84,"column":null}},"20":{"start":{"line":76,"column":36},"end":{"line":82,"column":null}},"21":{"start":{"line":83,"column":4},"end":{"line":83,"column":null}},"22":{"start":{"line":89,"column":0},"end":{"line":122,"column":null}},"23":{"start":{"line":90,"column":4},"end":{"line":92,"column":null}},"24":{"start":{"line":91,"column":8},"end":{"line":91,"column":null}},"25":{"start":{"line":94,"column":17},"end":{"line":94,"column":null}},"26":{"start":{"line":95,"column":15},"end":{"line":95,"column":null}},"27":{"start":{"line":96,"column":16},"end":{"line":96,"column":null}},"28":{"start":{"line":97,"column":17},"end":{"line":97,"column":null}},"29":{"start":{"line":98,"column":29},"end":{"line":98,"column":null}},"30":{"start":{"line":100,"column":4},"end":{"line":110,"column":null}},"31":{"start":{"line":101,"column":8},"end":{"line":101,"column":null}},"32":{"start":{"line":102,"column":8},"end":{"line":102,"column":null}},"33":{"start":{"line":103,"column":8},"end":{"line":103,"column":null}},"34":{"start":{"line":104,"column":8},"end":{"line":104,"column":null}},"35":{"start":{"line":107,"column":8},"end":{"line":109,"column":null}},"36":{"start":{"line":108,"column":12},"end":{"line":108,"column":null}},"37":{"start":{"line":112,"column":36},"end":{"line":119,"column":null}},"38":{"start":{"line":121,"column":4},"end":{"line":121,"column":null}},"39":{"start":{"line":127,"column":13},"end":{"line":127,"column":null}},"40":{"start":{"line":130,"column":0},"end":{"line":137,"column":null}},"41":{"start":{"line":131,"column":4},"end":{"line":131,"column":null}},"42":{"start":{"line":132,"column":4},"end":{"line":136,"column":null}}},"fnMap":{"0":{"name":"(anonymous_0)","decl":{"start":{"line":31,"column":12},"end":{"line":31,"column":33}},"loc":{"start":{"line":31,"column":33},"end":{"line":33,"column":5}},"line":31},"1":{"name":"(anonymous_1)","decl":{"start":{"line":55,"column":27},"end":{"line":55,"column":42}},"loc":{"start":{"line":55,"column":56},"end":{"line":65,"column":9}},"line":55},"2":{"name":"(anonymous_2)","decl":{"start":{"line":58,"column":58},"end":{"line":58,"column":63}},"loc":{"start":{"line":58,"column":74},"end":{"line":61,"column":18}},"line":58},"3":{"name":"(anonymous_3)","decl":{"start":{"line":65,"column":9},"end":{"line":65,"column":null}},"loc":{"start":{"line":66,"column":15},"end":{"line":68,"column":null}},"line":66},"4":{"name":"(anonymous_4)","decl":{"start":{"line":75,"column":4},"end":{"line":75,"column":14}},"loc":{"start":{"line":75,"column":20},"end":{"line":84,"column":1}},"line":75},"5":{"name":"(anonymous_5)","decl":{"start":{"line":89,"column":4},"end":{"line":89,"column":13}},"loc":{"start":{"line":89,"column":24},"end":{"line":122,"column":1}},"line":89}},"branchMap":{"0":{"loc":{"start":{"line":17,"column":0},"end":{"line":19,"column":null}},"type":"if","locations":[{"start":{"line":17,"column":0},"end":{"line":19,"column":null}},{"start":{},"end":{}}],"line":17},"1":{"loc":{"start":{"line":30,"column":0},"end":{"line":34,"column":null}},"type":"if","locations":[{"start":{"line":30,"column":0},"end":{"line":34,"column":null}},{"start":{},"end":{}}],"line":30},"2":{"loc":{"start":{"line":47,"column":0},"end":{"line":70,"column":null}},"type":"if","locations":[{"start":{"line":47,"column":0},"end":{"line":70,"column":null}},{"start":{},"end":{}}],"line":47},"3":{"loc":{"start":{"line":56,"column":12},"end":{"line":64,"column":null}},"type":"if","locations":[{"start":{"line":56,"column":12},"end":{"line":64,"column":null}},{"start":{},"end":{}}],"line":56},"4":{"loc":{"start":{"line":90,"column":4},"end":{"line":92,"column":null}},"type":"if","locations":[{"start":{"line":90,"column":4},"end":{"line":92,"column":null}},{"start":{},"end":{}}],"line":90},"5":{"loc":{"start":{"line":100,"column":4},"end":{"line":110,"column":null}},"type":"if","locations":[{"start":{"line":100,"column":4},"end":{"line":110,"column":null}},{"start":{},"end":{}}],"line":100},"6":{"loc":{"start":{"line":107,"column":8},"end":{"line":109,"column":null}},"type":"if","locations":[{"start":{"line":107,"column":8},"end":{"line":109,"column":null}},{"start":{},"end":{}}],"line":107},"7":{"loc":{"start":{"line":118,"column":12},"end":{"line":118,"column":null}},"type":"binary-expr","locations":[{"start":{"line":118,"column":12},"end":{"line":118,"column":29}},{"start":{"line":118,"column":29},"end":{"line":118,"column":null}}],"line":118},"8":{"loc":{"start":{"line":130,"column":0},"end":{"line":137,"column":null}},"type":"if","locations":[{"start":{"line":130,"column":0},"end":{"line":137,"column":null}},{"start":{},"end":{}}],"line":130}},"s":{"0":1,"1":1,"2":0,"3":1,"4":1,"5":1,"6":1,"7":1,"8":1,"9":1,"10":1,"11":1,"12":1,"13":1,"14":1,"15":1,"16":2,"17":1,"18":0,"19":1,"20":1,"21":1,"22":1,"23":2,"24":0,"25":2,"26":2,"27":2,"28":2,"29":2,"30":2,"31":1,"32":1,"33":1,"34":1,"35":1,"36":1,"37":2,"38":2,"39":1,"40":1,"41":0,"42":0},"f":{"0":1,"1":1,"2":2,"3":0,"4":1,"5":2},"b":{"0":[0,1],"1":[1,0],"2":[1,0],"3":[1,0],"4":[0,2],"5":[1,1],"6":[1,0],"7":[2,1],"8":[0,1]},"meta":{"lastBranch":9,"lastFunction":6,"lastStatement":43,"seen":{"s:14:12:14:24":0,"b:17:0:19:Infinity:undefined:undefined:undefined:undefined":0,"s:17:0:19:Infinity":1,"s:18:4:18:Infinity":2,"s:22:0:22:Infinity":3,"s:23:0:23:Infinity":4,"s:25:12:25:Infinity":5,"b:30:0:34:Infinity:undefined:undefined:undefined:undefined":1,"s:30:0:34:Infinity":6,"s:31:4:33:Infinity":7,"f:31:12:31:33":0,"s:32:8:32:Infinity":8,"s:40:0:40:Infinity":9,"s:42:0:42:Infinity":10,"b:47:0:70:Infinity:undefined:undefined:undefined:undefined":2,"s:47:0:70:Infinity":11,"s:48:25:51:Infinity":12,"s:53:4:69:Infinity":13,"f:55:27:55:42":1,"b:56:12:64:Infinity:undefined:undefined:undefined:undefined":3,"s:56:12:64:Infinity":14,"s:58:38:61:Infinity":15,"f:58:58:58:63":2,"s:58:74:61:18":16,"s:63:16:63:Infinity":17,"f:65:9:65:Infinity":3,"s:67:12:67:Infinity":18,"s:75:0:84:Infinity":19,"f:75:4:75:14":4,"s:76:36:82:Infinity":20,"s:83:4:83:Infinity":21,"s:89:0:122:Infinity":22,"f:89:4:89:13":5,"b:90:4:92:Infinity:undefined:undefined:undefined:undefined":4,"s:90:4:92:Infinity":23,"s:91:8:91:Infinity":24,"s:94:17:94:Infinity":25,"s:95:15:95:Infinity":26,"s:96:16:96:Infinity":27,"s:97:17:97:Infinity":28,"s:98:29:98:Infinity":29,"b:100:4:110:Infinity:undefined:undefined:undefined:undefined":5,"s:100:4:110:Infinity":30,"s:101:8:101:Infinity":31,"s:102:8:102:Infinity":32,"s:103:8:103:Infinity":33,"s:104:8:104:Infinity":34,"b:107:8:109:Infinity:undefined:undefined:undefined:undefined":6,"s:107:8:109:Infinity":35,"s:108:12:108:Infinity":36,"s:112:36:119:Infinity":37,"b:118:12:118:29:118:29:118:Infinity":7,"s:121:4:121:Infinity":38,"s:127:13:127:Infinity":39,"b:130:0:137:Infinity:undefined:undefined:undefined:undefined":8,"s:130:0:137:Infinity":40,"s:131:4:131:Infinity":41,"s:132:4:136:Infinity":42},"fnNames":{}}}
,"/workspace/apps/api/src/middlewares/auth-middleware.ts": {"path":"/workspace/apps/api/src/middlewares/auth-middleware.ts","statementMap":{"0":{"start":{"line":16,"column":4},"end":{"line":35,"column":null}},"1":{"start":{"line":17,"column":27},"end":{"line":17,"column":null}},"2":{"start":{"line":20,"column":8},"end":{"line":22,"column":null}},"3":{"start":{"line":21,"column":12},"end":{"line":21,"column":null}},"4":{"start":{"line":25,"column":22},"end":{"line":25,"column":null}},"5":{"start":{"line":26,"column":24},"end":{"line":26,"column":null}},"6":{"start":{"line":28,"column":8},"end":{"line":30,"column":null}},"7":{"start":{"line":29,"column":12},"end":{"line":29,"column":null}},"8":{"start":{"line":33,"column":8},"end":{"line":33,"column":null}},"9":{"start":{"line":34,"column":8},"end":{"line":34,"column":null}}},"fnMap":{"0":{"name":"authMiddleware","decl":{"start":{"line":15,"column":16},"end":{"line":15,"column":31}},"loc":{"start":{"line":15,"column":66},"end":{"line":36,"column":null}},"line":15},"1":{"name":"(anonymous_1)","decl":{"start":{"line":16,"column":11},"end":{"line":16,"column":18}},"loc":{"start":{"line":16,"column":30},"end":{"line":35,"column":null}},"line":16}},"branchMap":{"0":{"loc":{"start":{"line":20,"column":8},"end":{"line":22,"column":null}},"type":"if","locations":[{"start":{"line":20,"column":8},"end":{"line":22,"column":null}},{"start":{},"end":{}}],"line":20},"1":{"loc":{"start":{"line":20,"column":12},"end":{"line":20,"column":62}},"type":"binary-expr","locations":[{"start":{"line":20,"column":12},"end":{"line":20,"column":27}},{"start":{"line":20,"column":27},"end":{"line":20,"column":62}}],"line":20},"2":{"loc":{"start":{"line":28,"column":8},"end":{"line":30,"column":null}},"type":"if","locations":[{"start":{"line":28,"column":8},"end":{"line":30,"column":null}},{"start":{},"end":{}}],"line":28}},"s":{"0":7,"1":4,"2":4,"3":1,"4":3,"5":3,"6":3,"7":1,"8":2,"9":2},"f":{"0":7,"1":4},"b":{"0":[1,3],"1":[4,3],"2":[1,2]},"meta":{"lastBranch":3,"lastFunction":2,"lastStatement":10,"seen":{"f:15:16:15:31":0,"s:16:4:35:Infinity":0,"f:16:11:16:18":1,"s:17:27:17:Infinity":1,"b:20:8:22:Infinity:undefined:undefined:undefined:undefined":0,"s:20:8:22:Infinity":2,"b:20:12:20:27:20:27:20:62":1,"s:21:12:21:Infinity":3,"s:25:22:25:Infinity":4,"s:26:24:26:Infinity":5,"b:28:8:30:Infinity:undefined:undefined:undefined:undefined":2,"s:28:8:30:Infinity":6,"s:29:12:29:Infinity":7,"s:33:8:33:Infinity":8,"s:34:8:34:Infinity":9},"fnNames":{}}}
,"/workspace/apps/api/src/routes/auth.ts": {"path":"/workspace/apps/api/src/routes/auth.ts","statementMap":{"0":{"start":{"line":9,"column":20},"end":{"line":12,"column":null}},"1":{"start":{"line":18,"column":16},"end":{"line":18,"column":null}},"2":{"start":{"line":23,"column":4},"end":{"line":67,"column":null}},"3":{"start":{"line":24,"column":21},"end":{"line":24,"column":null}},"4":{"start":{"line":25,"column":23},"end":{"line":25,"column":null}},"5":{"start":{"line":27,"column":8},"end":{"line":29,"column":null}},"6":{"start":{"line":28,"column":12},"end":{"line":28,"column":null}},"7":{"start":{"line":31,"column":36},"end":{"line":31,"column":null}},"8":{"start":{"line":34,"column":21},"end":{"line":36,"column":null}},"9":{"start":{"line":38,"column":8},"end":{"line":41,"column":null}},"10":{"start":{"line":40,"column":12},"end":{"line":40,"column":null}},"11":{"start":{"line":44,"column":32},"end":{"line":44,"column":null}},"12":{"start":{"line":45,"column":8},"end":{"line":47,"column":null}},"13":{"start":{"line":46,"column":12},"end":{"line":46,"column":null}},"14":{"start":{"line":50,"column":22},"end":{"line":57,"column":null}},"15":{"start":{"line":59,"column":8},"end":{"line":66,"column":null}},"16":{"start":{"line":72,"column":4},"end":{"line":82,"column":null}},"17":{"start":{"line":73,"column":28},"end":{"line":73,"column":null}},"18":{"start":{"line":75,"column":8},"end":{"line":81,"column":null}},"19":{"start":{"line":84,"column":4},"end":{"line":84,"column":null}}},"fnMap":{"0":{"name":"authRouter","decl":{"start":{"line":17,"column":16},"end":{"line":17,"column":27}},"loc":{"start":{"line":17,"column":46},"end":{"line":85,"column":null}},"line":17},"1":{"name":"(anonymous_1)","decl":{"start":{"line":23,"column":23},"end":{"line":23,"column":30}},"loc":{"start":{"line":23,"column":36},"end":{"line":67,"column":5}},"line":23},"2":{"name":"(anonymous_2)","decl":{"start":{"line":72,"column":46},"end":{"line":72,"column":53}},"loc":{"start":{"line":72,"column":59},"end":{"line":82,"column":5}},"line":72}},"branchMap":{"0":{"loc":{"start":{"line":27,"column":8},"end":{"line":29,"column":null}},"type":"if","locations":[{"start":{"line":27,"column":8},"end":{"line":29,"column":null}},{"start":{},"end":{}}],"line":27},"1":{"loc":{"start":{"line":38,"column":8},"end":{"line":41,"column":null}},"type":"if","locations":[{"start":{"line":38,"column":8},"end":{"line":41,"column":null}},{"start":{},"end":{}}],"line":38},"2":{"loc":{"start":{"line":45,"column":8},"end":{"line":47,"column":null}},"type":"if","locations":[{"start":{"line":45,"column":8},"end":{"line":47,"column":null}},{"start":{},"end":{}}],"line":45}},"s":{"0":2,"1":4,"2":4,"3":3,"4":3,"5":3,"6":0,"7":3,"8":3,"9":3,"10":0,"11":3,"12":3,"13":1,"14":2,"15":2,"16":4,"17":1,"18":1,"19":4},"f":{"0":4,"1":3,"2":1},"b":{"0":[0,3],"1":[0,3],"2":[1,2]},"meta":{"lastBranch":3,"lastFunction":3,"lastStatement":20,"seen":{"s:9:20:12:Infinity":0,"f:17:16:17:27":0,"s:18:16:18:Infinity":1,"s:23:4:67:Infinity":2,"f:23:23:23:30":1,"s:24:21:24:Infinity":3,"s:25:23:25:Infinity":4,"b:27:8:29:Infinity:undefined:undefined:undefined:undefined":0,"s:27:8:29:Infinity":5,"s:28:12:28:Infinity":6,"s:31:36:31:Infinity":7,"s:34:21:36:Infinity":8,"b:38:8:41:Infinity:undefined:undefined:undefined:undefined":1,"s:38:8:41:Infinity":9,"s:40:12:40:Infinity":10,"s:44:32:44:Infinity":11,"b:45:8:47:Infinity:undefined:undefined:undefined:undefined":2,"s:45:8:47:Infinity":12,"s:46:12:46:Infinity":13,"s:50:22:57:Infinity":14,"s:59:8:66:Infinity":15,"s:72:4:82:Infinity":16,"f:72:46:72:53":2,"s:73:28:73:Infinity":17,"s:75:8:81:Infinity":18,"s:84:4:84:Infinity":19},"fnNames":{}}}
,"/workspace/apps/web/src/App.tsx": {"path":"/workspace/apps/web/src/App.tsx","statementMap":{"0":{"start":{"line":5,"column":6},"end":{"line":35,"column":null}},"1":{"start":{"line":6,"column":55},"end":{"line":6,"column":63}},"2":{"start":{"line":8,"column":2},"end":{"line":10,"column":null}},"3":{"start":{"line":9,"column":4},"end":{"line":9,"column":null}},"4":{"start":{"line":12,"column":2},"end":{"line":33,"column":null}},"5":{"start":{"line":38,"column":2},"end":{"line":41,"column":null}}},"fnMap":{"0":{"name":"(anonymous_0)","decl":{"start":{"line":5,"column":6},"end":{"line":5,"column":36}},"loc":{"start":{"line":5,"column":36},"end":{"line":35,"column":null}},"line":5},"1":{"name":"App","decl":{"start":{"line":37,"column":16},"end":{"line":37,"column":22}},"loc":{"start":{"line":37,"column":22},"end":{"line":43,"column":null}},"line":37}},"branchMap":{"0":{"loc":{"start":{"line":8,"column":2},"end":{"line":10,"column":null}},"type":"if","locations":[{"start":{"line":8,"column":2},"end":{"line":10,"column":null}},{"start":{},"end":{}}],"line":8},"1":{"loc":{"start":{"line":16,"column":7},"end":{"line":33,"column":null}},"type":"cond-expr","locations":[{"start":{"line":17,"column":8},"end":{"line":29,"column":9}},{"start":{"line":29,"column":8},"end":{"line":33,"column":null}}],"line":16},"2":{"loc":{"start":{"line":16,"column":7},"end":{"line":16,"column":null}},"type":"binary-expr","locations":[{"start":{"line":16,"column":7},"end":{"line":16,"column":26}},{"start":{"line":16,"column":26},"end":{"line":16,"column":null}}],"line":16},"3":{"loc":{"start":{"line":18,"column":20},"end":{"line":18,"column":44}},"type":"binary-expr","locations":[{"start":{"line":18,"column":20},"end":{"line":18,"column":33}},{"start":{"line":18,"column":33},"end":{"line":18,"column":44}}],"line":18}},"s":{"0":0,"1":0,"2":0,"3":0,"4":0,"5":0},"f":{"0":0,"1":0},"b":{"0":[0,0],"1":[0,0],"2":[0,0],"3":[0,0]},"meta":{"lastBranch":4,"lastFunction":2,"lastStatement":6,"seen":{"s:5:6:35:Infinity":0,"f:5:6:5:36":0,"s:6:55:6:63":1,"b:8:2:10:Infinity:undefined:undefined:undefined:undefined":0,"s:8:2:10:Infinity":2,"s:9:4:9:Infinity":3,"s:12:2:33:Infinity":4,"b:17:8:29:9:29:8:33:Infinity":1,"b:16:7:16:26:16:26:16:Infinity":2,"b:18:20:18:33:18:33:18:44":3,"f:37:16:37:22":1,"s:38:2:41:Infinity":5},"fnNames":{}}}
,"/workspace/apps/web/src/env.ts": {"path":"/workspace/apps/web/src/env.ts","statementMap":{"0":{"start":{"line":4,"column":30},"end":{"line":8,"column":null}}},"fnMap":{},"branchMap":{},"s":{"0":0},"f":{},"b":{},"meta":{"lastBranch":0,"lastFunction":0,"lastStatement":1,"seen":{"s:4:30:8:Infinity":0},"fnNames":{}}}
,"/workspace/apps/web/src/main.tsx": {"path":"/workspace/apps/web/src/main.tsx","statementMap":{"0":{"start":{"line":5,"column":0},"end":{"line":9,"column":null}}},"fnMap":{},"branchMap":{},"s":{"0":0},"f":{},"b":{},"meta":{"lastBranch":0,"lastFunction":0,"lastStatement":1,"seen":{"s:5:0:9:Infinity":0},"fnNames":{}}}
,"/workspace/apps/web/src/components/LoginForm.tsx": {"path":"/workspace/apps/web/src/components/LoginForm.tsx","statementMap":{"0":{"start":{"line":8,"column":13},"end":{"line":69,"column":null}},"1":{"start":{"line":9,"column":22},"end":{"line":9,"column":30}},"2":{"start":{"line":10,"column":30},"end":{"line":10,"column":null}},"3":{"start":{"line":11,"column":36},"end":{"line":11,"column":null}},"4":{"start":{"line":12,"column":30},"end":{"line":12,"column":null}},"5":{"start":{"line":13,"column":44},"end":{"line":13,"column":null}},"6":{"start":{"line":15,"column":25},"end":{"line":30,"column":null}},"7":{"start":{"line":16,"column":8},"end":{"line":16,"column":null}},"8":{"start":{"line":17,"column":8},"end":{"line":17,"column":null}},"9":{"start":{"line":18,"column":8},"end":{"line":18,"column":null}},"10":{"start":{"line":20,"column":8},"end":{"line":29,"column":null}},"11":{"start":{"line":21,"column":12},"end":{"line":21,"column":null}},"12":{"start":{"line":22,"column":12},"end":{"line":24,"column":null}},"13":{"start":{"line":23,"column":16},"end":{"line":23,"column":null}},"14":{"start":{"line":26,"column":12},"end":{"line":26,"column":null}},"15":{"start":{"line":28,"column":12},"end":{"line":28,"column":null}},"16":{"start":{"line":32,"column":4},"end":{"line":67,"column":null}},"17":{"start":{"line":46,"column":37},"end":{"line":46,"column":null}},"18":{"start":{"line":58,"column":37},"end":{"line":58,"column":null}}},"fnMap":{"0":{"name":"(anonymous_0)","decl":{"start":{"line":8,"column":13},"end":{"line":8,"column":52}},"loc":{"start":{"line":8,"column":70},"end":{"line":69,"column":null}},"line":8},"1":{"name":"(anonymous_1)","decl":{"start":{"line":15,"column":25},"end":{"line":15,"column":32}},"loc":{"start":{"line":15,"column":55},"end":{"line":30,"column":null}},"line":15},"2":{"name":"(anonymous_2)","decl":{"start":{"line":46,"column":20},"end":{"line":46,"column":31}},"loc":{"start":{"line":46,"column":37},"end":{"line":46,"column":null}},"line":46},"3":{"name":"(anonymous_3)","decl":{"start":{"line":58,"column":20},"end":{"line":58,"column":31}},"loc":{"start":{"line":58,"column":37},"end":{"line":58,"column":null}},"line":58}},"branchMap":{"0":{"loc":{"start":{"line":22,"column":12},"end":{"line":24,"column":null}},"type":"if","locations":[{"start":{"line":22,"column":12},"end":{"line":24,"column":null}},{"start":{},"end":{}}],"line":22},"1":{"loc":{"start":{"line":26,"column":21},"end":{"line":26,"column":50}},"type":"binary-expr","locations":[{"start":{"line":26,"column":21},"end":{"line":26,"column":36}},{"start":{"line":26,"column":36},"end":{"line":26,"column":50}}],"line":26},"2":{"loc":{"start":{"line":35,"column":13},"end":{"line":38,"column":null}},"type":"binary-expr","locations":[{"start":{"line":35,"column":13},"end":{"line":35,"column":null}},{"start":{"line":36,"column":16},"end":{"line":38,"column":null}}],"line":35},"3":{"loc":{"start":{"line":65,"column":17},"end":{"line":65,"column":null}},"type":"cond-expr","locations":[{"start":{"line":65,"column":32},"end":{"line":65,"column":43}},{"start":{"line":65,"column":43},"end":{"line":65,"column":null}}],"line":65}},"s":{"0":1,"1":11,"2":11,"3":11,"4":11,"5":11,"6":11,"7":2,"8":2,"9":2,"10":2,"11":2,"12":1,"13":1,"14":1,"15":2,"16":11,"17":2,"18":2},"f":{"0":11,"1":2,"2":2,"3":2},"b":{"0":[1,0],"1":[1,0],"2":[11,1],"3":[2,9]},"meta":{"lastBranch":4,"lastFunction":4,"lastStatement":19,"seen":{"s:8:13:69:Infinity":0,"f:8:13:8:52":0,"s:9:22:9:30":1,"s:10:30:10:Infinity":2,"s:11:36:11:Infinity":3,"s:12:30:12:Infinity":4,"s:13:44:13:Infinity":5,"s:15:25:30:Infinity":6,"f:15:25:15:32":1,"s:16:8:16:Infinity":7,"s:17:8:17:Infinity":8,"s:18:8:18:Infinity":9,"s:20:8:29:Infinity":10,"s:21:12:21:Infinity":11,"b:22:12:24:Infinity:undefined:undefined:undefined:undefined":0,"s:22:12:24:Infinity":12,"s:23:16:23:Infinity":13,"s:26:12:26:Infinity":14,"b:26:21:26:36:26:36:26:50":1,"s:28:12:28:Infinity":15,"s:32:4:67:Infinity":16,"b:35:13:35:Infinity:36:16:38:Infinity":2,"f:46:20:46:31":2,"s:46:37:46:Infinity":17,"f:58:20:58:31":3,"s:58:37:58:Infinity":18,"b:65:32:65:43:65:43:65:Infinity":3},"fnNames":{}}}
,"/workspace/apps/web/src/context/AuthContext.tsx": {"path":"/workspace/apps/web/src/context/AuthContext.tsx","statementMap":{"0":{"start":{"line":21,"column":27},"end":{"line":21,"column":null}},"1":{"start":{"line":23,"column":13},"end":{"line":108,"column":null}},"2":{"start":{"line":24,"column":28},"end":{"line":24,"column":null}},"3":{"start":{"line":25,"column":30},"end":{"line":25,"column":null}},"4":{"start":{"line":25,"column":60},"end":{"line":25,"column":89}},"5":{"start":{"line":26,"column":38},"end":{"line":26,"column":null}},"6":{"start":{"line":29,"column":4},"end":{"line":64,"column":null}},"7":{"start":{"line":30,"column":25},"end":{"line":61,"column":null}},"8":{"start":{"line":31,"column":32},"end":{"line":31,"column":null}},"9":{"start":{"line":32,"column":12},"end":{"line":35,"column":null}},"10":{"start":{"line":33,"column":16},"end":{"line":33,"column":null}},"11":{"start":{"line":34,"column":16},"end":{"line":34,"column":null}},"12":{"start":{"line":37,"column":12},"end":{"line":60,"column":null}},"13":{"start":{"line":38,"column":28},"end":{"line":42,"column":null}},"14":{"start":{"line":44,"column":16},"end":{"line":52,"column":null}},"15":{"start":{"line":45,"column":33},"end":{"line":45,"column":null}},"16":{"start":{"line":46,"column":20},"end":{"line":46,"column":null}},"17":{"start":{"line":47,"column":20},"end":{"line":47,"column":null}},"18":{"start":{"line":49,"column":20},"end":{"line":49,"column":null}},"19":{"start":{"line":50,"column":20},"end":{"line":50,"column":null}},"20":{"start":{"line":51,"column":20},"end":{"line":51,"column":null}},"21":{"start":{"line":54,"column":16},"end":{"line":54,"column":null}},"22":{"start":{"line":55,"column":16},"end":{"line":55,"column":null}},"23":{"start":{"line":56,"column":16},"end":{"line":56,"column":null}},"24":{"start":{"line":57,"column":16},"end":{"line":57,"column":null}},"25":{"start":{"line":59,"column":16},"end":{"line":59,"column":null}},"26":{"start":{"line":63,"column":8},"end":{"line":63,"column":null}},"27":{"start":{"line":67,"column":18},"end":{"line":85,"column":null}},"28":{"start":{"line":68,"column":20},"end":{"line":74,"column":null}},"29":{"start":{"line":76,"column":8},"end":{"line":79,"column":null}},"30":{"start":{"line":77,"column":30},"end":{"line":77,"column":null}},"31":{"start":{"line":77,"column":60},"end":{"line":77,"column":63}},"32":{"start":{"line":78,"column":12},"end":{"line":78,"column":null}},"33":{"start":{"line":81,"column":21},"end":{"line":81,"column":null}},"34":{"start":{"line":82,"column":8},"end":{"line":82,"column":null}},"35":{"start":{"line":83,"column":8},"end":{"line":83,"column":null}},"36":{"start":{"line":84,"column":8},"end":{"line":84,"column":null}},"37":{"start":{"line":88,"column":10},"end":{"line":92,"column":null}},"38":{"start":{"line":89,"column":8},"end":{"line":89,"column":null}},"39":{"start":{"line":90,"column":8},"end":{"line":90,"column":null}},"40":{"start":{"line":91,"column":8},"end":{"line":91,"column":null}},"41":{"start":{"line":94,"column":4},"end":{"line":106,"column":null}},"42":{"start":{"line":110,"column":13},"end":{"line":116,"column":null}},"43":{"start":{"line":111,"column":20},"end":{"line":111,"column":null}},"44":{"start":{"line":112,"column":4},"end":{"line":114,"column":null}},"45":{"start":{"line":113,"column":8},"end":{"line":113,"column":null}},"46":{"start":{"line":115,"column":4},"end":{"line":115,"column":null}}},"fnMap":{"0":{"name":"(anonymous_0)","decl":{"start":{"line":23,"column":13},"end":{"line":23,"column":70}},"loc":{"start":{"line":23,"column":87},"end":{"line":108,"column":null}},"line":23},"1":{"name":"(anonymous_1)","decl":{"start":{"line":25,"column":30},"end":{"line":25,"column":60}},"loc":{"start":{"line":25,"column":60},"end":{"line":25,"column":89}},"line":25},"2":{"name":"(anonymous_2)","decl":{"start":{"line":29,"column":4},"end":{"line":29,"column":20}},"loc":{"start":{"line":29,"column":20},"end":{"line":64,"column":7}},"line":29},"3":{"name":"(anonymous_3)","decl":{"start":{"line":30,"column":25},"end":{"line":30,"column":37}},"loc":{"start":{"line":30,"column":37},"end":{"line":61,"column":null}},"line":30},"4":{"name":"(anonymous_4)","decl":{"start":{"line":67,"column":18},"end":{"line":67,"column":25}},"loc":{"start":{"line":67,"column":61},"end":{"line":85,"column":null}},"line":67},"5":{"name":"(anonymous_5)","decl":{"start":{"line":77,"column":47},"end":{"line":77,"column":60}},"loc":{"start":{"line":77,"column":60},"end":{"line":77,"column":63}},"line":77},"6":{"name":"(anonymous_6)","decl":{"start":{"line":88,"column":10},"end":{"line":88,"column":25}},"loc":{"start":{"line":88,"column":25},"end":{"line":92,"column":null}},"line":88},"7":{"name":"(anonymous_7)","decl":{"start":{"line":110,"column":13},"end":{"line":110,"column":46}},"loc":{"start":{"line":110,"column":46},"end":{"line":116,"column":null}},"line":110}},"branchMap":{"0":{"loc":{"start":{"line":32,"column":12},"end":{"line":35,"column":null}},"type":"if","locations":[{"start":{"line":32,"column":12},"end":{"line":35,"column":null}},{"start":{},"end":{}}],"line":32},"1":{"loc":{"start":{"line":44,"column":16},"end":{"line":52,"column":null}},"type":"if","locations":[{"start":{"line":44,"column":16},"end":{"line":52,"column":null}},{"start":{"line":48,"column":23},"end":{"line":52,"column":null}}],"line":44},"2":{"loc":{"start":{"line":76,"column":8},"end":{"line":79,"column":null}},"type":"if","locations":[{"start":{"line":76,"column":8},"end":{"line":79,"column":null}},{"start":{},"end":{}}],"line":76},"3":{"loc":{"start":{"line":78,"column":28},"end":{"line":78,"column":62}},"type":"binary-expr","locations":[{"start":{"line":78,"column":28},"end":{"line":78,"column":48}},{"start":{"line":78,"column":48},"end":{"line":78,"column":62}}],"line":78},"4":{"loc":{"start":{"line":112,"column":4},"end":{"line":114,"column":null}},"type":"if","locations":[{"start":{"line":112,"column":4},"end":{"line":114,"column":null}},{"start":{},"end":{}}],"line":112}},"s":{"0":2,"1":2,"2":8,"3":8,"4":3,"5":8,"6":8,"7":3,"8":3,"9":3,"10":2,"11":2,"12":1,"13":1,"14":1,"15":1,"16":1,"17":1,"18":0,"19":0,"20":0,"21":0,"22":0,"23":0,"24":0,"25":1,"26":3,"27":8,"28":1,"29":1,"30":0,"31":0,"32":0,"33":1,"34":1,"35":1,"36":1,"37":8,"38":1,"39":1,"40":1,"41":8,"42":2,"43":19,"44":19,"45":0,"46":19},"f":{"0":8,"1":3,"2":3,"3":3,"4":1,"5":0,"6":1,"7":19},"b":{"0":[2,1],"1":[1,0],"2":[0,1],"3":[0,0],"4":[0,19]},"meta":{"lastBranch":5,"lastFunction":8,"lastStatement":47,"seen":{"s:21:27:21:Infinity":0,"s:23:13:108:Infinity":1,"f:23:13:23:70":0,"s:24:28:24:Infinity":2,"s:25:30:25:Infinity":3,"f:25:30:25:60":1,"s:25:60:25:89":4,"s:26:38:26:Infinity":5,"s:29:4:64:Infinity":6,"f:29:4:29:20":2,"s:30:25:61:Infinity":7,"f:30:25:30:37":3,"s:31:32:31:Infinity":8,"b:32:12:35:Infinity:undefined:undefined:undefined:undefined":0,"s:32:12:35:Infinity":9,"s:33:16:33:Infinity":10,"s:34:16:34:Infinity":11,"s:37:12:60:Infinity":12,"s:38:28:42:Infinity":13,"b:44:16:52:Infinity:48:23:52:Infinity":1,"s:44:16:52:Infinity":14,"s:45:33:45:Infinity":15,"s:46:20:46:Infinity":16,"s:47:20:47:Infinity":17,"s:49:20:49:Infinity":18,"s:50:20:50:Infinity":19,"s:51:20:51:Infinity":20,"s:54:16:54:Infinity":21,"s:55:16:55:Infinity":22,"s:56:16:56:Infinity":23,"s:57:16:57:Infinity":24,"s:59:16:59:Infinity":25,"s:63:8:63:Infinity":26,"s:67:18:85:Infinity":27,"f:67:18:67:25":4,"s:68:20:74:Infinity":28,"b:76:8:79:Infinity:undefined:undefined:undefined:undefined":2,"s:76:8:79:Infinity":29,"s:77:30:77:Infinity":30,"f:77:47:77:60":5,"s:77:60:77:63":31,"s:78:12:78:Infinity":32,"b:78:28:78:48:78:48:78:62":3,"s:81:21:81:Infinity":33,"s:82:8:82:Infinity":34,"s:83:8:83:Infinity":35,"s:84:8:84:Infinity":36,"s:88:10:92:Infinity":37,"f:88:10:88:25":6,"s:89:8:89:Infinity":38,"s:90:8:90:Infinity":39,"s:91:8:91:Infinity":40,"s:94:4:106:Infinity":41,"s:110:13:116:Infinity":42,"f:110:13:110:46":7,"s:111:20:111:Infinity":43,"b:112:4:114:Infinity:undefined:undefined:undefined:undefined":4,"s:112:4:114:Infinity":44,"s:113:8:113:Infinity":45,"s:115:4:115:Infinity":46},"fnNames":{}}}
,"/workspace/packages/core/drizzle-test.config.ts": {"path":"/workspace/packages/core/drizzle-test.config.ts","statementMap":{},"fnMap":{},"branchMap":{"0":{"loc":{"start":{"line":15,"column":13},"end":{"line":15,"column":null}},"type":"binary-expr","locations":[{"start":{"line":15,"column":13},"end":{"line":15,"column":46}},{"start":{"line":15,"column":46},"end":{"line":15,"column":null}}],"line":15}},"s":{},"f":{},"b":{"0":[0,0]},"meta":{"lastBranch":1,"lastFunction":0,"lastStatement":0,"seen":{"b:15:13:15:46:15:46:15:Infinity":0},"fnNames":{}}}
,"/workspace/packages/core/drizzle.config.ts": {"path":"/workspace/packages/core/drizzle.config.ts","statementMap":{},"fnMap":{},"branchMap":{"0":{"loc":{"start":{"line":15,"column":13},"end":{"line":15,"column":null}},"type":"binary-expr","locations":[{"start":{"line":15,"column":13},"end":{"line":15,"column":41}},{"start":{"line":15,"column":41},"end":{"line":15,"column":null}}],"line":15}},"s":{},"f":{},"b":{"0":[0,0]},"meta":{"lastBranch":1,"lastFunction":0,"lastStatement":0,"seen":{"b:15:13:15:41:15:41:15:Infinity":0},"fnNames":{}}}
,"/workspace/packages/core/src/index.ts": {"path":"/workspace/packages/core/src/index.ts","statementMap":{},"fnMap":{},"branchMap":{},"s":{},"f":{},"b":{},"meta":{"lastBranch":0,"lastFunction":0,"lastStatement":0,"seen":{},"fnNames":{}}}
,"/workspace/packages/core/src/seed-dev-user.ts": {"path":"/workspace/packages/core/src/seed-dev-user.ts","statementMap":{"0":{"start":{"line":7,"column":18},"end":{"line":7,"column":null}},"1":{"start":{"line":8,"column":21},"end":{"line":8,"column":null}},"2":{"start":{"line":11,"column":27},"end":{"line":11,"column":null}},"3":{"start":{"line":13,"column":4},"end":{"line":17,"column":null}},"4":{"start":{"line":19,"column":4},"end":{"line":19,"column":null}},"5":{"start":{"line":20,"column":4},"end":{"line":20,"column":null}},"6":{"start":{"line":23,"column":0},"end":{"line":26,"column":null}},"7":{"start":{"line":24,"column":4},"end":{"line":24,"column":null}},"8":{"start":{"line":25,"column":4},"end":{"line":25,"column":null}}},"fnMap":{"0":{"name":"main","decl":{"start":{"line":6,"column":15},"end":{"line":6,"column":22}},"loc":{"start":{"line":6,"column":22},"end":{"line":21,"column":null}},"line":6},"1":{"name":"(anonymous_1)","decl":{"start":{"line":23,"column":7},"end":{"line":23,"column":14}},"loc":{"start":{"line":23,"column":22},"end":{"line":26,"column":1}},"line":23}},"branchMap":{},"s":{"0":0,"1":0,"2":0,"3":0,"4":0,"5":0,"6":0,"7":0,"8":0},"f":{"0":0,"1":0},"b":{},"meta":{"lastBranch":0,"lastFunction":2,"lastStatement":9,"seen":{"f:6:15:6:22":0,"s:7:18:7:Infinity":0,"s:8:21:8:Infinity":1,"s:11:27:11:Infinity":2,"s:13:4:17:Infinity":3,"s:19:4:19:Infinity":4,"s:20:4:20:Infinity":5,"s:23:0:26:Infinity":6,"f:23:7:23:14":1,"s:24:4:24:Infinity":7,"s:25:4:25:Infinity":8},"fnNames":{}}}
,"/workspace/packages/core/src/auth/auth-registry.ts": {"path":"/workspace/packages/core/src/auth/auth-registry.ts","statementMap":{"0":{"start":{"line":7,"column":30},"end":{"line":7,"column":null}},"1":{"start":{"line":10,"column":4},"end":{"line":10,"column":null}},"2":{"start":{"line":11,"column":4},"end":{"line":11,"column":null}},"3":{"start":{"line":15,"column":19},"end":{"line":15,"column":null}},"4":{"start":{"line":16,"column":4},"end":{"line":18,"column":null}},"5":{"start":{"line":17,"column":6},"end":{"line":17,"column":null}},"6":{"start":{"line":19,"column":4},"end":{"line":19,"column":null}}},"fnMap":{"0":{"name":"register","decl":{"start":{"line":9,"column":9},"end":{"line":9,"column":18}},"loc":{"start":{"line":9,"column":38},"end":{"line":12,"column":null}},"line":9},"1":{"name":"authenticate","decl":{"start":{"line":14,"column":15},"end":{"line":14,"column":28}},"loc":{"start":{"line":14,"column":64},"end":{"line":20,"column":null}},"line":14}},"branchMap":{"0":{"loc":{"start":{"line":16,"column":4},"end":{"line":18,"column":null}},"type":"if","locations":[{"start":{"line":16,"column":4},"end":{"line":18,"column":null}},{"start":{},"end":{}}],"line":16}},"s":{"0":3,"1":2,"2":2,"3":0,"4":0,"5":0,"6":0},"f":{"0":3,"1":3},"b":{"0":[0,0]},"meta":{"lastBranch":1,"lastFunction":2,"lastStatement":7,"seen":{"s:7:30:7:Infinity":0,"f:9:9:9:18":0,"s:10:4:10:Infinity":1,"s:11:4:11:Infinity":2,"f:14:15:14:28":1,"s:15:19:15:Infinity":3,"b:16:4:18:Infinity:undefined:undefined:undefined:undefined":0,"s:16:4:18:Infinity":4,"s:17:6:17:Infinity":5,"s:19:4:19:Infinity":6},"fnNames":{}}}
,"/workspace/packages/core/src/config/env.ts": {"path":"/workspace/packages/core/src/config/env.ts","statementMap":{"0":{"start":{"line":6,"column":25},"end":{"line":14,"column":null}},"1":{"start":{"line":19,"column":19},"end":{"line":19,"column":null}},"2":{"start":{"line":21,"column":4},"end":{"line":25,"column":null}},"3":{"start":{"line":22,"column":32},"end":{"line":22,"column":null}},"4":{"start":{"line":23,"column":8},"end":{"line":23,"column":null}},"5":{"start":{"line":24,"column":8},"end":{"line":24,"column":null}},"6":{"start":{"line":27,"column":4},"end":{"line":27,"column":null}},"7":{"start":{"line":34,"column":22},"end":{"line":34,"column":null}},"8":{"start":{"line":36,"column":4},"end":{"line":41,"column":null}},"9":{"start":{"line":37,"column":8},"end":{"line":40,"column":null}},"10":{"start":{"line":43,"column":4},"end":{"line":43,"column":null}},"11":{"start":{"line":48,"column":24},"end":{"line":52,"column":null}},"12":{"start":{"line":58,"column":31},"end":{"line":62,"column":null}}},"fnMap":{"0":{"name":"validateEnv","decl":{"start":{"line":18,"column":16},"end":{"line":18,"column":28}},"loc":{"start":{"line":18,"column":94},"end":{"line":28,"column":null}},"line":18},"1":{"name":"formatEnvForLog","decl":{"start":{"line":33,"column":16},"end":{"line":33,"column":32}},"loc":{"start":{"line":33,"column":53},"end":{"line":44,"column":null}},"line":33}},"branchMap":{"0":{"loc":{"start":{"line":18,"column":28},"end":{"line":18,"column":94}},"type":"default-arg","locations":[{"start":{"line":18,"column":76},"end":{"line":18,"column":94}}],"line":18},"1":{"loc":{"start":{"line":21,"column":4},"end":{"line":25,"column":null}},"type":"if","locations":[{"start":{"line":21,"column":4},"end":{"line":25,"column":null}},{"start":{},"end":{}}],"line":21},"2":{"loc":{"start":{"line":36,"column":4},"end":{"line":41,"column":null}},"type":"if","locations":[{"start":{"line":36,"column":4},"end":{"line":41,"column":null}},{"start":{},"end":{}}],"line":36},"3":{"loc":{"start":{"line":48,"column":24},"end":{"line":52,"column":null}},"type":"cond-expr","locations":[{"start":{"line":49,"column":7},"end":{"line":49,"column":null}},{"start":{"line":49,"column":8},"end":{"line":52,"column":null}}],"line":48},"4":{"loc":{"start":{"line":49,"column":8},"end":{"line":52,"column":null}},"type":"cond-expr","locations":[{"start":{"line":51,"column":11},"end":{"line":51,"column":null}},{"start":{"line":52,"column":10},"end":{"line":52,"column":null}}],"line":49}},"s":{"0":5,"1":10,"2":10,"3":2,"4":2,"5":2,"6":8,"7":1,"8":1,"9":1,"10":1,"11":5,"12":5},"f":{"0":10,"1":1},"b":{"0":[10],"1":[2,8],"2":[1,0],"3":[0,5],"4":[5,0]},"meta":{"lastBranch":5,"lastFunction":2,"lastStatement":13,"seen":{"s:6:25:14:Infinity":0,"f:18:16:18:28":0,"b:18:76:18:94":0,"s:19:19:19:Infinity":1,"b:21:4:25:Infinity:undefined:undefined:undefined:undefined":1,"s:21:4:25:Infinity":2,"s:22:32:22:Infinity":3,"s:23:8:23:Infinity":4,"s:24:8:24:Infinity":5,"s:27:4:27:Infinity":6,"f:33:16:33:32":1,"s:34:22:34:Infinity":7,"b:36:4:41:Infinity:undefined:undefined:undefined:undefined":2,"s:36:4:41:Infinity":8,"s:37:8:40:Infinity":9,"s:43:4:43:Infinity":10,"s:48:24:52:Infinity":11,"b:49:7:49:Infinity:49:8:52:Infinity":3,"b:51:11:51:Infinity:52:10:52:Infinity":4,"s:58:31:62:Infinity":12},"fnNames":{}}}
,"/workspace/packages/core/src/db/index.ts": {"path":"/workspace/packages/core/src/db/index.ts","statementMap":{"0":{"start":{"line":6,"column":12},"end":{"line":6,"column":24}},"1":{"start":{"line":9,"column":20},"end":{"line":9,"column":null}},"2":{"start":{"line":10,"column":18},"end":{"line":10,"column":null}}},"fnMap":{},"branchMap":{},"s":{"0":5,"1":5,"2":5},"f":{},"b":{},"meta":{"lastBranch":0,"lastFunction":0,"lastStatement":3,"seen":{"s:6:12:6:24":0,"s:9:20:9:Infinity":1,"s:10:18:10:Infinity":2},"fnNames":{}}}
,"/workspace/packages/core/src/db/schema.ts": {"path":"/workspace/packages/core/src/db/schema.ts","statementMap":{"0":{"start":{"line":3,"column":21},"end":{"line":10,"column":null}}},"fnMap":{},"branchMap":{},"s":{"0":5},"f":{},"b":{},"meta":{"lastBranch":0,"lastFunction":0,"lastStatement":1,"seen":{"s:3:21:10:Infinity":0},"fnNames":{}}}
,"/workspace/packages/core/src/errors/index.ts": {"path":"/workspace/packages/core/src/errors/index.ts","statementMap":{"0":{"start":{"line":22,"column":8},"end":{"line":22,"column":null}},"1":{"start":{"line":17,"column":24},"end":{"line":17,"column":null}},"2":{"start":{"line":18,"column":24},"end":{"line":18,"column":null}},"3":{"start":{"line":19,"column":24},"end":{"line":19,"column":null}},"4":{"start":{"line":23,"column":8},"end":{"line":23,"column":null}},"5":{"start":{"line":29,"column":8},"end":{"line":29,"column":null}},"6":{"start":{"line":35,"column":8},"end":{"line":35,"column":null}},"7":{"start":{"line":44,"column":8},"end":{"line":44,"column":null}},"8":{"start":{"line":41,"column":24},"end":{"line":41,"column":null}},"9":{"start":{"line":50,"column":8},"end":{"line":50,"column":null}}},"fnMap":{"0":{"name":"constructor","decl":{"start":{"line":16,"column":4},"end":{"line":16,"column":null}},"loc":{"start":{"line":21,"column":6},"end":{"line":24,"column":null}},"line":21},"1":{"name":"constructor_2","decl":{"start":{"line":28,"column":4},"end":{"line":28,"column":16}},"loc":{"start":{"line":28,"column":66},"end":{"line":30,"column":null}},"line":28},"2":{"name":"constructor_3","decl":{"start":{"line":34,"column":4},"end":{"line":34,"column":16}},"loc":{"start":{"line":34,"column":58},"end":{"line":36,"column":null}},"line":34},"3":{"name":"constructor_4","decl":{"start":{"line":40,"column":4},"end":{"line":40,"column":null}},"loc":{"start":{"line":43,"column":6},"end":{"line":45,"column":null}},"line":43},"4":{"name":"constructor_5","decl":{"start":{"line":49,"column":4},"end":{"line":49,"column":16}},"loc":{"start":{"line":49,"column":72},"end":{"line":51,"column":null}},"line":49}},"branchMap":{"0":{"loc":{"start":{"line":28,"column":16},"end":{"line":28,"column":66}},"type":"default-arg","locations":[{"start":{"line":28,"column":26},"end":{"line":28,"column":66}}],"line":28},"1":{"loc":{"start":{"line":34,"column":16},"end":{"line":34,"column":58}},"type":"default-arg","locations":[{"start":{"line":34,"column":26},"end":{"line":34,"column":58}}],"line":34},"2":{"loc":{"start":{"line":42,"column":8},"end":{"line":42,"column":null}},"type":"default-arg","locations":[{"start":{"line":42,"column":18},"end":{"line":42,"column":null}}],"line":42},"3":{"loc":{"start":{"line":49,"column":16},"end":{"line":49,"column":72}},"type":"default-arg","locations":[{"start":{"line":49,"column":26},"end":{"line":49,"column":72}}],"line":49}},"s":{"0":4,"1":4,"2":4,"3":4,"4":4,"5":0,"6":0,"7":1,"8":1,"9":3},"f":{"0":4,"1":0,"2":0,"3":1,"4":3},"b":{"0":[0],"1":[0],"2":[1],"3":[3]},"meta":{"lastBranch":4,"lastFunction":5,"lastStatement":10,"seen":{"f:16:4:16:Infinity":0,"s:22:8:22:Infinity":0,"s:17:24:17:Infinity":1,"s:18:24:18:Infinity":2,"s:19:24:19:Infinity":3,"s:23:8:23:Infinity":4,"f:28:4:28:16":1,"b:28:26:28:66":0,"s:29:8:29:Infinity":5,"f:34:4:34:16":2,"b:34:26:34:58":1,"s:35:8:35:Infinity":6,"f:40:4:40:Infinity":3,"b:42:18:42:Infinity":2,"s:44:8:44:Infinity":7,"s:41:24:41:Infinity":8,"f:49:4:49:16":4,"b:49:26:49:72":3,"s:50:8:50:Infinity":9},"fnNames":{}}}
,"/workspace/packages/core/src/registry/hono-auto-loader.ts": {"path":"/workspace/packages/core/src/registry/hono-auto-loader.ts","statementMap":{"0":{"start":{"line":7,"column":16},"end":{"line":7,"column":null}},"1":{"start":{"line":8,"column":2},"end":{"line":21,"column":null}},"2":{"start":{"line":9,"column":25},"end":{"line":9,"column":null}},"3":{"start":{"line":12,"column":22},"end":{"line":12,"column":null}},"4":{"start":{"line":14,"column":19},"end":{"line":14,"column":null}},"5":{"start":{"line":16,"column":4},"end":{"line":20,"column":null}},"6":{"start":{"line":17,"column":20},"end":{"line":17,"column":null}},"7":{"start":{"line":18,"column":6},"end":{"line":18,"column":null}},"8":{"start":{"line":19,"column":6},"end":{"line":19,"column":null}}},"fnMap":{"0":{"name":"loadFeatureModules","decl":{"start":{"line":6,"column":22},"end":{"line":6,"column":41}},"loc":{"start":{"line":6,"column":69},"end":{"line":22,"column":null}},"line":6}},"branchMap":{"0":{"loc":{"start":{"line":16,"column":4},"end":{"line":20,"column":null}},"type":"if","locations":[{"start":{"line":16,"column":4},"end":{"line":20,"column":null}},{"start":{},"end":{}}],"line":16},"1":{"loc":{"start":{"line":16,"column":8},"end":{"line":16,"column":64}},"type":"binary-expr","locations":[{"start":{"line":16,"column":8},"end":{"line":16,"column":26}},{"start":{"line":16,"column":26},"end":{"line":16,"column":64}}],"line":16}},"s":{"0":1,"1":1,"2":1,"3":1,"4":1,"5":1,"6":1,"7":1,"8":1},"f":{"0":1},"b":{"0":[1,0],"1":[1,1]},"meta":{"lastBranch":2,"lastFunction":1,"lastStatement":9,"seen":{"f:6:22:6:41":0,"s:7:16:7:Infinity":0,"s:8:2:21:Infinity":1,"s:9:25:9:Infinity":2,"s:12:22:12:Infinity":3,"s:14:19:14:Infinity":4,"b:16:4:20:Infinity:undefined:undefined:undefined:undefined":0,"s:16:4:20:Infinity":5,"b:16:8:16:26:16:26:16:64":1,"s:17:20:17:Infinity":6,"s:18:6:18:Infinity":7,"s:19:6:19:Infinity":8},"fnNames":{}}}
,"/workspace/packages/core/src/test/global-setup.ts": {"path":"/workspace/packages/core/src/test/global-setup.ts","statementMap":{"0":{"start":{"line":6,"column":19},"end":{"line":6,"column":null}},"1":{"start":{"line":7,"column":18},"end":{"line":7,"column":null}},"2":{"start":{"line":10,"column":4},"end":{"line":10,"column":null}},"3":{"start":{"line":13,"column":27},"end":{"line":13,"column":null}},"4":{"start":{"line":15,"column":4},"end":{"line":24,"column":null}},"5":{"start":{"line":16,"column":8},"end":{"line":19,"column":null}},"6":{"start":{"line":20,"column":8},"end":{"line":20,"column":null}},"7":{"start":{"line":22,"column":8},"end":{"line":22,"column":null}},"8":{"start":{"line":23,"column":8},"end":{"line":23,"column":null}}},"fnMap":{"0":{"name":"setup","decl":{"start":{"line":9,"column":22},"end":{"line":9,"column":30}},"loc":{"start":{"line":9,"column":30},"end":{"line":25,"column":null}},"line":9}},"branchMap":{},"s":{"0":0,"1":0,"2":0,"3":0,"4":0,"5":0,"6":0,"7":0,"8":0},"f":{"0":0},"b":{},"meta":{"lastBranch":0,"lastFunction":1,"lastStatement":9,"seen":{"s:6:19:6:Infinity":0,"s:7:18:7:Infinity":1,"f:9:22:9:30":0,"s:10:4:10:Infinity":2,"s:13:27:13:Infinity":3,"s:15:4:24:Infinity":4,"s:16:8:19:Infinity":5,"s:20:8:20:Infinity":6,"s:22:8:22:Infinity":7,"s:23:8:23:Infinity":8},"fnNames":{}}}
,"/workspace/packages/features/sample/src/index.ts": {"path":"/workspace/packages/features/sample/src/index.ts","statementMap":{"0":{"start":{"line":4,"column":14},"end":{"line":4,"column":null}},"1":{"start":{"line":6,"column":2},"end":{"line":8,"column":null}},"2":{"start":{"line":7,"column":4},"end":{"line":7,"column":null}},"3":{"start":{"line":10,"column":2},"end":{"line":10,"column":null}}},"fnMap":{"0":{"name":"createSampleFeature","decl":{"start":{"line":3,"column":24},"end":{"line":3,"column":46}},"loc":{"start":{"line":3,"column":46},"end":{"line":11,"column":null}},"line":3},"1":{"name":"(anonymous_1)","decl":{"start":{"line":6,"column":10},"end":{"line":6,"column":22}},"loc":{"start":{"line":6,"column":28},"end":{"line":8,"column":3}},"line":6}},"branchMap":{},"s":{"0":2,"1":2,"2":2,"3":2},"f":{"0":2,"1":2},"b":{},"meta":{"lastBranch":0,"lastFunction":2,"lastStatement":4,"seen":{"f:3:24:3:46":0,"s:4:14:4:Infinity":0,"s:6:2:8:Infinity":1,"f:6:10:6:22":1,"s:7:4:7:Infinity":2,"s:10:2:10:Infinity":3},"fnNames":{}}}
,"/workspace/packages/plugins/auth-ad/src/index.ts": {"path":"/workspace/packages/plugins/auth-ad/src/index.ts","statementMap":{"0":{"start":{"line":4,"column":9},"end":{"line":4,"column":null}},"1":{"start":{"line":7,"column":35},"end":{"line":7,"column":null}},"2":{"start":{"line":8,"column":4},"end":{"line":10,"column":null}},"3":{"start":{"line":9,"column":6},"end":{"line":9,"column":null}},"4":{"start":{"line":11,"column":4},"end":{"line":11,"column":null}}},"fnMap":{"0":{"name":"authenticate","decl":{"start":{"line":6,"column":8},"end":{"line":6,"column":21}},"loc":{"start":{"line":6,"column":39},"end":{"line":12,"column":null}},"line":6}},"branchMap":{"0":{"loc":{"start":{"line":8,"column":4},"end":{"line":10,"column":null}},"type":"if","locations":[{"start":{"line":8,"column":4},"end":{"line":10,"column":null}},{"start":{},"end":{}}],"line":8},"1":{"loc":{"start":{"line":8,"column":8},"end":{"line":8,"column":62}},"type":"binary-expr","locations":[{"start":{"line":8,"column":8},"end":{"line":8,"column":34}},{"start":{"line":8,"column":34},"end":{"line":8,"column":62}}],"line":8}},"s":{"0":1,"1":0,"2":0,"3":0,"4":0},"f":{"0":0},"b":{"0":[0,0],"1":[0,0]},"meta":{"lastBranch":2,"lastFunction":1,"lastStatement":5,"seen":{"s:4:9:4:Infinity":0,"f:6:8:6:21":0,"s:7:35:7:Infinity":1,"b:8:4:10:Infinity:undefined:undefined:undefined:undefined":0,"s:8:4:10:Infinity":2,"b:8:8:8:34:8:34:8:62":1,"s:9:6:9:Infinity":3,"s:11:4:11:Infinity":4},"fnNames":{}}}
,"/workspace/packages/plugins/auth-local/src/auth-utils.ts": {"path":"/workspace/packages/plugins/auth-local/src/auth-utils.ts","statementMap":{"0":{"start":{"line":12,"column":23},"end":{"line":12,"column":null}},"1":{"start":{"line":13,"column":4},"end":{"line":13,"column":null}},"2":{"start":{"line":20,"column":4},"end":{"line":20,"column":null}},"3":{"start":{"line":35,"column":22},"end":{"line":35,"column":null}},"4":{"start":{"line":37,"column":4},"end":{"line":41,"column":null}},"5":{"start":{"line":52,"column":4},"end":{"line":59,"column":null}},"6":{"start":{"line":53,"column":26},"end":{"line":53,"column":null}},"7":{"start":{"line":54,"column":28},"end":{"line":54,"column":null}},"8":{"start":{"line":55,"column":8},"end":{"line":55,"column":null}},"9":{"start":{"line":58,"column":8},"end":{"line":58,"column":null}}},"fnMap":{"0":{"name":"hashPassword","decl":{"start":{"line":11,"column":22},"end":{"line":11,"column":35}},"loc":{"start":{"line":11,"column":70},"end":{"line":14,"column":null}},"line":11},"1":{"name":"verifyPassword","decl":{"start":{"line":19,"column":22},"end":{"line":19,"column":37}},"loc":{"start":{"line":19,"column":87},"end":{"line":21,"column":null}},"line":19},"2":{"name":"signJwt","decl":{"start":{"line":30,"column":22},"end":{"line":30,"column":null}},"loc":{"start":{"line":34,"column":19},"end":{"line":42,"column":null}},"line":34},"3":{"name":"verifyJwt","decl":{"start":{"line":48,"column":22},"end":{"line":48,"column":null}},"loc":{"start":{"line":51,"column":21},"end":{"line":60,"column":null}},"line":51}},"branchMap":{"0":{"loc":{"start":{"line":33,"column":4},"end":{"line":33,"column":null}},"type":"default-arg","locations":[{"start":{"line":33,"column":24},"end":{"line":33,"column":null}}],"line":33}},"s":{"0":5,"1":5,"2":5,"3":5,"4":5,"5":6,"6":6,"7":6,"8":3,"9":3},"f":{"0":5,"1":5,"2":5,"3":6},"b":{"0":[5]},"meta":{"lastBranch":1,"lastFunction":4,"lastStatement":10,"seen":{"f:11:22:11:35":0,"s:12:23:12:Infinity":0,"s:13:4:13:Infinity":1,"f:19:22:19:37":1,"s:20:4:20:Infinity":2,"f:30:22:30:Infinity":2,"b:33:24:33:Infinity":0,"s:35:22:35:Infinity":3,"s:37:4:41:Infinity":4,"f:48:22:48:Infinity":3,"s:52:4:59:Infinity":5,"s:53:26:53:Infinity":6,"s:54:28:54:Infinity":7,"s:55:8:55:Infinity":8,"s:58:8:58:Infinity":9},"fnNames":{}}}
,"/workspace/packages/plugins/auth-local/src/index.ts": {"path":"/workspace/packages/plugins/auth-local/src/index.ts","statementMap":{"0":{"start":{"line":4,"column":9},"end":{"line":4,"column":null}},"1":{"start":{"line":7,"column":35},"end":{"line":7,"column":null}},"2":{"start":{"line":8,"column":4},"end":{"line":10,"column":null}},"3":{"start":{"line":9,"column":6},"end":{"line":9,"column":null}},"4":{"start":{"line":11,"column":4},"end":{"line":11,"column":null}}},"fnMap":{"0":{"name":"authenticate","decl":{"start":{"line":6,"column":8},"end":{"line":6,"column":21}},"loc":{"start":{"line":6,"column":39},"end":{"line":12,"column":null}},"line":6}},"branchMap":{"0":{"loc":{"start":{"line":8,"column":4},"end":{"line":10,"column":null}},"type":"if","locations":[{"start":{"line":8,"column":4},"end":{"line":10,"column":null}},{"start":{},"end":{}}],"line":8},"1":{"loc":{"start":{"line":8,"column":8},"end":{"line":8,"column":57}},"type":"binary-expr","locations":[{"start":{"line":8,"column":8},"end":{"line":8,"column":32}},{"start":{"line":8,"column":32},"end":{"line":8,"column":57}}],"line":8}},"s":{"0":1,"1":0,"2":0,"3":0,"4":0},"f":{"0":0},"b":{"0":[0,0],"1":[0,0]},"meta":{"lastBranch":2,"lastFunction":1,"lastStatement":5,"seen":{"s:4:9:4:Infinity":0,"f:6:8:6:21":0,"s:7:35:7:Infinity":1,"b:8:4:10:Infinity:undefined:undefined:undefined:undefined":0,"s:8:4:10:Infinity":2,"b:8:8:8:32:8:32:8:57":1,"s:9:6:9:Infinity":3,"s:11:4:11:Infinity":4},"fnNames":{}}}
}
EOF_1785916429_4295

mkdir -p "coverage"
echo "作成: coverage/index.html"
cat << 'EOF_1785916429_8075' > "coverage/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for All files</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="prettify.css" />
    <link rel="stylesheet" href="base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1>All files</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">75.52% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>179/237</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">51.64% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>47/91</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">76.59% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>36/47</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">75.64% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>177/234</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line medium'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="apps/api/src"><a href="apps/api/src/index.html">apps/api/src</a></td>
	<td data-value="89.58" class="pic high">
	<div class="chart"><div class="cover-fill" style="width: 89%"></div><div class="cover-empty" style="width: 11%"></div></div>
	</td>
	<td data-value="89.58" class="pct high">89.58%</td>
	<td data-value="48" class="abs high">43/48</td>
	<td data-value="66.66" class="pct medium">66.66%</td>
	<td data-value="21" class="abs medium">14/21</td>
	<td data-value="85.71" class="pct high">85.71%</td>
	<td data-value="7" class="abs high">6/7</td>
	<td data-value="89.36" class="pct high">89.36%</td>
	<td data-value="47" class="abs high">42/47</td>
	</tr>

<tr>
	<td class="file high" data-value="apps/api/src/middlewares"><a href="apps/api/src/middlewares/index.html">apps/api/src/middlewares</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="10" class="abs high">10/10</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="6" class="abs high">6/6</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="2" class="abs high">2/2</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="10" class="abs high">10/10</td>
	</tr>

<tr>
	<td class="file high" data-value="apps/api/src/routes"><a href="apps/api/src/routes/index.html">apps/api/src/routes</a></td>
	<td data-value="90" class="pic high">
	<div class="chart"><div class="cover-fill" style="width: 90%"></div><div class="cover-empty" style="width: 10%"></div></div>
	</td>
	<td data-value="90" class="pct high">90%</td>
	<td data-value="20" class="abs high">18/20</td>
	<td data-value="66.66" class="pct medium">66.66%</td>
	<td data-value="6" class="abs medium">4/6</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="3" class="abs high">3/3</td>
	<td data-value="90" class="pct high">90%</td>
	<td data-value="20" class="abs high">18/20</td>
	</tr>

<tr>
	<td class="file low" data-value="apps/web/src"><a href="apps/web/src/index.html">apps/web/src</a></td>
	<td data-value="0" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="8" class="abs low">0/8</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="8" class="abs low">0/8</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="2" class="abs low">0/2</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="8" class="abs low">0/8</td>
	</tr>

<tr>
	<td class="file high" data-value="apps/web/src/components"><a href="apps/web/src/components/index.html">apps/web/src/components</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="19" class="abs high">19/19</td>
	<td data-value="75" class="pct medium">75%</td>
	<td data-value="8" class="abs medium">6/8</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="4" class="abs high">4/4</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="19" class="abs high">19/19</td>
	</tr>

<tr>
	<td class="file medium" data-value="apps/web/src/context"><a href="apps/web/src/context/index.html">apps/web/src/context</a></td>
	<td data-value="76.59" class="pic medium">
	<div class="chart"><div class="cover-fill" style="width: 76%"></div><div class="cover-empty" style="width: 24%"></div></div>
	</td>
	<td data-value="76.59" class="pct medium">76.59%</td>
	<td data-value="47" class="abs medium">36/47</td>
	<td data-value="50" class="pct medium">50%</td>
	<td data-value="10" class="abs medium">5/10</td>
	<td data-value="87.5" class="pct high">87.5%</td>
	<td data-value="8" class="abs high">7/8</td>
	<td data-value="77.77" class="pct medium">77.77%</td>
	<td data-value="45" class="abs medium">35/45</td>
	</tr>

<tr>
	<td class="file empty" data-value="packages/core"><a href="packages/core/index.html">packages/core</a></td>
	<td data-value="0" class="pic empty">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="4" class="abs empty">0/4</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	</tr>

<tr>
	<td class="file low" data-value="packages/core/src"><a href="packages/core/src/index.html">packages/core/src</a></td>
	<td data-value="0" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="9" class="abs low">0/9</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="2" class="abs low">0/2</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="9" class="abs low">0/9</td>
	</tr>

<tr>
	<td class="file low" data-value="packages/core/src/auth"><a href="packages/core/src/auth/index.html">packages/core/src/auth</a></td>
	<td data-value="42.85" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 42%"></div><div class="cover-empty" style="width: 58%"></div></div>
	</td>
	<td data-value="42.85" class="pct low">42.85%</td>
	<td data-value="7" class="abs low">3/7</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="2" class="abs low">0/2</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="2" class="abs high">2/2</td>
	<td data-value="42.85" class="pct low">42.85%</td>
	<td data-value="7" class="abs low">3/7</td>
	</tr>

<tr>
	<td class="file high" data-value="packages/core/src/config"><a href="packages/core/src/config/index.html">packages/core/src/config</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="13" class="abs high">13/13</td>
	<td data-value="66.66" class="pct medium">66.66%</td>
	<td data-value="9" class="abs medium">6/9</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="2" class="abs high">2/2</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="13" class="abs high">13/13</td>
	</tr>

<tr>
	<td class="file high" data-value="packages/core/src/db"><a href="packages/core/src/db/index.html">packages/core/src/db</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="4" class="abs high">4/4</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="4" class="abs high">4/4</td>
	</tr>

<tr>
	<td class="file high" data-value="packages/core/src/errors"><a href="packages/core/src/errors/index.html">packages/core/src/errors</a></td>
	<td data-value="80" class="pic high">
	<div class="chart"><div class="cover-fill" style="width: 80%"></div><div class="cover-empty" style="width: 20%"></div></div>
	</td>
	<td data-value="80" class="pct high">80%</td>
	<td data-value="10" class="abs high">8/10</td>
	<td data-value="50" class="pct medium">50%</td>
	<td data-value="4" class="abs medium">2/4</td>
	<td data-value="60" class="pct medium">60%</td>
	<td data-value="5" class="abs medium">3/5</td>
	<td data-value="80" class="pct high">80%</td>
	<td data-value="10" class="abs high">8/10</td>
	</tr>

<tr>
	<td class="file high" data-value="packages/core/src/registry"><a href="packages/core/src/registry/index.html">packages/core/src/registry</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="9" class="abs high">9/9</td>
	<td data-value="75" class="pct medium">75%</td>
	<td data-value="4" class="abs medium">3/4</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="1" class="abs high">1/1</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="9" class="abs high">9/9</td>
	</tr>

<tr>
	<td class="file low" data-value="packages/core/src/test"><a href="packages/core/src/test/index.html">packages/core/src/test</a></td>
	<td data-value="0" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="9" class="abs low">0/9</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="1" class="abs low">0/1</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="9" class="abs low">0/9</td>
	</tr>

<tr>
	<td class="file high" data-value="packages/features/sample/src"><a href="packages/features/sample/src/index.html">packages/features/sample/src</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="4" class="abs high">4/4</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="2" class="abs high">2/2</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="4" class="abs high">4/4</td>
	</tr>

<tr>
	<td class="file low" data-value="packages/plugins/auth-ad/src"><a href="packages/plugins/auth-ad/src/index.html">packages/plugins/auth-ad/src</a></td>
	<td data-value="20" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 20%"></div><div class="cover-empty" style="width: 80%"></div></div>
	</td>
	<td data-value="20" class="pct low">20%</td>
	<td data-value="5" class="abs low">1/5</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="4" class="abs low">0/4</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="1" class="abs low">0/1</td>
	<td data-value="20" class="pct low">20%</td>
	<td data-value="5" class="abs low">1/5</td>
	</tr>

<tr>
	<td class="file medium" data-value="packages/plugins/auth-local/src"><a href="packages/plugins/auth-local/src/index.html">packages/plugins/auth-local/src</a></td>
	<td data-value="73.33" class="pic medium">
	<div class="chart"><div class="cover-fill" style="width: 73%"></div><div class="cover-empty" style="width: 27%"></div></div>
	</td>
	<td data-value="73.33" class="pct medium">73.33%</td>
	<td data-value="15" class="abs medium">11/15</td>
	<td data-value="20" class="pct low">20%</td>
	<td data-value="5" class="abs low">1/5</td>
	<td data-value="80" class="pct high">80%</td>
	<td data-value="5" class="abs high">4/5</td>
	<td data-value="73.33" class="pct medium">73.33%</td>
	<td data-value="15" class="abs medium">11/15</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="sorter.js"></script>
        <script src="block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_8075

mkdir -p "coverage"
echo "作成: coverage/block-navigation.js"
cat << 'EOF_1785916429_13036' > "coverage/block-navigation.js"
/* eslint-disable */
var jumpToCode = (function init() {
    // Classes of code we would like to highlight in the file view
    var missingCoverageClasses = ['.cbranch-no', '.cstat-no', '.fstat-no'];

    // Elements to highlight in the file listing view
    var fileListingElements = ['td.pct.low'];

    // We don't want to select elements that are direct descendants of another match
    var notSelector = ':not(' + missingCoverageClasses.join('):not(') + ') > '; // becomes `:not(a):not(b) > `

    // Selector that finds elements on the page to which we can jump
    var selector =
        fileListingElements.join(', ') +
        ', ' +
        notSelector +
        missingCoverageClasses.join(', ' + notSelector); // becomes `:not(a):not(b) > a, :not(a):not(b) > b`

    // The NodeList of matching elements
    var missingCoverageElements = document.querySelectorAll(selector);

    var currentIndex;

    function toggleClass(index) {
        missingCoverageElements
            .item(currentIndex)
            .classList.remove('highlighted');
        missingCoverageElements.item(index).classList.add('highlighted');
    }

    function makeCurrent(index) {
        toggleClass(index);
        currentIndex = index;
        missingCoverageElements.item(index).scrollIntoView({
            behavior: 'smooth',
            block: 'center',
            inline: 'center'
        });
    }

    function goToPrevious() {
        var nextIndex = 0;
        if (typeof currentIndex !== 'number' || currentIndex === 0) {
            nextIndex = missingCoverageElements.length - 1;
        } else if (missingCoverageElements.length > 1) {
            nextIndex = currentIndex - 1;
        }

        makeCurrent(nextIndex);
    }

    function goToNext() {
        var nextIndex = 0;

        if (
            typeof currentIndex === 'number' &&
            currentIndex < missingCoverageElements.length - 1
        ) {
            nextIndex = currentIndex + 1;
        }

        makeCurrent(nextIndex);
    }

    return function jump(event) {
        if (
            document.getElementById('fileSearch') === document.activeElement &&
            document.activeElement != null
        ) {
            // if we're currently focused on the search input, we don't want to navigate
            return;
        }

        switch (event.which) {
            case 78: // n
            case 74: // j
                goToNext();
                break;
            case 66: // b
            case 75: // k
            case 80: // p
                goToPrevious();
                break;
        }
    };
})();
window.addEventListener('keydown', jumpToCode);
EOF_1785916429_13036

mkdir -p "coverage"
echo "作成: coverage/sorter.js"
cat << 'EOF_1785916429_8363' > "coverage/sorter.js"
/* eslint-disable */
var addSorting = (function() {
    'use strict';
    var cols,
        currentSort = {
            index: 0,
            desc: false
        };

    // returns the summary table element
    function getTable() {
        return document.querySelector('.coverage-summary');
    }
    // returns the thead element of the summary table
    function getTableHeader() {
        return getTable().querySelector('thead tr');
    }
    // returns the tbody element of the summary table
    function getTableBody() {
        return getTable().querySelector('tbody');
    }
    // returns the th element for nth column
    function getNthColumn(n) {
        return getTableHeader().querySelectorAll('th')[n];
    }

    function onFilterInput() {
        const searchValue = document.getElementById('fileSearch').value;
        const rows = document.getElementsByTagName('tbody')[0].children;

        // Try to create a RegExp from the searchValue. If it fails (invalid regex),
        // it will be treated as a plain text search
        let searchRegex;
        try {
            searchRegex = new RegExp(searchValue, 'i'); // 'i' for case-insensitive
        } catch (error) {
            searchRegex = null;
        }

        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            let isMatch = false;

            if (searchRegex) {
                // If a valid regex was created, use it for matching
                isMatch = searchRegex.test(row.textContent);
            } else {
                // Otherwise, fall back to the original plain text search
                isMatch = row.textContent
                    .toLowerCase()
                    .includes(searchValue.toLowerCase());
            }

            row.style.display = isMatch ? '' : 'none';
        }
    }

    // loads the search box
    function addSearchBox() {
        var template = document.getElementById('filterTemplate');
        var templateClone = template.content.cloneNode(true);
        templateClone.getElementById('fileSearch').oninput = onFilterInput;
        template.parentElement.appendChild(templateClone);
    }

    // loads all columns
    function loadColumns() {
        var colNodes = getTableHeader().querySelectorAll('th'),
            colNode,
            cols = [],
            col,
            i;

        for (i = 0; i < colNodes.length; i += 1) {
            colNode = colNodes[i];
            col = {
                key: colNode.getAttribute('data-col'),
                sortable: !colNode.getAttribute('data-nosort'),
                type: colNode.getAttribute('data-type') || 'string'
            };
            cols.push(col);
            if (col.sortable) {
                col.defaultDescSort = col.type === 'number';
                colNode.innerHTML =
                    colNode.innerHTML + '<span class="sorter"></span>';
            }
        }
        return cols;
    }
    // attaches a data attribute to every tr element with an object
    // of data values keyed by column name
    function loadRowData(tableRow) {
        var tableCols = tableRow.querySelectorAll('td'),
            colNode,
            col,
            data = {},
            i,
            val;
        for (i = 0; i < tableCols.length; i += 1) {
            colNode = tableCols[i];
            col = cols[i];
            val = colNode.getAttribute('data-value');
            if (col.type === 'number') {
                val = Number(val);
            }
            data[col.key] = val;
        }
        return data;
    }
    // loads all row data
    function loadData() {
        var rows = getTableBody().querySelectorAll('tr'),
            i;

        for (i = 0; i < rows.length; i += 1) {
            rows[i].data = loadRowData(rows[i]);
        }
    }
    // sorts the table using the data for the ith column
    function sortByIndex(index, desc) {
        var key = cols[index].key,
            sorter = function(a, b) {
                a = a.data[key];
                b = b.data[key];
                return a < b ? -1 : a > b ? 1 : 0;
            },
            finalSorter = sorter,
            tableBody = document.querySelector('.coverage-summary tbody'),
            rowNodes = tableBody.querySelectorAll('tr'),
            rows = [],
            i;

        if (desc) {
            finalSorter = function(a, b) {
                return -1 * sorter(a, b);
            };
        }

        for (i = 0; i < rowNodes.length; i += 1) {
            rows.push(rowNodes[i]);
            tableBody.removeChild(rowNodes[i]);
        }

        rows.sort(finalSorter);

        for (i = 0; i < rows.length; i += 1) {
            tableBody.appendChild(rows[i]);
        }
    }
    // removes sort indicators for current column being sorted
    function removeSortIndicators() {
        var col = getNthColumn(currentSort.index),
            cls = col.className;

        cls = cls.replace(/ sorted$/, '').replace(/ sorted-desc$/, '');
        col.className = cls;
    }
    // adds sort indicators for current column being sorted
    function addSortIndicators() {
        getNthColumn(currentSort.index).className += currentSort.desc
            ? ' sorted-desc'
            : ' sorted';
    }
    // adds event listeners for all sorter widgets
    function enableUI() {
        var i,
            el,
            ithSorter = function ithSorter(i) {
                var col = cols[i];

                return function() {
                    var desc = col.defaultDescSort;

                    if (currentSort.index === i) {
                        desc = !currentSort.desc;
                    }
                    sortByIndex(i, desc);
                    removeSortIndicators();
                    currentSort.index = i;
                    currentSort.desc = desc;
                    addSortIndicators();
                };
            };
        for (i = 0; i < cols.length; i += 1) {
            if (cols[i].sortable) {
                // add the click event handler on the th so users
                // dont have to click on those tiny arrows
                el = getNthColumn(i).querySelector('.sorter').parentElement;
                if (el.addEventListener) {
                    el.addEventListener('click', ithSorter(i));
                } else {
                    el.attachEvent('onclick', ithSorter(i));
                }
            }
        }
    }
    // adds sorting functionality to the UI
    return function() {
        if (!getTable()) {
            return;
        }
        cols = loadColumns();
        loadData();
        addSearchBox();
        addSortIndicators();
        enableUI();
    };
})();

window.addEventListener('load', addSorting);
EOF_1785916429_8363

mkdir -p "coverage"
echo "作成: coverage/prettify.js"
cat << 'EOF_1785916429_6963' > "coverage/prettify.js"
/* eslint-disable */
window.PR_SHOULD_USE_CONTINUATION=true;(function(){var h=["break,continue,do,else,for,if,return,while"];var u=[h,"auto,case,char,const,default,double,enum,extern,float,goto,int,long,register,short,signed,sizeof,static,struct,switch,typedef,union,unsigned,void,volatile"];var p=[u,"catch,class,delete,false,import,new,operator,private,protected,public,this,throw,true,try,typeof"];var l=[p,"alignof,align_union,asm,axiom,bool,concept,concept_map,const_cast,constexpr,decltype,dynamic_cast,explicit,export,friend,inline,late_check,mutable,namespace,nullptr,reinterpret_cast,static_assert,static_cast,template,typeid,typename,using,virtual,where"];var x=[p,"abstract,boolean,byte,extends,final,finally,implements,import,instanceof,null,native,package,strictfp,super,synchronized,throws,transient"];var R=[x,"as,base,by,checked,decimal,delegate,descending,dynamic,event,fixed,foreach,from,group,implicit,in,interface,internal,into,is,lock,object,out,override,orderby,params,partial,readonly,ref,sbyte,sealed,stackalloc,string,select,uint,ulong,unchecked,unsafe,ushort,var"];var r="all,and,by,catch,class,else,extends,false,finally,for,if,in,is,isnt,loop,new,no,not,null,of,off,on,or,return,super,then,true,try,unless,until,when,while,yes";var w=[p,"debugger,eval,export,function,get,null,set,undefined,var,with,Infinity,NaN"];var s="caller,delete,die,do,dump,elsif,eval,exit,foreach,for,goto,if,import,last,local,my,next,no,our,print,package,redo,require,sub,undef,unless,until,use,wantarray,while,BEGIN,END";var I=[h,"and,as,assert,class,def,del,elif,except,exec,finally,from,global,import,in,is,lambda,nonlocal,not,or,pass,print,raise,try,with,yield,False,True,None"];var f=[h,"alias,and,begin,case,class,def,defined,elsif,end,ensure,false,in,module,next,nil,not,or,redo,rescue,retry,self,super,then,true,undef,unless,until,when,yield,BEGIN,END"];var H=[h,"case,done,elif,esac,eval,fi,function,in,local,set,then,until"];var A=[l,R,w,s+I,f,H];var e=/^(DIR|FILE|vector|(de|priority_)?queue|list|stack|(const_)?iterator|(multi)?(set|map)|bitset|u?(int|float)\d*)/;var C="str";var z="kwd";var j="com";var O="typ";var G="lit";var L="pun";var F="pln";var m="tag";var E="dec";var J="src";var P="atn";var n="atv";var N="nocode";var M="(?:^^\\.?|[+-]|\\!|\\!=|\\!==|\\#|\\%|\\%=|&|&&|&&=|&=|\\(|\\*|\\*=|\\+=|\\,|\\-=|\\->|\\/|\\/=|:|::|\\;|<|<<|<<=|<=|=|==|===|>|>=|>>|>>=|>>>|>>>=|\\?|\\@|\\[|\\^|\\^=|\\^\\^|\\^\\^=|\\{|\\||\\|=|\\|\\||\\|\\|=|\\~|break|case|continue|delete|do|else|finally|instanceof|return|throw|try|typeof)\\s*";function k(Z){var ad=0;var S=false;var ac=false;for(var V=0,U=Z.length;V<U;++V){var ae=Z[V];if(ae.ignoreCase){ac=true}else{if(/[a-z]/i.test(ae.source.replace(/\\u[0-9a-f]{4}|\\x[0-9a-f]{2}|\\[^ux]/gi,""))){S=true;ac=false;break}}}var Y={b:8,t:9,n:10,v:11,f:12,r:13};function ab(ah){var ag=ah.charCodeAt(0);if(ag!==92){return ag}var af=ah.charAt(1);ag=Y[af];if(ag){return ag}else{if("0"<=af&&af<="7"){return parseInt(ah.substring(1),8)}else{if(af==="u"||af==="x"){return parseInt(ah.substring(2),16)}else{return ah.charCodeAt(1)}}}}function T(af){if(af<32){return(af<16?"\\x0":"\\x")+af.toString(16)}var ag=String.fromCharCode(af);if(ag==="\\"||ag==="-"||ag==="["||ag==="]"){ag="\\"+ag}return ag}function X(am){var aq=am.substring(1,am.length-1).match(new RegExp("\\\\u[0-9A-Fa-f]{4}|\\\\x[0-9A-Fa-f]{2}|\\\\[0-3][0-7]{0,2}|\\\\[0-7]{1,2}|\\\\[\\s\\S]|-|[^-\\\\]","g"));var ak=[];var af=[];var ao=aq[0]==="^";for(var ar=ao?1:0,aj=aq.length;ar<aj;++ar){var ah=aq[ar];if(/\\[bdsw]/i.test(ah)){ak.push(ah)}else{var ag=ab(ah);var al;if(ar+2<aj&&"-"===aq[ar+1]){al=ab(aq[ar+2]);ar+=2}else{al=ag}af.push([ag,al]);if(!(al<65||ag>122)){if(!(al<65||ag>90)){af.push([Math.max(65,ag)|32,Math.min(al,90)|32])}if(!(al<97||ag>122)){af.push([Math.max(97,ag)&~32,Math.min(al,122)&~32])}}}}af.sort(function(av,au){return(av[0]-au[0])||(au[1]-av[1])});var ai=[];var ap=[NaN,NaN];for(var ar=0;ar<af.length;++ar){var at=af[ar];if(at[0]<=ap[1]+1){ap[1]=Math.max(ap[1],at[1])}else{ai.push(ap=at)}}var an=["["];if(ao){an.push("^")}an.push.apply(an,ak);for(var ar=0;ar<ai.length;++ar){var at=ai[ar];an.push(T(at[0]));if(at[1]>at[0]){if(at[1]+1>at[0]){an.push("-")}an.push(T(at[1]))}}an.push("]");return an.join("")}function W(al){var aj=al.source.match(new RegExp("(?:\\[(?:[^\\x5C\\x5D]|\\\\[\\s\\S])*\\]|\\\\u[A-Fa-f0-9]{4}|\\\\x[A-Fa-f0-9]{2}|\\\\[0-9]+|\\\\[^ux0-9]|\\(\\?[:!=]|[\\(\\)\\^]|[^\\x5B\\x5C\\(\\)\\^]+)","g"));var ah=aj.length;var an=[];for(var ak=0,am=0;ak<ah;++ak){var ag=aj[ak];if(ag==="("){++am}else{if("\\"===ag.charAt(0)){var af=+ag.substring(1);if(af&&af<=am){an[af]=-1}}}}for(var ak=1;ak<an.length;++ak){if(-1===an[ak]){an[ak]=++ad}}for(var ak=0,am=0;ak<ah;++ak){var ag=aj[ak];if(ag==="("){++am;if(an[am]===undefined){aj[ak]="(?:"}}else{if("\\"===ag.charAt(0)){var af=+ag.substring(1);if(af&&af<=am){aj[ak]="\\"+an[am]}}}}for(var ak=0,am=0;ak<ah;++ak){if("^"===aj[ak]&&"^"!==aj[ak+1]){aj[ak]=""}}if(al.ignoreCase&&S){for(var ak=0;ak<ah;++ak){var ag=aj[ak];var ai=ag.charAt(0);if(ag.length>=2&&ai==="["){aj[ak]=X(ag)}else{if(ai!=="\\"){aj[ak]=ag.replace(/[a-zA-Z]/g,function(ao){var ap=ao.charCodeAt(0);return"["+String.fromCharCode(ap&~32,ap|32)+"]"})}}}}return aj.join("")}var aa=[];for(var V=0,U=Z.length;V<U;++V){var ae=Z[V];if(ae.global||ae.multiline){throw new Error(""+ae)}aa.push("(?:"+W(ae)+")")}return new RegExp(aa.join("|"),ac?"gi":"g")}function a(V){var U=/(?:^|\s)nocode(?:\s|$)/;var X=[];var T=0;var Z=[];var W=0;var S;if(V.currentStyle){S=V.currentStyle.whiteSpace}else{if(window.getComputedStyle){S=document.defaultView.getComputedStyle(V,null).getPropertyValue("white-space")}}var Y=S&&"pre"===S.substring(0,3);function aa(ab){switch(ab.nodeType){case 1:if(U.test(ab.className)){return}for(var ae=ab.firstChild;ae;ae=ae.nextSibling){aa(ae)}var ad=ab.nodeName;if("BR"===ad||"LI"===ad){X[W]="\n";Z[W<<1]=T++;Z[(W++<<1)|1]=ab}break;case 3:case 4:var ac=ab.nodeValue;if(ac.length){if(!Y){ac=ac.replace(/[ \t\r\n]+/g," ")}else{ac=ac.replace(/\r\n?/g,"\n")}X[W]=ac;Z[W<<1]=T;T+=ac.length;Z[(W++<<1)|1]=ab}break}}aa(V);return{sourceCode:X.join("").replace(/\n$/,""),spans:Z}}function B(S,U,W,T){if(!U){return}var V={sourceCode:U,basePos:S};W(V);T.push.apply(T,V.decorations)}var v=/\S/;function o(S){var V=undefined;for(var U=S.firstChild;U;U=U.nextSibling){var T=U.nodeType;V=(T===1)?(V?S:U):(T===3)?(v.test(U.nodeValue)?S:V):V}return V===S?undefined:V}function g(U,T){var S={};var V;(function(){var ad=U.concat(T);var ah=[];var ag={};for(var ab=0,Z=ad.length;ab<Z;++ab){var Y=ad[ab];var ac=Y[3];if(ac){for(var ae=ac.length;--ae>=0;){S[ac.charAt(ae)]=Y}}var af=Y[1];var aa=""+af;if(!ag.hasOwnProperty(aa)){ah.push(af);ag[aa]=null}}ah.push(/[\0-\uffff]/);V=k(ah)})();var X=T.length;var W=function(ah){var Z=ah.sourceCode,Y=ah.basePos;var ad=[Y,F];var af=0;var an=Z.match(V)||[];var aj={};for(var ae=0,aq=an.length;ae<aq;++ae){var ag=an[ae];var ap=aj[ag];var ai=void 0;var am;if(typeof ap==="string"){am=false}else{var aa=S[ag.charAt(0)];if(aa){ai=ag.match(aa[1]);ap=aa[0]}else{for(var ao=0;ao<X;++ao){aa=T[ao];ai=ag.match(aa[1]);if(ai){ap=aa[0];break}}if(!ai){ap=F}}am=ap.length>=5&&"lang-"===ap.substring(0,5);if(am&&!(ai&&typeof ai[1]==="string")){am=false;ap=J}if(!am){aj[ag]=ap}}var ab=af;af+=ag.length;if(!am){ad.push(Y+ab,ap)}else{var al=ai[1];var ak=ag.indexOf(al);var ac=ak+al.length;if(ai[2]){ac=ag.length-ai[2].length;ak=ac-al.length}var ar=ap.substring(5);B(Y+ab,ag.substring(0,ak),W,ad);B(Y+ab+ak,al,q(ar,al),ad);B(Y+ab+ac,ag.substring(ac),W,ad)}}ah.decorations=ad};return W}function i(T){var W=[],S=[];if(T.tripleQuotedStrings){W.push([C,/^(?:\'\'\'(?:[^\'\\]|\\[\s\S]|\'{1,2}(?=[^\']))*(?:\'\'\'|$)|\"\"\"(?:[^\"\\]|\\[\s\S]|\"{1,2}(?=[^\"]))*(?:\"\"\"|$)|\'(?:[^\\\']|\\[\s\S])*(?:\'|$)|\"(?:[^\\\"]|\\[\s\S])*(?:\"|$))/,null,"'\""])}else{if(T.multiLineStrings){W.push([C,/^(?:\'(?:[^\\\']|\\[\s\S])*(?:\'|$)|\"(?:[^\\\"]|\\[\s\S])*(?:\"|$)|\`(?:[^\\\`]|\\[\s\S])*(?:\`|$))/,null,"'\"`"])}else{W.push([C,/^(?:\'(?:[^\\\'\r\n]|\\.)*(?:\'|$)|\"(?:[^\\\"\r\n]|\\.)*(?:\"|$))/,null,"\"'"])}}if(T.verbatimStrings){S.push([C,/^@\"(?:[^\"]|\"\")*(?:\"|$)/,null])}var Y=T.hashComments;if(Y){if(T.cStyleComments){if(Y>1){W.push([j,/^#(?:##(?:[^#]|#(?!##))*(?:###|$)|.*)/,null,"#"])}else{W.push([j,/^#(?:(?:define|elif|else|endif|error|ifdef|include|ifndef|line|pragma|undef|warning)\b|[^\r\n]*)/,null,"#"])}S.push([C,/^<(?:(?:(?:\.\.\/)*|\/?)(?:[\w-]+(?:\/[\w-]+)+)?[\w-]+\.h|[a-z]\w*)>/,null])}else{W.push([j,/^#[^\r\n]*/,null,"#"])}}if(T.cStyleComments){S.push([j,/^\/\/[^\r\n]*/,null]);S.push([j,/^\/\*[\s\S]*?(?:\*\/|$)/,null])}if(T.regexLiterals){var X=("/(?=[^/*])(?:[^/\\x5B\\x5C]|\\x5C[\\s\\S]|\\x5B(?:[^\\x5C\\x5D]|\\x5C[\\s\\S])*(?:\\x5D|$))+/");S.push(["lang-regex",new RegExp("^"+M+"("+X+")")])}var V=T.types;if(V){S.push([O,V])}var U=(""+T.keywords).replace(/^ | $/g,"");if(U.length){S.push([z,new RegExp("^(?:"+U.replace(/[\s,]+/g,"|")+")\\b"),null])}W.push([F,/^\s+/,null," \r\n\t\xA0"]);S.push([G,/^@[a-z_$][a-z_$@0-9]*/i,null],[O,/^(?:[@_]?[A-Z]+[a-z][A-Za-z_$@0-9]*|\w+_t\b)/,null],[F,/^[a-z_$][a-z_$@0-9]*/i,null],[G,new RegExp("^(?:0x[a-f0-9]+|(?:\\d(?:_\\d+)*\\d*(?:\\.\\d*)?|\\.\\d\\+)(?:e[+\\-]?\\d+)?)[a-z]*","i"),null,"0123456789"],[F,/^\\[\s\S]?/,null],[L,/^.[^\s\w\.$@\'\"\`\/\#\\]*/,null]);return g(W,S)}var K=i({keywords:A,hashComments:true,cStyleComments:true,multiLineStrings:true,regexLiterals:true});function Q(V,ag){var U=/(?:^|\s)nocode(?:\s|$)/;var ab=/\r\n?|\n/;var ac=V.ownerDocument;var S;if(V.currentStyle){S=V.currentStyle.whiteSpace}else{if(window.getComputedStyle){S=ac.defaultView.getComputedStyle(V,null).getPropertyValue("white-space")}}var Z=S&&"pre"===S.substring(0,3);var af=ac.createElement("LI");while(V.firstChild){af.appendChild(V.firstChild)}var W=[af];function ae(al){switch(al.nodeType){case 1:if(U.test(al.className)){break}if("BR"===al.nodeName){ad(al);if(al.parentNode){al.parentNode.removeChild(al)}}else{for(var an=al.firstChild;an;an=an.nextSibling){ae(an)}}break;case 3:case 4:if(Z){var am=al.nodeValue;var aj=am.match(ab);if(aj){var ai=am.substring(0,aj.index);al.nodeValue=ai;var ah=am.substring(aj.index+aj[0].length);if(ah){var ak=al.parentNode;ak.insertBefore(ac.createTextNode(ah),al.nextSibling)}ad(al);if(!ai){al.parentNode.removeChild(al)}}}break}}function ad(ak){while(!ak.nextSibling){ak=ak.parentNode;if(!ak){return}}function ai(al,ar){var aq=ar?al.cloneNode(false):al;var ao=al.parentNode;if(ao){var ap=ai(ao,1);var an=al.nextSibling;ap.appendChild(aq);for(var am=an;am;am=an){an=am.nextSibling;ap.appendChild(am)}}return aq}var ah=ai(ak.nextSibling,0);for(var aj;(aj=ah.parentNode)&&aj.nodeType===1;){ah=aj}W.push(ah)}for(var Y=0;Y<W.length;++Y){ae(W[Y])}if(ag===(ag|0)){W[0].setAttribute("value",ag)}var aa=ac.createElement("OL");aa.className="linenums";var X=Math.max(0,((ag-1))|0)||0;for(var Y=0,T=W.length;Y<T;++Y){af=W[Y];af.className="L"+((Y+X)%10);if(!af.firstChild){af.appendChild(ac.createTextNode("\xA0"))}aa.appendChild(af)}V.appendChild(aa)}function D(ac){var aj=/\bMSIE\b/.test(navigator.userAgent);var am=/\n/g;var al=ac.sourceCode;var an=al.length;var V=0;var aa=ac.spans;var T=aa.length;var ah=0;var X=ac.decorations;var Y=X.length;var Z=0;X[Y]=an;var ar,aq;for(aq=ar=0;aq<Y;){if(X[aq]!==X[aq+2]){X[ar++]=X[aq++];X[ar++]=X[aq++]}else{aq+=2}}Y=ar;for(aq=ar=0;aq<Y;){var at=X[aq];var ab=X[aq+1];var W=aq+2;while(W+2<=Y&&X[W+1]===ab){W+=2}X[ar++]=at;X[ar++]=ab;aq=W}Y=X.length=ar;var ae=null;while(ah<T){var af=aa[ah];var S=aa[ah+2]||an;var ag=X[Z];var ap=X[Z+2]||an;var W=Math.min(S,ap);var ak=aa[ah+1];var U;if(ak.nodeType!==1&&(U=al.substring(V,W))){if(aj){U=U.replace(am,"\r")}ak.nodeValue=U;var ai=ak.ownerDocument;var ao=ai.createElement("SPAN");ao.className=X[Z+1];var ad=ak.parentNode;ad.replaceChild(ao,ak);ao.appendChild(ak);if(V<S){aa[ah+1]=ak=ai.createTextNode(al.substring(W,S));ad.insertBefore(ak,ao.nextSibling)}}V=W;if(V>=S){ah+=2}if(V>=ap){Z+=2}}}var t={};function c(U,V){for(var S=V.length;--S>=0;){var T=V[S];if(!t.hasOwnProperty(T)){t[T]=U}else{if(window.console){console.warn("cannot override language handler %s",T)}}}}function q(T,S){if(!(T&&t.hasOwnProperty(T))){T=/^\s*</.test(S)?"default-markup":"default-code"}return t[T]}c(K,["default-code"]);c(g([],[[F,/^[^<?]+/],[E,/^<!\w[^>]*(?:>|$)/],[j,/^<\!--[\s\S]*?(?:-\->|$)/],["lang-",/^<\?([\s\S]+?)(?:\?>|$)/],["lang-",/^<%([\s\S]+?)(?:%>|$)/],[L,/^(?:<[%?]|[%?]>)/],["lang-",/^<xmp\b[^>]*>([\s\S]+?)<\/xmp\b[^>]*>/i],["lang-js",/^<script\b[^>]*>([\s\S]*?)(<\/script\b[^>]*>)/i],["lang-css",/^<style\b[^>]*>([\s\S]*?)(<\/style\b[^>]*>)/i],["lang-in.tag",/^(<\/?[a-z][^<>]*>)/i]]),["default-markup","htm","html","mxml","xhtml","xml","xsl"]);c(g([[F,/^[\s]+/,null," \t\r\n"],[n,/^(?:\"[^\"]*\"?|\'[^\']*\'?)/,null,"\"'"]],[[m,/^^<\/?[a-z](?:[\w.:-]*\w)?|\/?>$/i],[P,/^(?!style[\s=]|on)[a-z](?:[\w:-]*\w)?/i],["lang-uq.val",/^=\s*([^>\'\"\s]*(?:[^>\'\"\s\/]|\/(?=\s)))/],[L,/^[=<>\/]+/],["lang-js",/^on\w+\s*=\s*\"([^\"]+)\"/i],["lang-js",/^on\w+\s*=\s*\'([^\']+)\'/i],["lang-js",/^on\w+\s*=\s*([^\"\'>\s]+)/i],["lang-css",/^style\s*=\s*\"([^\"]+)\"/i],["lang-css",/^style\s*=\s*\'([^\']+)\'/i],["lang-css",/^style\s*=\s*([^\"\'>\s]+)/i]]),["in.tag"]);c(g([],[[n,/^[\s\S]+/]]),["uq.val"]);c(i({keywords:l,hashComments:true,cStyleComments:true,types:e}),["c","cc","cpp","cxx","cyc","m"]);c(i({keywords:"null,true,false"}),["json"]);c(i({keywords:R,hashComments:true,cStyleComments:true,verbatimStrings:true,types:e}),["cs"]);c(i({keywords:x,cStyleComments:true}),["java"]);c(i({keywords:H,hashComments:true,multiLineStrings:true}),["bsh","csh","sh"]);c(i({keywords:I,hashComments:true,multiLineStrings:true,tripleQuotedStrings:true}),["cv","py"]);c(i({keywords:s,hashComments:true,multiLineStrings:true,regexLiterals:true}),["perl","pl","pm"]);c(i({keywords:f,hashComments:true,multiLineStrings:true,regexLiterals:true}),["rb"]);c(i({keywords:w,cStyleComments:true,regexLiterals:true}),["js"]);c(i({keywords:r,hashComments:3,cStyleComments:true,multilineStrings:true,tripleQuotedStrings:true,regexLiterals:true}),["coffee"]);c(g([],[[C,/^[\s\S]+/]]),["regex"]);function d(V){var U=V.langExtension;try{var S=a(V.sourceNode);var T=S.sourceCode;V.sourceCode=T;V.spans=S.spans;V.basePos=0;q(U,T)(V);D(V)}catch(W){if("console" in window){console.log(W&&W.stack?W.stack:W)}}}function y(W,V,U){var S=document.createElement("PRE");S.innerHTML=W;if(U){Q(S,U)}var T={langExtension:V,numberLines:U,sourceNode:S};d(T);return S.innerHTML}function b(ad){function Y(af){return document.getElementsByTagName(af)}var ac=[Y("pre"),Y("code"),Y("xmp")];var T=[];for(var aa=0;aa<ac.length;++aa){for(var Z=0,V=ac[aa].length;Z<V;++Z){T.push(ac[aa][Z])}}ac=null;var W=Date;if(!W.now){W={now:function(){return +(new Date)}}}var X=0;var S;var ab=/\blang(?:uage)?-([\w.]+)(?!\S)/;var ae=/\bprettyprint\b/;function U(){var ag=(window.PR_SHOULD_USE_CONTINUATION?W.now()+250:Infinity);for(;X<T.length&&W.now()<ag;X++){var aj=T[X];var ai=aj.className;if(ai.indexOf("prettyprint")>=0){var ah=ai.match(ab);var am;if(!ah&&(am=o(aj))&&"CODE"===am.tagName){ah=am.className.match(ab)}if(ah){ah=ah[1]}var al=false;for(var ak=aj.parentNode;ak;ak=ak.parentNode){if((ak.tagName==="pre"||ak.tagName==="code"||ak.tagName==="xmp")&&ak.className&&ak.className.indexOf("prettyprint")>=0){al=true;break}}if(!al){var af=aj.className.match(/\blinenums\b(?::(\d+))?/);af=af?af[1]&&af[1].length?+af[1]:true:false;if(af){Q(aj,af)}S={langExtension:ah,sourceNode:aj,numberLines:af};d(S)}}}if(X<T.length){setTimeout(U,250)}else{if(ad){ad()}}}U()}window.prettyPrintOne=y;window.prettyPrint=b;window.PR={createSimpleLexer:g,registerLangHandler:c,sourceDecorator:i,PR_ATTRIB_NAME:P,PR_ATTRIB_VALUE:n,PR_COMMENT:j,PR_DECLARATION:E,PR_KEYWORD:z,PR_LITERAL:G,PR_NOCODE:N,PR_PLAIN:F,PR_PUNCTUATION:L,PR_SOURCE:J,PR_STRING:C,PR_TAG:m,PR_TYPE:O}})();PR.registerLangHandler(PR.createSimpleLexer([],[[PR.PR_DECLARATION,/^<!\w[^>]*(?:>|$)/],[PR.PR_COMMENT,/^<\!--[\s\S]*?(?:-\->|$)/],[PR.PR_PUNCTUATION,/^(?:<[%?]|[%?]>)/],["lang-",/^<\?([\s\S]+?)(?:\?>|$)/],["lang-",/^<%([\s\S]+?)(?:%>|$)/],["lang-",/^<xmp\b[^>]*>([\s\S]+?)<\/xmp\b[^>]*>/i],["lang-handlebars",/^<script\b[^>]*type\s*=\s*['"]?text\/x-handlebars-template['"]?\b[^>]*>([\s\S]*?)(<\/script\b[^>]*>)/i],["lang-js",/^<script\b[^>]*>([\s\S]*?)(<\/script\b[^>]*>)/i],["lang-css",/^<style\b[^>]*>([\s\S]*?)(<\/style\b[^>]*>)/i],["lang-in.tag",/^(<\/?[a-z][^<>]*>)/i],[PR.PR_DECLARATION,/^{{[#^>/]?\s*[\w.][^}]*}}/],[PR.PR_DECLARATION,/^{{&?\s*[\w.][^}]*}}/],[PR.PR_DECLARATION,/^{{{>?\s*[\w.][^}]*}}}/],[PR.PR_COMMENT,/^{{![^}]*}}/]]),["handlebars","hbs"]);PR.registerLangHandler(PR.createSimpleLexer([[PR.PR_PLAIN,/^[ \t\r\n\f]+/,null," \t\r\n\f"]],[[PR.PR_STRING,/^\"(?:[^\n\r\f\\\"]|\\(?:\r\n?|\n|\f)|\\[\s\S])*\"/,null],[PR.PR_STRING,/^\'(?:[^\n\r\f\\\']|\\(?:\r\n?|\n|\f)|\\[\s\S])*\'/,null],["lang-css-str",/^url\(([^\)\"\']*)\)/i],[PR.PR_KEYWORD,/^(?:url|rgb|\!important|@import|@page|@media|@charset|inherit)(?=[^\-\w]|$)/i,null],["lang-css-kw",/^(-?(?:[_a-z]|(?:\\[0-9a-f]+ ?))(?:[_a-z0-9\-]|\\(?:\\[0-9a-f]+ ?))*)\s*:/i],[PR.PR_COMMENT,/^\/\*[^*]*\*+(?:[^\/*][^*]*\*+)*\//],[PR.PR_COMMENT,/^(?:<!--|-->)/],[PR.PR_LITERAL,/^(?:\d+|\d*\.\d+)(?:%|[a-z]+)?/i],[PR.PR_LITERAL,/^#(?:[0-9a-f]{3}){1,2}/i],[PR.PR_PLAIN,/^-?(?:[_a-z]|(?:\\[\da-f]+ ?))(?:[_a-z\d\-]|\\(?:\\[\da-f]+ ?))*/i],[PR.PR_PUNCTUATION,/^[^\s\w\'\"]+/]]),["css"]);PR.registerLangHandler(PR.createSimpleLexer([],[[PR.PR_KEYWORD,/^-?(?:[_a-z]|(?:\\[\da-f]+ ?))(?:[_a-z\d\-]|\\(?:\\[\da-f]+ ?))*/i]]),["css-kw"]);PR.registerLangHandler(PR.createSimpleLexer([],[[PR.PR_STRING,/^[^\)\"\']+/]]),["css-str"]);
EOF_1785916429_6963

mkdir -p "coverage/packages/plugins/auth-ad/src"
echo "作成: coverage/packages/plugins/auth-ad/src/index.html"
cat << 'EOF_1785916429_32165' > "coverage/packages/plugins/auth-ad/src/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/plugins/auth-ad/src</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> packages/plugins/auth-ad/src</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">20% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>1/5</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">20% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>1/5</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file low" data-value="index.ts"><a href="index.ts.html">index.ts</a></td>
	<td data-value="20" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 20%"></div><div class="cover-empty" style="width: 80%"></div></div>
	</td>
	<td data-value="20" class="pct low">20%</td>
	<td data-value="5" class="abs low">1/5</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="4" class="abs low">0/4</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="1" class="abs low">0/1</td>
	<td data-value="20" class="pct low">20%</td>
	<td data-value="5" class="abs low">1/5</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_32165

mkdir -p "coverage/packages/plugins/auth-ad/src"
echo "作成: coverage/packages/plugins/auth-ad/src/index.ts.html"
cat << 'EOF_1785916429_24246' > "coverage/packages/plugins/auth-ad/src/index.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/plugins/auth-ad/src/index.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/plugins/auth-ad/src</a> index.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">20% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>1/5</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">20% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>1/5</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { AuthPlugin } from '@app/core/auth/auth-registry';
&nbsp;
export class ActiveDirectoryAuthPlugin implements AuthPlugin {
  name = 'ad';
&nbsp;
  async <span class="fstat-no" title="function not covered" >authenticate(c</span>redentials: any) {
    const { username, password } = <span class="cstat-no" title="statement not covered" >credentials;</span>
<span class="cstat-no" title="statement not covered" >    if (username === 'ad_user' &amp;&amp; password === 'domain_pass') {</span>
<span class="cstat-no" title="statement not covered" >      return { id: '100', name: 'AD Domain User' };</span>
    }
<span class="cstat-no" title="statement not covered" >    throw new Error('Active Directory authentication failed');</span>
  }
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_24246

mkdir -p "coverage/packages/plugins/auth-local/src"
echo "作成: coverage/packages/plugins/auth-local/src/auth-utils.ts.html"
cat << 'EOF_1785916429_10614' > "coverage/packages/plugins/auth-local/src/auth-utils.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/plugins/auth-local/src/auth-utils.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/plugins/auth-local/src</a> auth-utils.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>10/10</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>1/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>4/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>10/10</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a>
<a name='L28'></a><a href='#L28'>28</a>
<a name='L29'></a><a href='#L29'>29</a>
<a name='L30'></a><a href='#L30'>30</a>
<a name='L31'></a><a href='#L31'>31</a>
<a name='L32'></a><a href='#L32'>32</a>
<a name='L33'></a><a href='#L33'>33</a>
<a name='L34'></a><a href='#L34'>34</a>
<a name='L35'></a><a href='#L35'>35</a>
<a name='L36'></a><a href='#L36'>36</a>
<a name='L37'></a><a href='#L37'>37</a>
<a name='L38'></a><a href='#L38'>38</a>
<a name='L39'></a><a href='#L39'>39</a>
<a name='L40'></a><a href='#L40'>40</a>
<a name='L41'></a><a href='#L41'>41</a>
<a name='L42'></a><a href='#L42'>42</a>
<a name='L43'></a><a href='#L43'>43</a>
<a name='L44'></a><a href='#L44'>44</a>
<a name='L45'></a><a href='#L45'>45</a>
<a name='L46'></a><a href='#L46'>46</a>
<a name='L47'></a><a href='#L47'>47</a>
<a name='L48'></a><a href='#L48'>48</a>
<a name='L49'></a><a href='#L49'>49</a>
<a name='L50'></a><a href='#L50'>50</a>
<a name='L51'></a><a href='#L51'>51</a>
<a name='L52'></a><a href='#L52'>52</a>
<a name='L53'></a><a href='#L53'>53</a>
<a name='L54'></a><a href='#L54'>54</a>
<a name='L55'></a><a href='#L55'>55</a>
<a name='L56'></a><a href='#L56'>56</a>
<a name='L57'></a><a href='#L57'>57</a>
<a name='L58'></a><a href='#L58'>58</a>
<a name='L59'></a><a href='#L59'>59</a>
<a name='L60'></a><a href='#L60'>60</a>
<a name='L61'></a><a href='#L61'>61</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">6x</span>
<span class="cline-any cline-yes">6x</span>
<span class="cline-any cline-yes">6x</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import bcrypt from 'bcryptjs';
import { SignJWT, jwtVerify } from 'jose';
&nbsp;
// ----------------------------------------------------
// 1. パスワードハッシュ化 &amp; 照合処理
// ----------------------------------------------------
&nbsp;
/**
 * 平文パスワードをハッシュ化します
 */
export async function hashPassword(password: string): Promise&lt;string&gt; {
    const saltRounds = 10;
    return await bcrypt.hash(password, saltRounds);
}
&nbsp;
/**
 * 平文パスワードとハッシュ値を照合します
 */
export async function verifyPassword(password: string, hash: string): Promise&lt;boolean&gt; {
    return await bcrypt.compare(password, hash);
}
&nbsp;
// ----------------------------------------------------
// 2. JWT 発行 &amp; 検証処理
// ----------------------------------------------------
&nbsp;
/**
 * Payload を受け取り、署名済み JWT を生成します
 */
export async function signJwt(
    payload: Record&lt;string, unknown&gt;,
    secret: string,
    expiresIn: string = '2h'
): Promise&lt;string&gt; {
    const secretKey = new TextEncoder().encode(secret);
&nbsp;
    return await new SignJWT(payload)
        .setProtectedHeader({ alg: 'HS256' })
        .setIssuedAt()
        .setExpirationTime(expiresIn)
        .sign(secretKey);
}
&nbsp;
/**
 * JWT を検証し、デコードされた Payload を返します。
 * 不正または改ざんされたトークンの場合は null を返します。
 */
export async function verifyJwt&lt;T = Record&lt;string, unknown&gt;&gt;(
    token: string,
    secret: string
): Promise&lt;T | null&gt; {
    try {
        const secretKey = new TextEncoder().encode(secret);
        const { payload } = await jwtVerify(token, secretKey);
        return payload as T;
    } catch {
        // トークンが不正、改ざんされている、または有効期限切れの場合
        return null;
    }
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_10614

mkdir -p "coverage/packages/plugins/auth-local/src"
echo "作成: coverage/packages/plugins/auth-local/src/index.html"
cat << 'EOF_1785916429_11790' > "coverage/packages/plugins/auth-local/src/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/plugins/auth-local/src</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> packages/plugins/auth-local/src</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">73.33% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>11/15</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">20% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>1/5</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">80% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>4/5</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">73.33% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>11/15</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line medium'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="auth-utils.ts"><a href="auth-utils.ts.html">auth-utils.ts</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="10" class="abs high">10/10</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="1" class="abs high">1/1</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="4" class="abs high">4/4</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="10" class="abs high">10/10</td>
	</tr>

<tr>
	<td class="file low" data-value="index.ts"><a href="index.ts.html">index.ts</a></td>
	<td data-value="20" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 20%"></div><div class="cover-empty" style="width: 80%"></div></div>
	</td>
	<td data-value="20" class="pct low">20%</td>
	<td data-value="5" class="abs low">1/5</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="4" class="abs low">0/4</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="1" class="abs low">0/1</td>
	<td data-value="20" class="pct low">20%</td>
	<td data-value="5" class="abs low">1/5</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_11790

mkdir -p "coverage/packages/plugins/auth-local/src"
echo "作成: coverage/packages/plugins/auth-local/src/index.ts.html"
cat << 'EOF_1785916429_24218' > "coverage/packages/plugins/auth-local/src/index.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/plugins/auth-local/src/index.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/plugins/auth-local/src</a> index.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">20% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>1/5</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">20% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>1/5</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { AuthPlugin } from '@app/core/auth/auth-registry';
&nbsp;
export class LocalAuthPlugin implements AuthPlugin {
  name = 'local';
&nbsp;
  async <span class="fstat-no" title="function not covered" >authenticate(c</span>redentials: any) {
    const { username, password } = <span class="cstat-no" title="statement not covered" >credentials;</span>
<span class="cstat-no" title="statement not covered" >    if (username === 'admin' &amp;&amp; password === 'password') {</span>
<span class="cstat-no" title="statement not covered" >      return { id: '1', name: 'Local Admin' };</span>
    }
<span class="cstat-no" title="statement not covered" >    throw new Error('Invalid local credentials');</span>
  }
}
&nbsp;
export * from './auth-utils';
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_24218

mkdir -p "coverage/packages/core"
echo "作成: coverage/packages/core/index.html"
cat << 'EOF_1785916429_30434' > "coverage/packages/core/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../prettify.css" />
    <link rel="stylesheet" href="../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../index.html">All files</a> packages/core</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file empty" data-value="drizzle-test.config.ts"><a href="drizzle-test.config.ts.html">drizzle-test.config.ts</a></td>
	<td data-value="0" class="pic empty">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="2" class="abs empty">0/2</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	</tr>

<tr>
	<td class="file empty" data-value="drizzle.config.ts"><a href="drizzle.config.ts.html">drizzle.config.ts</a></td>
	<td data-value="0" class="pic empty">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="2" class="abs empty">0/2</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../sorter.js"></script>
        <script src="../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_30434

mkdir -p "coverage/packages/core"
echo "作成: coverage/packages/core/drizzle-test.config.ts.html"
cat << 'EOF_1785916429_8975' > "coverage/packages/core/drizzle-test.config.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/drizzle-test.config.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../prettify.css" />
    <link rel="stylesheet" href="../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../index.html">All files</a> / <a href="index.html">packages/core</a> drizzle-test.config.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { defineConfig } from 'drizzle-kit';
&nbsp;
export default defineConfig({
    // スキーマファイルの場所
    schema: './src/db/schema.ts',
&nbsp;
    // マイグレーションファイルの出力先（push の場合は参照のみ）
    out: './drizzle',
&nbsp;
    // 使用する DB ドライバー
    dialect: 'postgresql',
&nbsp;
    // 接続情報（.env から読み込み）
    dbCredentials: {
        url: process.env.TEST_DATABASE_URL || 'postgresql://postgres:postgres@db:5432/app_db_test',
    },
});
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../sorter.js"></script>
        <script src="../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_8975

mkdir -p "coverage/packages/core/src/registry"
echo "作成: coverage/packages/core/src/registry/index.html"
cat << 'EOF_1785916429_18151' > "coverage/packages/core/src/registry/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/registry</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> packages/core/src/registry</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>9/9</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">75% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>3/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>1/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>9/9</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="hono-auto-loader.ts"><a href="hono-auto-loader.ts.html">hono-auto-loader.ts</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="9" class="abs high">9/9</td>
	<td data-value="75" class="pct medium">75%</td>
	<td data-value="4" class="abs medium">3/4</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="1" class="abs high">1/1</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="9" class="abs high">9/9</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_18151

mkdir -p "coverage/packages/core/src/registry"
echo "作成: coverage/packages/core/src/registry/hono-auto-loader.ts.html"
cat << 'EOF_1785916429_25553' > "coverage/packages/core/src/registry/hono-auto-loader.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/registry/hono-auto-loader.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/core/src/registry</a> hono-auto-loader.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>9/9</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">75% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>3/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>1/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>9/9</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { Hono } from 'hono';
import { glob } from 'glob';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
&nbsp;
export async function loadFeatureModules(app: Hono, pattern: string) {
  const files = await glob(pattern);
  for (const file of files) {
    const absolutePath = path.resolve(file);
&nbsp;
    // 💡 pathToFileURL を使って安全な file:// URL を生成
    const moduleUrl = pathToFileURL(absolutePath).href;
    // const module = await import(/* @vite-ignore */ moduleUrl);
    const module = await import(moduleUrl);
&nbsp;
    <span class="missing-if-branch" title="else path not taken" >E</span>if (module.default &amp;&amp; typeof module.default === 'function') {
      const route = module.default();
      app.route('/', route);
      console.log(`[Auto-Loader] Loaded Feature module: ${file}`);
    }
  }
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_25553

mkdir -p "coverage/packages/core/src"
echo "作成: coverage/packages/core/src/index.html"
cat << 'EOF_1785916429_32145' > "coverage/packages/core/src/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> packages/core/src</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/9</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/9</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file empty" data-value="index.ts"><a href="index.ts.html">index.ts</a></td>
	<td data-value="0" class="pic empty">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	<td data-value="0" class="pct empty">0%</td>
	<td data-value="0" class="abs empty">0/0</td>
	</tr>

<tr>
	<td class="file low" data-value="seed-dev-user.ts"><a href="seed-dev-user.ts.html">seed-dev-user.ts</a></td>
	<td data-value="0" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="9" class="abs low">0/9</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="2" class="abs low">0/2</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="9" class="abs low">0/9</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_32145

mkdir -p "coverage/packages/core/src/config"
echo "作成: coverage/packages/core/src/config/index.html"
cat << 'EOF_1785916429_25631' > "coverage/packages/core/src/config/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/config</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> packages/core/src/config</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>13/13</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">66.66% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>6/9</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>2/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>13/13</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="env.ts"><a href="env.ts.html">env.ts</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="13" class="abs high">13/13</td>
	<td data-value="66.66" class="pct medium">66.66%</td>
	<td data-value="9" class="abs medium">6/9</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="2" class="abs high">2/2</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="13" class="abs high">13/13</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_25631

mkdir -p "coverage/packages/core/src/config"
echo "作成: coverage/packages/core/src/config/env.ts.html"
cat << 'EOF_1785916429_26907' > "coverage/packages/core/src/config/env.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/config/env.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/core/src/config</a> env.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>13/13</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">66.66% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>6/9</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>2/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>13/13</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a>
<a name='L28'></a><a href='#L28'>28</a>
<a name='L29'></a><a href='#L29'>29</a>
<a name='L30'></a><a href='#L30'>30</a>
<a name='L31'></a><a href='#L31'>31</a>
<a name='L32'></a><a href='#L32'>32</a>
<a name='L33'></a><a href='#L33'>33</a>
<a name='L34'></a><a href='#L34'>34</a>
<a name='L35'></a><a href='#L35'>35</a>
<a name='L36'></a><a href='#L36'>36</a>
<a name='L37'></a><a href='#L37'>37</a>
<a name='L38'></a><a href='#L38'>38</a>
<a name='L39'></a><a href='#L39'>39</a>
<a name='L40'></a><a href='#L40'>40</a>
<a name='L41'></a><a href='#L41'>41</a>
<a name='L42'></a><a href='#L42'>42</a>
<a name='L43'></a><a href='#L43'>43</a>
<a name='L44'></a><a href='#L44'>44</a>
<a name='L45'></a><a href='#L45'>45</a>
<a name='L46'></a><a href='#L46'>46</a>
<a name='L47'></a><a href='#L47'>47</a>
<a name='L48'></a><a href='#L48'>48</a>
<a name='L49'></a><a href='#L49'>49</a>
<a name='L50'></a><a href='#L50'>50</a>
<a name='L51'></a><a href='#L51'>51</a>
<a name='L52'></a><a href='#L52'>52</a>
<a name='L53'></a><a href='#L53'>53</a>
<a name='L54'></a><a href='#L54'>54</a>
<a name='L55'></a><a href='#L55'>55</a>
<a name='L56'></a><a href='#L56'>56</a>
<a name='L57'></a><a href='#L57'>57</a>
<a name='L58'></a><a href='#L58'>58</a>
<a name='L59'></a><a href='#L59'>59</a>
<a name='L60'></a><a href='#L60'>60</a>
<a name='L61'></a><a href='#L61'>61</a>
<a name='L62'></a><a href='#L62'>62</a>
<a name='L63'></a><a href='#L63'>63</a>
<a name='L64'></a><a href='#L64'>64</a>
<a name='L65'></a><a href='#L65'>65</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">10x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">10x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">8x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { z } from 'zod';
&nbsp;
// ==========================================
// 1. バックエンド用 (Node.js) スキーマ &amp; 関数
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
&nbsp;
export type Env = z.infer&lt;typeof envSchema&gt;;
&nbsp;
export function validateEnv(targetEnv: Record&lt;string, string | undefined&gt; = process.env): Env {
    const result = envSchema.safeParse(targetEnv);
&nbsp;
    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        console.error('❌ 無効な環境変数があります:\n', formattedErrors);
        throw new Error(`環境変数の検証に失敗しました:\n${formattedErrors}`);
    }
&nbsp;
    return result.data;
}
&nbsp;
/**
 * ログ出力用に環境変数を整形（パスワード等はマスク）する関数
 */
export function formatEnvForLog(envObj: Env): string {
    const maskedEnv = { ...envObj };
&nbsp;
    <span class="missing-if-branch" title="else path not taken" >E</span>if (maskedEnv.DATABASE_URL) {
        maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL.replace(
            /:\/\/(.*):(.*)@/,
            '://$1:***@'
        );
    }
&nbsp;
    return JSON.stringify(maskedEnv, null, 2);
}
&nbsp;
// ⚠️ トップレベルで validateEnv() を直接実行するのではなく、
// ブラウザ環境（typeof window !== 'undefined'）では参照しない安全なガードを入れる
export const env: Env = typeof window !== 'undefined'
    ? (<span class="branch-0 cbranch-no" title="branch not covered" >{} as Env)</span>
    : (process.env.NODE_ENV === 'test'
        ? (process.env as unknown as Env)
        : <span class="branch-1 cbranch-no" title="branch not covered" >validateEnv());</span>
&nbsp;
&nbsp;
// ==========================================
// 2. フロントエンド用 (Vite / Browser) スキーマ
// ==========================================
export const clientEnvSchema = z.object({
    VITE_PORT: z.string().optional().default('3000'),
    VITE_API_TARGET_URL: z.string().url().optional().default('http://127.0.0.1:3001'),
    VITE_APP_TITLE: z.string().optional().default('My App'),
});
&nbsp;
export type ClientEnv = z.infer&lt;typeof clientEnvSchema&gt;;
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_26907

mkdir -p "coverage/packages/core/src/db"
echo "作成: coverage/packages/core/src/db/schema.ts.html"
cat << 'EOF_1785916429_23499' > "coverage/packages/core/src/db/schema.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/db/schema.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/core/src/db</a> schema.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>1/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>1/1</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';
&nbsp;
export const users = pgTable('users', {
    id: serial('id').primaryKey(),
    name: text('name').notNull(),
    email: text('email').notNull().unique(),
    passwordHash: text('password_hash').notNull(),
    role: text('role').notNull().default('user'),
    createdAt: timestamp('created_at').defaultNow().notNull(),
});
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_23499

mkdir -p "coverage/packages/core/src/db"
echo "作成: coverage/packages/core/src/db/index.html"
cat << 'EOF_1785916429_4929' > "coverage/packages/core/src/db/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/db</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> packages/core/src/db</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>4/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>4/4</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="index.ts"><a href="index.ts.html">index.ts</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="3" class="abs high">3/3</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="3" class="abs high">3/3</td>
	</tr>

<tr>
	<td class="file high" data-value="schema.ts"><a href="schema.ts.html">schema.ts</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="1" class="abs high">1/1</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="1" class="abs high">1/1</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_4929

mkdir -p "coverage/packages/core/src/db"
echo "作成: coverage/packages/core/src/db/index.ts.html"
cat << 'EOF_1785916429_19298' > "coverage/packages/core/src/db/index.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/db/index.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/core/src/db</a> index.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>3/3</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>3/3</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-yes">5x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';
import { validateEnv } from '../config/env';
&nbsp;
const env = validateEnv();
&nbsp;
// PostgreSQL 接続クライアントの作成
const queryClient = postgres(env.DATABASE_URL);
export const db = drizzle(queryClient, { schema });
&nbsp;
// 💡 スキーマも外部から参照できるように export します
export { schema };
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_19298

mkdir -p "coverage/packages/core/src/auth"
echo "作成: coverage/packages/core/src/auth/index.html"
cat << 'EOF_1785916429_25346' > "coverage/packages/core/src/auth/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/auth</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> packages/core/src/auth</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">42.85% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>3/7</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>2/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">42.85% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>3/7</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file low" data-value="auth-registry.ts"><a href="auth-registry.ts.html">auth-registry.ts</a></td>
	<td data-value="42.85" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 42%"></div><div class="cover-empty" style="width: 58%"></div></div>
	</td>
	<td data-value="42.85" class="pct low">42.85%</td>
	<td data-value="7" class="abs low">3/7</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="2" class="abs low">0/2</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="2" class="abs high">2/2</td>
	<td data-value="42.85" class="pct low">42.85%</td>
	<td data-value="7" class="abs low">3/7</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_25346

mkdir -p "coverage/packages/core/src/auth"
echo "作成: coverage/packages/core/src/auth/auth-registry.ts.html"
cat << 'EOF_1785916429_13549' > "coverage/packages/core/src/auth/auth-registry.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/auth/auth-registry.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/core/src/auth</a> auth-registry.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">42.85% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>3/7</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>2/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">42.85% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>3/7</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">export interface AuthPlugin {
  name: string;
  authenticate(credentials: any): Promise&lt;{ id: string; name: string }&gt;;
}
&nbsp;
export class AuthRegistry {
  private static strategies = new Map&lt;string, AuthPlugin&gt;();
&nbsp;
  static register(plugin: AuthPlugin) {
    this.strategies.set(plugin.name, plugin);
    console.log(`[AuthRegistry] Registered strategy: ${plugin.name}`);
  }
&nbsp;
  static async authenticate(strategy: string, credentials: any) {
    const plugin = <span class="cstat-no" title="statement not covered" >this.strategies.get(strategy);</span>
<span class="cstat-no" title="statement not covered" >    if (!plugin) {</span>
<span class="cstat-no" title="statement not covered" >      throw new Error(`Authentication strategy '${strategy}' not found.`);</span>
    }
<span class="cstat-no" title="statement not covered" >    return plugin.authenticate(credentials);</span>
  }
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_13549

mkdir -p "coverage/packages/core/src/errors"
echo "作成: coverage/packages/core/src/errors/index.html"
cat << 'EOF_1785916429_17277' > "coverage/packages/core/src/errors/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/errors</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> packages/core/src/errors</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">80% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>8/10</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">50% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>2/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">60% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>3/5</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">80% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>8/10</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="index.ts"><a href="index.ts.html">index.ts</a></td>
	<td data-value="80" class="pic high">
	<div class="chart"><div class="cover-fill" style="width: 80%"></div><div class="cover-empty" style="width: 20%"></div></div>
	</td>
	<td data-value="80" class="pct high">80%</td>
	<td data-value="10" class="abs high">8/10</td>
	<td data-value="50" class="pct medium">50%</td>
	<td data-value="4" class="abs medium">2/4</td>
	<td data-value="60" class="pct medium">60%</td>
	<td data-value="5" class="abs medium">3/5</td>
	<td data-value="80" class="pct high">80%</td>
	<td data-value="10" class="abs high">8/10</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_17277

mkdir -p "coverage/packages/core/src/errors"
echo "作成: coverage/packages/core/src/errors/index.ts.html"
cat << 'EOF_1785916429_17993' > "coverage/packages/core/src/errors/index.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/errors/index.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/core/src/errors</a> index.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">80% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>8/10</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">50% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>2/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">60% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>3/5</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">80% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>8/10</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a>
<a name='L28'></a><a href='#L28'>28</a>
<a name='L29'></a><a href='#L29'>29</a>
<a name='L30'></a><a href='#L30'>30</a>
<a name='L31'></a><a href='#L31'>31</a>
<a name='L32'></a><a href='#L32'>32</a>
<a name='L33'></a><a href='#L33'>33</a>
<a name='L34'></a><a href='#L34'>34</a>
<a name='L35'></a><a href='#L35'>35</a>
<a name='L36'></a><a href='#L36'>36</a>
<a name='L37'></a><a href='#L37'>37</a>
<a name='L38'></a><a href='#L38'>38</a>
<a name='L39'></a><a href='#L39'>39</a>
<a name='L40'></a><a href='#L40'>40</a>
<a name='L41'></a><a href='#L41'>41</a>
<a name='L42'></a><a href='#L42'>42</a>
<a name='L43'></a><a href='#L43'>43</a>
<a name='L44'></a><a href='#L44'>44</a>
<a name='L45'></a><a href='#L45'>45</a>
<a name='L46'></a><a href='#L46'>46</a>
<a name='L47'></a><a href='#L47'>47</a>
<a name='L48'></a><a href='#L48'>48</a>
<a name='L49'></a><a href='#L49'>49</a>
<a name='L50'></a><a href='#L50'>50</a>
<a name='L51'></a><a href='#L51'>51</a>
<a name='L52'></a><a href='#L52'>52</a>
<a name='L53'></a><a href='#L53'>53</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">export interface InvalidParam {
    name: string;
    reason: string;
}
&nbsp;
export interface ProblemDetails {
    type: string;
    title: string;
    status: number;
    detail: string;
    instance: string;
    invalidParams?: InvalidParam[];
}
&nbsp;
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
&nbsp;
export class NotFoundError extends AppError {
<span class="fstat-no" title="function not covered" >    constructor(m</span>essage = <span class="branch-0 cbranch-no" title="branch not covered" >'The requested resource was not found') {</span>
<span class="cstat-no" title="statement not covered" >        super(404, 'not-found', 'Not Found', message);</span>
    }
}
&nbsp;
export class InternalServerError extends AppError {
<span class="fstat-no" title="function not covered" >    constructor(m</span>essage = <span class="branch-0 cbranch-no" title="branch not covered" >'An unexpected error occurred') {</span>
<span class="cstat-no" title="statement not covered" >        super(500, 'internal-server-error', 'Internal Server Error', message);</span>
    }
}
&nbsp;
export class ValidationError extends AppError {
    constructor(
        public readonly invalidParams: InvalidParam[],
        message = 'Validation failed for the request payload'
    ) {
        super(400, 'validation-error', 'Bad Request', message);
    }
}
&nbsp;
export class UnauthorizedError extends AppError {
    constructor(message = 'Authentication token is missing or invalid') {
        super(401, 'unauthorized', 'Unauthorized', message);
    }
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_17993

mkdir -p "coverage/packages/core/src/test"
echo "作成: coverage/packages/core/src/test/global-setup.ts.html"
cat << 'EOF_1785916429_1113' > "coverage/packages/core/src/test/global-setup.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/test/global-setup.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/core/src/test</a> global-setup.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/9</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/9</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { execSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
&nbsp;
// import.meta.url から安全にパスを抽出
const __filename = <span class="cstat-no" title="statement not covered" >fileURLToPath(import.meta.url);</span>
const __dirname = <span class="cstat-no" title="statement not covered" >path.dirname(__filename);</span>
&nbsp;
export async function <span class="fstat-no" title="function not covered" >setup() {</span>
<span class="cstat-no" title="statement not covered" >    console.log('\n🔄 テスト用データベースに最新のスキーマを反映中...');</span>
&nbsp;
    // packages/core のルートディレクトリパスを解決
    const corePackageDir = <span class="cstat-no" title="statement not covered" >path.resolve(__dirname, '../../');</span>
&nbsp;
<span class="cstat-no" title="statement not covered" >    try {</span>
<span class="cstat-no" title="statement not covered" >        execSync('npx drizzle-kit push --config=drizzle-test.config.ts', {</span>
            cwd: corePackageDir,
            stdio: 'inherit',
        });
<span class="cstat-no" title="statement not covered" >        console.log('✅ テスト用データベースの準備完了!\n');</span>
    } catch (error) {
<span class="cstat-no" title="statement not covered" >        console.error('❌ テスト用データベースへのスキーマ反映に失敗しました:', error);</span>
<span class="cstat-no" title="statement not covered" >        throw error;</span>
    }
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_1113

mkdir -p "coverage/packages/core/src/test"
echo "作成: coverage/packages/core/src/test/index.html"
cat << 'EOF_1785916429_4061' > "coverage/packages/core/src/test/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/test</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> packages/core/src/test</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/9</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/9</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file low" data-value="global-setup.ts"><a href="global-setup.ts.html">global-setup.ts</a></td>
	<td data-value="0" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="9" class="abs low">0/9</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="1" class="abs low">0/1</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="9" class="abs low">0/9</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_4061

mkdir -p "coverage/packages/core/src"
echo "作成: coverage/packages/core/src/index.ts.html"
cat << 'EOF_1785916429_12592' > "coverage/packages/core/src/index.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/index.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> / <a href="index.html">packages/core/src</a> index.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">export * from './auth/auth-registry';
export * from './registry/hono-auto-loader';
export * from './db';
export * from './config/env';
export * from './errors';
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_12592

mkdir -p "coverage/packages/core/src"
echo "作成: coverage/packages/core/src/seed-dev-user.ts.html"
cat << 'EOF_1785916429_6123' > "coverage/packages/core/src/seed-dev-user.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/src/seed-dev-user.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> / <a href="index.html">packages/core/src</a> seed-dev-user.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/9</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/9</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { db } from './db'; // packages/core 内の db エクスポートのパス
import { users } from './db/schema'; // users スキーマ
import { hashPassword } from '@app/plugins-auth-local';
// packages/core にハッシュ関数（または bcrypt/argon2）があればそれを使用
&nbsp;
async function <span class="fstat-no" title="function not covered" >main() {</span>
    const email = <span class="cstat-no" title="statement not covered" >'mako65jp@gmail.com';</span>
    const password = <span class="cstat-no" title="statement not covered" >'1234'; // お好みのパスワード</span>
&nbsp;
    // もし core 内にハッシュ関数があれば使い、無ければ使っているライブラリでハッシュ化
    const hashedPassword = <span class="cstat-no" title="statement not covered" >await hashPassword(password);</span>
&nbsp;
<span class="cstat-no" title="statement not covered" >    await db.insert(users).values({</span>
        email,
        passwordHash: hashedPassword,
        name: '開発ユーザー',
    }).onConflictDoNothing();
&nbsp;
<span class="cstat-no" title="statement not covered" >    console.log(`✅ User created: ${email}`);</span>
<span class="cstat-no" title="statement not covered" >    process.exit(0);</span>
}
&nbsp;
<span class="cstat-no" title="statement not covered" >main().<span class="fstat-no" title="function not covered" >catch((e</span>rr) =&gt; {</span>
<span class="cstat-no" title="statement not covered" >    console.error('❌ Failed:', err);</span>
<span class="cstat-no" title="statement not covered" >    process.exit(1);</span>
});
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_6123

mkdir -p "coverage/packages/core"
echo "作成: coverage/packages/core/drizzle.config.ts.html"
cat << 'EOF_1785916429_17957' > "coverage/packages/core/drizzle.config.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/core/drizzle.config.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../prettify.css" />
    <link rel="stylesheet" href="../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../index.html">All files</a> / <a href="index.html">packages/core</a> drizzle.config.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { defineConfig } from 'drizzle-kit';
&nbsp;
export default defineConfig({
    // スキーマファイルの場所
    schema: './src/db/schema.ts',
&nbsp;
    // マイグレーションファイルの出力先（push の場合は参照のみ）
    out: './drizzle',
&nbsp;
    // 使用する DB ドライバー
    dialect: 'postgresql',
&nbsp;
    // 接続情報（.env から読み込み）
    dbCredentials: {
        url: process.env.DATABASE_URL || 'postgresql://postgres:postgres@db:5432/app_db_test',
    },
});
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../sorter.js"></script>
        <script src="../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_17957

mkdir -p "coverage/packages/features/sample/src"
echo "作成: coverage/packages/features/sample/src/index.html"
cat << 'EOF_1785916429_2919' > "coverage/packages/features/sample/src/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/features/sample/src</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> packages/features/sample/src</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>4/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>2/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>4/4</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="index.ts"><a href="index.ts.html">index.ts</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="4" class="abs high">4/4</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="2" class="abs high">2/2</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="4" class="abs high">4/4</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_2919

mkdir -p "coverage/packages/features/sample/src"
echo "作成: coverage/packages/features/sample/src/index.ts.html"
cat << 'EOF_1785916429_6285' > "coverage/packages/features/sample/src/index.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for packages/features/sample/src/index.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">packages/features/sample/src</a> index.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>4/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>2/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>4/4</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { Hono } from 'hono';
&nbsp;
export default function createSampleFeature() {
  const app = new Hono();
&nbsp;
  app.get('/sample', (c) =&gt; {
    return c.json({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });
&nbsp;
  return app;
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_6285

mkdir -p "coverage"
echo "作成: coverage/clover.xml"
cat << 'EOF_1785916429_1053' > "coverage/clover.xml"
<?xml version="1.0" encoding="UTF-8"?>
<coverage generated="1785897439564" clover="3.2.0">
  <project timestamp="1785897439564" name="All files">
    <metrics statements="234" coveredstatements="177" conditionals="91" coveredconditionals="47" methods="47" coveredmethods="36" elements="372" coveredelements="260" complexity="0" loc="234" ncloc="234" packages="17" files="24" classes="24"/>
    <package name="apps.api.src">
      <metrics statements="47" coveredstatements="42" conditionals="21" coveredconditionals="14" methods="7" coveredmethods="6"/>
      <file name="env.ts" path="/workspace/apps/api/src/env.ts">
        <metrics statements="5" coveredstatements="5" conditionals="3" coveredconditionals="3" methods="1" coveredmethods="1"/>
        <line num="3" count="1" type="stmt"/>
        <line num="9" count="2" type="stmt"/>
        <line num="10" count="2" type="cond" truecount="2" falsecount="0"/>
        <line num="11" count="1" type="stmt"/>
        <line num="13" count="1" type="stmt"/>
      </file>
      <file name="index.ts" path="/workspace/apps/api/src/index.ts">
        <metrics statements="42" coveredstatements="37" conditionals="18" coveredconditionals="11" methods="6" coveredmethods="5"/>
        <line num="14" count="1" type="stmt"/>
        <line num="17" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="18" count="0" type="stmt"/>
        <line num="22" count="1" type="stmt"/>
        <line num="23" count="1" type="stmt"/>
        <line num="25" count="1" type="stmt"/>
        <line num="30" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="31" count="1" type="stmt"/>
        <line num="32" count="1" type="stmt"/>
        <line num="40" count="1" type="stmt"/>
        <line num="42" count="1" type="stmt"/>
        <line num="47" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="48" count="1" type="stmt"/>
        <line num="53" count="1" type="stmt"/>
        <line num="56" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="58" count="2" type="stmt"/>
        <line num="63" count="1" type="stmt"/>
        <line num="67" count="0" type="stmt"/>
        <line num="75" count="1" type="stmt"/>
        <line num="76" count="1" type="stmt"/>
        <line num="83" count="1" type="stmt"/>
        <line num="89" count="1" type="stmt"/>
        <line num="90" count="2" type="cond" truecount="1" falsecount="1"/>
        <line num="91" count="0" type="stmt"/>
        <line num="94" count="2" type="stmt"/>
        <line num="95" count="2" type="stmt"/>
        <line num="96" count="2" type="stmt"/>
        <line num="97" count="2" type="stmt"/>
        <line num="98" count="2" type="stmt"/>
        <line num="100" count="2" type="cond" truecount="2" falsecount="0"/>
        <line num="101" count="1" type="stmt"/>
        <line num="102" count="1" type="stmt"/>
        <line num="103" count="1" type="stmt"/>
        <line num="104" count="1" type="stmt"/>
        <line num="107" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="108" count="1" type="stmt"/>
        <line num="112" count="2" type="stmt"/>
        <line num="121" count="2" type="stmt"/>
        <line num="127" count="1" type="stmt"/>
        <line num="130" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="131" count="0" type="stmt"/>
        <line num="132" count="0" type="stmt"/>
      </file>
    </package>
    <package name="apps.api.src.middlewares">
      <metrics statements="10" coveredstatements="10" conditionals="6" coveredconditionals="6" methods="2" coveredmethods="2"/>
      <file name="auth-middleware.ts" path="/workspace/apps/api/src/middlewares/auth-middleware.ts">
        <metrics statements="10" coveredstatements="10" conditionals="6" coveredconditionals="6" methods="2" coveredmethods="2"/>
        <line num="16" count="7" type="stmt"/>
        <line num="17" count="4" type="stmt"/>
        <line num="20" count="4" type="cond" truecount="4" falsecount="0"/>
        <line num="21" count="1" type="stmt"/>
        <line num="25" count="3" type="stmt"/>
        <line num="26" count="3" type="stmt"/>
        <line num="28" count="3" type="cond" truecount="2" falsecount="0"/>
        <line num="29" count="1" type="stmt"/>
        <line num="33" count="2" type="stmt"/>
        <line num="34" count="2" type="stmt"/>
      </file>
    </package>
    <package name="apps.api.src.routes">
      <metrics statements="20" coveredstatements="18" conditionals="6" coveredconditionals="4" methods="3" coveredmethods="3"/>
      <file name="auth.ts" path="/workspace/apps/api/src/routes/auth.ts">
        <metrics statements="20" coveredstatements="18" conditionals="6" coveredconditionals="4" methods="3" coveredmethods="3"/>
        <line num="9" count="2" type="stmt"/>
        <line num="18" count="4" type="stmt"/>
        <line num="23" count="4" type="stmt"/>
        <line num="24" count="3" type="stmt"/>
        <line num="25" count="3" type="stmt"/>
        <line num="27" count="3" type="cond" truecount="1" falsecount="1"/>
        <line num="28" count="0" type="stmt"/>
        <line num="31" count="3" type="stmt"/>
        <line num="34" count="3" type="stmt"/>
        <line num="38" count="3" type="cond" truecount="1" falsecount="1"/>
        <line num="40" count="0" type="stmt"/>
        <line num="44" count="3" type="stmt"/>
        <line num="45" count="3" type="cond" truecount="2" falsecount="0"/>
        <line num="46" count="1" type="stmt"/>
        <line num="50" count="2" type="stmt"/>
        <line num="59" count="2" type="stmt"/>
        <line num="72" count="4" type="stmt"/>
        <line num="73" count="1" type="stmt"/>
        <line num="75" count="1" type="stmt"/>
        <line num="84" count="4" type="stmt"/>
      </file>
    </package>
    <package name="apps.web.src">
      <metrics statements="8" coveredstatements="0" conditionals="8" coveredconditionals="0" methods="2" coveredmethods="0"/>
      <file name="App.tsx" path="/workspace/apps/web/src/App.tsx">
        <metrics statements="6" coveredstatements="0" conditionals="8" coveredconditionals="0" methods="2" coveredmethods="0"/>
        <line num="5" count="0" type="stmt"/>
        <line num="6" count="0" type="stmt"/>
        <line num="8" count="0" type="cond" truecount="0" falsecount="2"/>
        <line num="9" count="0" type="stmt"/>
        <line num="12" count="0" type="stmt"/>
        <line num="38" count="0" type="stmt"/>
      </file>
      <file name="env.ts" path="/workspace/apps/web/src/env.ts">
        <metrics statements="1" coveredstatements="0" conditionals="0" coveredconditionals="0" methods="0" coveredmethods="0"/>
        <line num="4" count="0" type="stmt"/>
      </file>
      <file name="main.tsx" path="/workspace/apps/web/src/main.tsx">
        <metrics statements="1" coveredstatements="0" conditionals="0" coveredconditionals="0" methods="0" coveredmethods="0"/>
        <line num="5" count="0" type="stmt"/>
      </file>
    </package>
    <package name="apps.web.src.components">
      <metrics statements="19" coveredstatements="19" conditionals="8" coveredconditionals="6" methods="4" coveredmethods="4"/>
      <file name="LoginForm.tsx" path="/workspace/apps/web/src/components/LoginForm.tsx">
        <metrics statements="19" coveredstatements="19" conditionals="8" coveredconditionals="6" methods="4" coveredmethods="4"/>
        <line num="8" count="1" type="stmt"/>
        <line num="9" count="11" type="stmt"/>
        <line num="10" count="11" type="stmt"/>
        <line num="11" count="11" type="stmt"/>
        <line num="12" count="11" type="stmt"/>
        <line num="13" count="11" type="stmt"/>
        <line num="15" count="11" type="stmt"/>
        <line num="16" count="2" type="stmt"/>
        <line num="17" count="2" type="stmt"/>
        <line num="18" count="2" type="stmt"/>
        <line num="20" count="2" type="stmt"/>
        <line num="21" count="2" type="stmt"/>
        <line num="22" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="23" count="1" type="stmt"/>
        <line num="26" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="28" count="2" type="stmt"/>
        <line num="32" count="11" type="stmt"/>
        <line num="46" count="2" type="stmt"/>
        <line num="58" count="2" type="stmt"/>
      </file>
    </package>
    <package name="apps.web.src.context">
      <metrics statements="45" coveredstatements="35" conditionals="10" coveredconditionals="5" methods="8" coveredmethods="7"/>
      <file name="AuthContext.tsx" path="/workspace/apps/web/src/context/AuthContext.tsx">
        <metrics statements="45" coveredstatements="35" conditionals="10" coveredconditionals="5" methods="8" coveredmethods="7"/>
        <line num="21" count="2" type="stmt"/>
        <line num="23" count="2" type="stmt"/>
        <line num="24" count="8" type="stmt"/>
        <line num="25" count="8" type="stmt"/>
        <line num="26" count="8" type="stmt"/>
        <line num="29" count="8" type="stmt"/>
        <line num="30" count="3" type="stmt"/>
        <line num="31" count="3" type="stmt"/>
        <line num="32" count="3" type="cond" truecount="2" falsecount="0"/>
        <line num="33" count="2" type="stmt"/>
        <line num="34" count="2" type="stmt"/>
        <line num="37" count="1" type="stmt"/>
        <line num="38" count="1" type="stmt"/>
        <line num="44" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="45" count="1" type="stmt"/>
        <line num="46" count="1" type="stmt"/>
        <line num="47" count="1" type="stmt"/>
        <line num="49" count="0" type="stmt"/>
        <line num="50" count="0" type="stmt"/>
        <line num="51" count="0" type="stmt"/>
        <line num="54" count="0" type="stmt"/>
        <line num="55" count="0" type="stmt"/>
        <line num="56" count="0" type="stmt"/>
        <line num="57" count="0" type="stmt"/>
        <line num="59" count="1" type="stmt"/>
        <line num="63" count="3" type="stmt"/>
        <line num="67" count="8" type="stmt"/>
        <line num="68" count="1" type="stmt"/>
        <line num="76" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="77" count="0" type="stmt"/>
        <line num="78" count="0" type="cond" truecount="0" falsecount="2"/>
        <line num="81" count="1" type="stmt"/>
        <line num="82" count="1" type="stmt"/>
        <line num="83" count="1" type="stmt"/>
        <line num="84" count="1" type="stmt"/>
        <line num="88" count="8" type="stmt"/>
        <line num="89" count="1" type="stmt"/>
        <line num="90" count="1" type="stmt"/>
        <line num="91" count="1" type="stmt"/>
        <line num="94" count="8" type="stmt"/>
        <line num="110" count="2" type="stmt"/>
        <line num="111" count="19" type="stmt"/>
        <line num="112" count="19" type="cond" truecount="1" falsecount="1"/>
        <line num="113" count="0" type="stmt"/>
        <line num="115" count="19" type="stmt"/>
      </file>
    </package>
    <package name="packages.core">
      <metrics statements="0" coveredstatements="0" conditionals="4" coveredconditionals="0" methods="0" coveredmethods="0"/>
      <file name="drizzle-test.config.ts" path="/workspace/packages/core/drizzle-test.config.ts">
        <metrics statements="0" coveredstatements="0" conditionals="2" coveredconditionals="0" methods="0" coveredmethods="0"/>
      </file>
      <file name="drizzle.config.ts" path="/workspace/packages/core/drizzle.config.ts">
        <metrics statements="0" coveredstatements="0" conditionals="2" coveredconditionals="0" methods="0" coveredmethods="0"/>
      </file>
    </package>
    <package name="packages.core.src">
      <metrics statements="9" coveredstatements="0" conditionals="0" coveredconditionals="0" methods="2" coveredmethods="0"/>
      <file name="index.ts" path="/workspace/packages/core/src/index.ts">
        <metrics statements="0" coveredstatements="0" conditionals="0" coveredconditionals="0" methods="0" coveredmethods="0"/>
      </file>
      <file name="seed-dev-user.ts" path="/workspace/packages/core/src/seed-dev-user.ts">
        <metrics statements="9" coveredstatements="0" conditionals="0" coveredconditionals="0" methods="2" coveredmethods="0"/>
        <line num="7" count="0" type="stmt"/>
        <line num="8" count="0" type="stmt"/>
        <line num="11" count="0" type="stmt"/>
        <line num="13" count="0" type="stmt"/>
        <line num="19" count="0" type="stmt"/>
        <line num="20" count="0" type="stmt"/>
        <line num="23" count="0" type="stmt"/>
        <line num="24" count="0" type="stmt"/>
        <line num="25" count="0" type="stmt"/>
      </file>
    </package>
    <package name="packages.core.src.auth">
      <metrics statements="7" coveredstatements="3" conditionals="2" coveredconditionals="0" methods="2" coveredmethods="2"/>
      <file name="auth-registry.ts" path="/workspace/packages/core/src/auth/auth-registry.ts">
        <metrics statements="7" coveredstatements="3" conditionals="2" coveredconditionals="0" methods="2" coveredmethods="2"/>
        <line num="7" count="3" type="stmt"/>
        <line num="10" count="2" type="stmt"/>
        <line num="11" count="2" type="stmt"/>
        <line num="15" count="0" type="stmt"/>
        <line num="16" count="0" type="cond" truecount="0" falsecount="2"/>
        <line num="17" count="0" type="stmt"/>
        <line num="19" count="0" type="stmt"/>
      </file>
    </package>
    <package name="packages.core.src.config">
      <metrics statements="13" coveredstatements="13" conditionals="9" coveredconditionals="6" methods="2" coveredmethods="2"/>
      <file name="env.ts" path="/workspace/packages/core/src/config/env.ts">
        <metrics statements="13" coveredstatements="13" conditionals="9" coveredconditionals="6" methods="2" coveredmethods="2"/>
        <line num="6" count="5" type="stmt"/>
        <line num="19" count="10" type="stmt"/>
        <line num="21" count="10" type="cond" truecount="2" falsecount="0"/>
        <line num="22" count="2" type="stmt"/>
        <line num="23" count="2" type="stmt"/>
        <line num="24" count="2" type="stmt"/>
        <line num="27" count="8" type="stmt"/>
        <line num="34" count="1" type="stmt"/>
        <line num="36" count="1" type="cond" truecount="1" falsecount="1"/>
        <line num="37" count="1" type="stmt"/>
        <line num="43" count="1" type="stmt"/>
        <line num="48" count="5" type="cond" truecount="1" falsecount="1"/>
        <line num="58" count="5" type="stmt"/>
      </file>
    </package>
    <package name="packages.core.src.db">
      <metrics statements="4" coveredstatements="4" conditionals="0" coveredconditionals="0" methods="0" coveredmethods="0"/>
      <file name="index.ts" path="/workspace/packages/core/src/db/index.ts">
        <metrics statements="3" coveredstatements="3" conditionals="0" coveredconditionals="0" methods="0" coveredmethods="0"/>
        <line num="6" count="5" type="stmt"/>
        <line num="9" count="5" type="stmt"/>
        <line num="10" count="5" type="stmt"/>
      </file>
      <file name="schema.ts" path="/workspace/packages/core/src/db/schema.ts">
        <metrics statements="1" coveredstatements="1" conditionals="0" coveredconditionals="0" methods="0" coveredmethods="0"/>
        <line num="3" count="5" type="stmt"/>
      </file>
    </package>
    <package name="packages.core.src.errors">
      <metrics statements="10" coveredstatements="8" conditionals="4" coveredconditionals="2" methods="5" coveredmethods="3"/>
      <file name="index.ts" path="/workspace/packages/core/src/errors/index.ts">
        <metrics statements="10" coveredstatements="8" conditionals="4" coveredconditionals="2" methods="5" coveredmethods="3"/>
        <line num="17" count="4" type="stmt"/>
        <line num="18" count="4" type="stmt"/>
        <line num="19" count="4" type="stmt"/>
        <line num="22" count="4" type="stmt"/>
        <line num="23" count="4" type="stmt"/>
        <line num="29" count="0" type="stmt"/>
        <line num="35" count="0" type="stmt"/>
        <line num="41" count="1" type="stmt"/>
        <line num="44" count="1" type="stmt"/>
        <line num="50" count="3" type="stmt"/>
      </file>
    </package>
    <package name="packages.core.src.registry">
      <metrics statements="9" coveredstatements="9" conditionals="4" coveredconditionals="3" methods="1" coveredmethods="1"/>
      <file name="hono-auto-loader.ts" path="/workspace/packages/core/src/registry/hono-auto-loader.ts">
        <metrics statements="9" coveredstatements="9" conditionals="4" coveredconditionals="3" methods="1" coveredmethods="1"/>
        <line num="7" count="1" type="stmt"/>
        <line num="8" count="1" type="stmt"/>
        <line num="9" count="1" type="stmt"/>
        <line num="12" count="1" type="stmt"/>
        <line num="14" count="1" type="stmt"/>
        <line num="16" count="1" type="cond" truecount="3" falsecount="1"/>
        <line num="17" count="1" type="stmt"/>
        <line num="18" count="1" type="stmt"/>
        <line num="19" count="1" type="stmt"/>
      </file>
    </package>
    <package name="packages.core.src.test">
      <metrics statements="9" coveredstatements="0" conditionals="0" coveredconditionals="0" methods="1" coveredmethods="0"/>
      <file name="global-setup.ts" path="/workspace/packages/core/src/test/global-setup.ts">
        <metrics statements="9" coveredstatements="0" conditionals="0" coveredconditionals="0" methods="1" coveredmethods="0"/>
        <line num="6" count="0" type="stmt"/>
        <line num="7" count="0" type="stmt"/>
        <line num="10" count="0" type="stmt"/>
        <line num="13" count="0" type="stmt"/>
        <line num="15" count="0" type="stmt"/>
        <line num="16" count="0" type="stmt"/>
        <line num="20" count="0" type="stmt"/>
        <line num="22" count="0" type="stmt"/>
        <line num="23" count="0" type="stmt"/>
      </file>
    </package>
    <package name="packages.features.sample.src">
      <metrics statements="4" coveredstatements="4" conditionals="0" coveredconditionals="0" methods="2" coveredmethods="2"/>
      <file name="index.ts" path="/workspace/packages/features/sample/src/index.ts">
        <metrics statements="4" coveredstatements="4" conditionals="0" coveredconditionals="0" methods="2" coveredmethods="2"/>
        <line num="4" count="2" type="stmt"/>
        <line num="6" count="2" type="stmt"/>
        <line num="7" count="2" type="stmt"/>
        <line num="10" count="2" type="stmt"/>
      </file>
    </package>
    <package name="packages.plugins.auth-ad.src">
      <metrics statements="5" coveredstatements="1" conditionals="4" coveredconditionals="0" methods="1" coveredmethods="0"/>
      <file name="index.ts" path="/workspace/packages/plugins/auth-ad/src/index.ts">
        <metrics statements="5" coveredstatements="1" conditionals="4" coveredconditionals="0" methods="1" coveredmethods="0"/>
        <line num="4" count="1" type="stmt"/>
        <line num="7" count="0" type="stmt"/>
        <line num="8" count="0" type="cond" truecount="0" falsecount="4"/>
        <line num="9" count="0" type="stmt"/>
        <line num="11" count="0" type="stmt"/>
      </file>
    </package>
    <package name="packages.plugins.auth-local.src">
      <metrics statements="15" coveredstatements="11" conditionals="5" coveredconditionals="1" methods="5" coveredmethods="4"/>
      <file name="auth-utils.ts" path="/workspace/packages/plugins/auth-local/src/auth-utils.ts">
        <metrics statements="10" coveredstatements="10" conditionals="1" coveredconditionals="1" methods="4" coveredmethods="4"/>
        <line num="12" count="5" type="stmt"/>
        <line num="13" count="5" type="stmt"/>
        <line num="20" count="5" type="stmt"/>
        <line num="35" count="5" type="stmt"/>
        <line num="37" count="5" type="stmt"/>
        <line num="52" count="6" type="stmt"/>
        <line num="53" count="6" type="stmt"/>
        <line num="54" count="6" type="stmt"/>
        <line num="55" count="3" type="stmt"/>
        <line num="58" count="3" type="stmt"/>
      </file>
      <file name="index.ts" path="/workspace/packages/plugins/auth-local/src/index.ts">
        <metrics statements="5" coveredstatements="1" conditionals="4" coveredconditionals="0" methods="1" coveredmethods="0"/>
        <line num="4" count="1" type="stmt"/>
        <line num="7" count="0" type="stmt"/>
        <line num="8" count="0" type="cond" truecount="0" falsecount="4"/>
        <line num="9" count="0" type="stmt"/>
        <line num="11" count="0" type="stmt"/>
      </file>
    </package>
  </project>
</coverage>
EOF_1785916429_1053

mkdir -p "coverage"
echo "作成: coverage/base.css"
cat << 'EOF_1785916429_6348' > "coverage/base.css"
body, html {
  margin:0; padding: 0;
  height: 100%;
}
body {
    font-family: Helvetica Neue, Helvetica, Arial;
    font-size: 14px;
    color:#333;
}
.small { font-size: 12px; }
*, *:after, *:before {
  -webkit-box-sizing:border-box;
     -moz-box-sizing:border-box;
          box-sizing:border-box;
  }
h1 { font-size: 20px; margin: 0;}
h2 { font-size: 14px; }
pre {
    font: 12px/1.4 Consolas, "Liberation Mono", Menlo, Courier, monospace;
    margin: 0;
    padding: 0;
    -moz-tab-size: 2;
    -o-tab-size:  2;
    tab-size: 2;
}
a { color:#0074D9; text-decoration:none; }
a:hover { text-decoration:underline; }
.strong { font-weight: bold; }
.space-top1 { padding: 10px 0 0 0; }
.pad2y { padding: 20px 0; }
.pad1y { padding: 10px 0; }
.pad2x { padding: 0 20px; }
.pad2 { padding: 20px; }
.pad1 { padding: 10px; }
.space-left2 { padding-left:55px; }
.space-right2 { padding-right:20px; }
.center { text-align:center; }
.clearfix { display:block; }
.clearfix:after {
  content:'';
  display:block;
  height:0;
  clear:both;
  visibility:hidden;
  }
.fl { float: left; }
@media only screen and (max-width:640px) {
  .col3 { width:100%; max-width:100%; }
  .hide-mobile { display:none!important; }
}

.quiet {
  color: #7f7f7f;
  color: rgba(0,0,0,0.5);
}
.quiet a { opacity: 0.7; }

.fraction {
  font-family: Consolas, 'Liberation Mono', Menlo, Courier, monospace;
  font-size: 10px;
  color: #555;
  background: #E8E8E8;
  padding: 4px 5px;
  border-radius: 3px;
  vertical-align: middle;
}

div.path a:link, div.path a:visited { color: #333; }
table.coverage {
  border-collapse: collapse;
  margin: 10px 0 0 0;
  padding: 0;
}

table.coverage td {
  margin: 0;
  padding: 0;
  vertical-align: top;
}
table.coverage td.line-count {
    text-align: right;
    padding: 0 5px 0 20px;
}
table.coverage td.line-coverage {
    text-align: right;
    padding-right: 10px;
    min-width:20px;
}

table.coverage td span.cline-any {
    display: inline-block;
    padding: 0 5px;
    width: 100%;
}
.missing-if-branch {
    display: inline-block;
    margin-right: 5px;
    border-radius: 3px;
    position: relative;
    padding: 0 4px;
    background: #333;
    color: yellow;
}

.skip-if-branch {
    display: none;
    margin-right: 10px;
    position: relative;
    padding: 0 4px;
    background: #ccc;
    color: white;
}
.missing-if-branch .typ, .skip-if-branch .typ {
    color: inherit !important;
}
.coverage-summary {
  border-collapse: collapse;
  width: 100%;
}
.coverage-summary tr { border-bottom: 1px solid #bbb; }
.keyline-all { border: 1px solid #ddd; }
.coverage-summary td, .coverage-summary th { padding: 10px; }
.coverage-summary tbody { border: 1px solid #bbb; }
.coverage-summary td { border-right: 1px solid #bbb; }
.coverage-summary td:last-child { border-right: none; }
.coverage-summary th {
  text-align: left;
  font-weight: normal;
  white-space: nowrap;
}
.coverage-summary th.file { border-right: none !important; }
.coverage-summary th.pct { }
.coverage-summary th.pic,
.coverage-summary th.abs,
.coverage-summary td.pct,
.coverage-summary td.abs { text-align: right; }
.coverage-summary td.file { white-space: nowrap;  }
.coverage-summary td.pic { min-width: 120px !important;  }
.coverage-summary tfoot td { }

.coverage-summary .sorter {
    height: 10px;
    width: 7px;
    display: inline-block;
    margin-left: 0.5em;
    background: url(sort-arrow-sprite.png) no-repeat scroll 0 0 transparent;
}
.coverage-summary .sorted .sorter {
    background-position: 0 -20px;
}
.coverage-summary .sorted-desc .sorter {
    background-position: 0 -10px;
}
.status-line {  height: 10px; }
/* yellow */
.cbranch-no { background: yellow !important; color: #111; }
/* dark red */
.red.solid, .status-line.low, .low .cover-fill { background:#C21F39 }
.low .chart { border:1px solid #C21F39 }
.highlighted,
.highlighted .cstat-no, .highlighted .fstat-no, .highlighted .cbranch-no{
  background: #C21F39 !important;
}
/* medium red */
.cstat-no, .fstat-no, .cbranch-no, .cbranch-no { background:#F6C6CE }
/* light red */
.low, .cline-no { background:#FCE1E5 }
/* light green */
.high, .cline-yes { background:rgb(230,245,208) }
/* medium green */
.cstat-yes { background:rgb(161,215,106) }
/* dark green */
.status-line.high, .high .cover-fill { background:rgb(77,146,33) }
.high .chart { border:1px solid rgb(77,146,33) }
/* dark yellow (gold) */
.status-line.medium, .medium .cover-fill { background: #f9cd0b; }
.medium .chart { border:1px solid #f9cd0b; }
/* light yellow */
.medium { background: #fff4c2; }

.cstat-skip { background: #ddd; color: #111; }
.fstat-skip { background: #ddd; color: #111 !important; }
.cbranch-skip { background: #ddd !important; color: #111; }

span.cline-neutral { background: #eaeaea; }

.coverage-summary td.empty {
    opacity: .5;
    padding-top: 4px;
    padding-bottom: 4px;
    line-height: 1;
    color: #888;
}

.cover-fill, .cover-empty {
  display:inline-block;
  height: 12px;
}
.chart {
  line-height: 0;
}
.cover-empty {
    background: white;
}
.cover-full {
    border-right: none !important;
}
pre.prettyprint {
    border: none !important;
    padding: 0 !important;
    margin: 0 !important;
}
.com { color: #999 !important; }
.ignore-none { color: #999; font-weight: normal; }

.wrapper {
  min-height: 100%;
  height: auto !important;
  height: 100%;
  margin: 0 auto -48px;
}
.footer, .push {
  height: 48px;
}
EOF_1785916429_6348

mkdir -p "coverage/apps/web/src"
echo "作成: coverage/apps/web/src/index.html"
cat << 'EOF_1785916429_30253' > "coverage/apps/web/src/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/web/src</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> apps/web/src</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/8</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/8</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/8</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file low" data-value="App.tsx"><a href="App.tsx.html">App.tsx</a></td>
	<td data-value="0" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="6" class="abs low">0/6</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="8" class="abs low">0/8</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="2" class="abs low">0/2</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="6" class="abs low">0/6</td>
	</tr>

<tr>
	<td class="file low" data-value="env.ts"><a href="env.ts.html">env.ts</a></td>
	<td data-value="0" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="1" class="abs low">0/1</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="1" class="abs low">0/1</td>
	</tr>

<tr>
	<td class="file low" data-value="main.tsx"><a href="main.tsx.html">main.tsx</a></td>
	<td data-value="0" class="pic low">
	<div class="chart"><div class="cover-fill" style="width: 0%"></div><div class="cover-empty" style="width: 100%"></div></div>
	</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="1" class="abs low">0/1</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="0" class="abs high">0/0</td>
	<td data-value="0" class="pct low">0%</td>
	<td data-value="1" class="abs low">0/1</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_30253

mkdir -p "coverage/apps/web/src"
echo "作成: coverage/apps/web/src/main.tsx.html"
cat << 'EOF_1785916429_10624' > "coverage/apps/web/src/main.tsx.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/web/src/main.tsx</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> / <a href="index.html">apps/web/src</a> main.tsx</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/1</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';
&nbsp;
<span class="cstat-no" title="statement not covered" >ReactDOM.createRoot(document.getElementById('root')!).render(</span>
  &lt;React.StrictMode&gt;
    &lt;App /&gt;
  &lt;/React.StrictMode&gt;
);
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_10624

mkdir -p "coverage/apps/web/src"
echo "作成: coverage/apps/web/src/env.ts.html"
cat << 'EOF_1785916429_10617' > "coverage/apps/web/src/env.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/web/src/env.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> / <a href="index.html">apps/web/src</a> env.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/0</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/1</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { clientEnvSchema, type ClientEnv } from '@app/core';
&nbsp;
// Vite の import.meta.env を Zod で検証・補完
export const env: ClientEnv = <span class="cstat-no" title="statement not covered" >clientEnvSchema.parse({</span>
    VITE_PORT: import.meta.env.VITE_PORT,
    VITE_API_TARGET_URL: import.meta.env.VITE_API_TARGET_URL,
    VITE_APP_TITLE: import.meta.env.VITE_APP_TITLE,
});
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_10617

mkdir -p "coverage/apps/web/src"
echo "作成: coverage/apps/web/src/App.tsx.html"
cat << 'EOF_1785916429_25083' > "coverage/apps/web/src/App.tsx.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/web/src/App.tsx</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> / <a href="index.html">apps/web/src</a> App.tsx</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>0/6</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>0/8</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>0/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">0% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>0/6</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line low'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a>
<a name='L28'></a><a href='#L28'>28</a>
<a name='L29'></a><a href='#L29'>29</a>
<a name='L30'></a><a href='#L30'>30</a>
<a name='L31'></a><a href='#L31'>31</a>
<a name='L32'></a><a href='#L32'>32</a>
<a name='L33'></a><a href='#L33'>33</a>
<a name='L34'></a><a href='#L34'>34</a>
<a name='L35'></a><a href='#L35'>35</a>
<a name='L36'></a><a href='#L36'>36</a>
<a name='L37'></a><a href='#L37'>37</a>
<a name='L38'></a><a href='#L38'>38</a>
<a name='L39'></a><a href='#L39'>39</a>
<a name='L40'></a><a href='#L40'>40</a>
<a name='L41'></a><a href='#L41'>41</a>
<a name='L42'></a><a href='#L42'>42</a>
<a name='L43'></a><a href='#L43'>43</a>
<a name='L44'></a><a href='#L44'>44</a>
<a name='L45'></a><a href='#L45'>45</a>
<a name='L46'></a><a href='#L46'>46</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import React from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { LoginForm } from './components/LoginForm';
&nbsp;
const <span class="cstat-no" title="statement not covered" ><span class="fstat-no" title="function not covered" >MainContent: React.FC = () =&gt; {</span></span>
  const { user, logout, isAuthenticated, isLoading } = <span class="cstat-no" title="statement not covered" >useAuth()</span>;
&nbsp;
<span class="cstat-no" title="statement not covered" >  if (isLoading) {</span>
<span class="cstat-no" title="statement not covered" >    return &lt;div&gt;読み込み中...&lt;/div&gt;;</span>
  }
&nbsp;
<span class="cstat-no" title="statement not covered" >  return (</span>
    &lt;main style={{ padding: '2rem', fontFamily: 'sans-serif' }}&gt;
      &lt;h1&gt;DevContainer + Docker Compose マイアプリケーション&lt;/h1&gt;
&nbsp;
      {isAuthenticated &amp;&amp; user ? (
        &lt;div style={{ marginTop: '1rem', padding: '1rem', border: '1px solid #ccc', borderRadius: '4px' }}&gt;
          &lt;h2&gt;ようこそ、{user.name || user.email} さん！&lt;/h2&gt;
          &lt;p&gt;&lt;strong&gt;Email:&lt;/strong&gt; {user.email}&lt;/p&gt;
          &lt;p&gt;&lt;strong&gt;ID:&lt;/strong&gt; {user.id}&lt;/p&gt;
          &lt;button
            onClick={logout}
            style={{ padding: '0.5rem 1rem', marginTop: '1rem', cursor: 'pointer' }}
          &gt;
            ログアウト
          &lt;/button&gt;
        &lt;/div&gt;
      ) : (
        &lt;div style={{ marginTop: '1rem' }}&gt;
          &lt;LoginForm /&gt;
        &lt;/div&gt;
      )}
    &lt;/main&gt;
  );
};
&nbsp;
export function <span class="fstat-no" title="function not covered" >App() {</span>
<span class="cstat-no" title="statement not covered" >  return (</span>
    &lt;AuthProvider&gt;
      &lt;MainContent /&gt;
    &lt;/AuthProvider&gt;
  );
}
&nbsp;
export default App;
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_25083

mkdir -p "coverage/apps/web/src/context"
echo "作成: coverage/apps/web/src/context/index.html"
cat << 'EOF_1785916429_14120' > "coverage/apps/web/src/context/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/web/src/context</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> apps/web/src/context</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">76.59% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>36/47</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">50% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>5/10</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">87.5% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>7/8</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">77.77% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>35/45</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line medium'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file medium" data-value="AuthContext.tsx"><a href="AuthContext.tsx.html">AuthContext.tsx</a></td>
	<td data-value="76.59" class="pic medium">
	<div class="chart"><div class="cover-fill" style="width: 76%"></div><div class="cover-empty" style="width: 24%"></div></div>
	</td>
	<td data-value="76.59" class="pct medium">76.59%</td>
	<td data-value="47" class="abs medium">36/47</td>
	<td data-value="50" class="pct medium">50%</td>
	<td data-value="10" class="abs medium">5/10</td>
	<td data-value="87.5" class="pct high">87.5%</td>
	<td data-value="8" class="abs high">7/8</td>
	<td data-value="77.77" class="pct medium">77.77%</td>
	<td data-value="45" class="abs medium">35/45</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_14120

mkdir -p "coverage/apps/web/src/context"
echo "作成: coverage/apps/web/src/context/AuthContext.tsx.html"
cat << 'EOF_1785916429_25098' > "coverage/apps/web/src/context/AuthContext.tsx.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/web/src/context/AuthContext.tsx</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">apps/web/src/context</a> AuthContext.tsx</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">76.59% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>36/47</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">50% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>5/10</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">87.5% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>7/8</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">77.77% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>35/45</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line medium'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a>
<a name='L28'></a><a href='#L28'>28</a>
<a name='L29'></a><a href='#L29'>29</a>
<a name='L30'></a><a href='#L30'>30</a>
<a name='L31'></a><a href='#L31'>31</a>
<a name='L32'></a><a href='#L32'>32</a>
<a name='L33'></a><a href='#L33'>33</a>
<a name='L34'></a><a href='#L34'>34</a>
<a name='L35'></a><a href='#L35'>35</a>
<a name='L36'></a><a href='#L36'>36</a>
<a name='L37'></a><a href='#L37'>37</a>
<a name='L38'></a><a href='#L38'>38</a>
<a name='L39'></a><a href='#L39'>39</a>
<a name='L40'></a><a href='#L40'>40</a>
<a name='L41'></a><a href='#L41'>41</a>
<a name='L42'></a><a href='#L42'>42</a>
<a name='L43'></a><a href='#L43'>43</a>
<a name='L44'></a><a href='#L44'>44</a>
<a name='L45'></a><a href='#L45'>45</a>
<a name='L46'></a><a href='#L46'>46</a>
<a name='L47'></a><a href='#L47'>47</a>
<a name='L48'></a><a href='#L48'>48</a>
<a name='L49'></a><a href='#L49'>49</a>
<a name='L50'></a><a href='#L50'>50</a>
<a name='L51'></a><a href='#L51'>51</a>
<a name='L52'></a><a href='#L52'>52</a>
<a name='L53'></a><a href='#L53'>53</a>
<a name='L54'></a><a href='#L54'>54</a>
<a name='L55'></a><a href='#L55'>55</a>
<a name='L56'></a><a href='#L56'>56</a>
<a name='L57'></a><a href='#L57'>57</a>
<a name='L58'></a><a href='#L58'>58</a>
<a name='L59'></a><a href='#L59'>59</a>
<a name='L60'></a><a href='#L60'>60</a>
<a name='L61'></a><a href='#L61'>61</a>
<a name='L62'></a><a href='#L62'>62</a>
<a name='L63'></a><a href='#L63'>63</a>
<a name='L64'></a><a href='#L64'>64</a>
<a name='L65'></a><a href='#L65'>65</a>
<a name='L66'></a><a href='#L66'>66</a>
<a name='L67'></a><a href='#L67'>67</a>
<a name='L68'></a><a href='#L68'>68</a>
<a name='L69'></a><a href='#L69'>69</a>
<a name='L70'></a><a href='#L70'>70</a>
<a name='L71'></a><a href='#L71'>71</a>
<a name='L72'></a><a href='#L72'>72</a>
<a name='L73'></a><a href='#L73'>73</a>
<a name='L74'></a><a href='#L74'>74</a>
<a name='L75'></a><a href='#L75'>75</a>
<a name='L76'></a><a href='#L76'>76</a>
<a name='L77'></a><a href='#L77'>77</a>
<a name='L78'></a><a href='#L78'>78</a>
<a name='L79'></a><a href='#L79'>79</a>
<a name='L80'></a><a href='#L80'>80</a>
<a name='L81'></a><a href='#L81'>81</a>
<a name='L82'></a><a href='#L82'>82</a>
<a name='L83'></a><a href='#L83'>83</a>
<a name='L84'></a><a href='#L84'>84</a>
<a name='L85'></a><a href='#L85'>85</a>
<a name='L86'></a><a href='#L86'>86</a>
<a name='L87'></a><a href='#L87'>87</a>
<a name='L88'></a><a href='#L88'>88</a>
<a name='L89'></a><a href='#L89'>89</a>
<a name='L90'></a><a href='#L90'>90</a>
<a name='L91'></a><a href='#L91'>91</a>
<a name='L92'></a><a href='#L92'>92</a>
<a name='L93'></a><a href='#L93'>93</a>
<a name='L94'></a><a href='#L94'>94</a>
<a name='L95'></a><a href='#L95'>95</a>
<a name='L96'></a><a href='#L96'>96</a>
<a name='L97'></a><a href='#L97'>97</a>
<a name='L98'></a><a href='#L98'>98</a>
<a name='L99'></a><a href='#L99'>99</a>
<a name='L100'></a><a href='#L100'>100</a>
<a name='L101'></a><a href='#L101'>101</a>
<a name='L102'></a><a href='#L102'>102</a>
<a name='L103'></a><a href='#L103'>103</a>
<a name='L104'></a><a href='#L104'>104</a>
<a name='L105'></a><a href='#L105'>105</a>
<a name='L106'></a><a href='#L106'>106</a>
<a name='L107'></a><a href='#L107'>107</a>
<a name='L108'></a><a href='#L108'>108</a>
<a name='L109'></a><a href='#L109'>109</a>
<a name='L110'></a><a href='#L110'>110</a>
<a name='L111'></a><a href='#L111'>111</a>
<a name='L112'></a><a href='#L112'>112</a>
<a name='L113'></a><a href='#L113'>113</a>
<a name='L114'></a><a href='#L114'>114</a>
<a name='L115'></a><a href='#L115'>115</a>
<a name='L116'></a><a href='#L116'>116</a>
<a name='L117'></a><a href='#L117'>117</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">8x</span>
<span class="cline-any cline-yes">8x</span>
<span class="cline-any cline-yes">8x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">8x</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">8x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">8x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">8x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">19x</span>
<span class="cline-any cline-yes">19x</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">19x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import React, { createContext, useContext, useState, useEffect } from 'react';
&nbsp;
// ユーザーオブジェクトの型定義
export interface User {
    id: number | string;
    name?: string;
    email: string;
    role: string;
}
&nbsp;
// AuthContext の型定義
export interface AuthContextType {
    user: User | null;
    token: string | null;
    isLoading: boolean;
    isAuthenticated: boolean;
    login: (email: string, password: string) =&gt; Promise&lt;void&gt;;
    logout: () =&gt; void;
}
&nbsp;
export const AuthContext = createContext&lt;AuthContextType | undefined&gt;(undefined);
&nbsp;
export const AuthProvider: React.FC&lt;{ children: React.ReactNode }&gt; = ({ children }) =&gt; {
    const [user, setUser] = useState&lt;User | null&gt;(null);
    const [token, setToken] = useState&lt;string | null&gt;(() =&gt; localStorage.getItem('token'));
    const [isLoading, setIsLoading] = useState&lt;boolean&gt;(true);
&nbsp;
    // 初期化時：localStorage にトークンがあれば /api/auth/me でユーザー情報を復元
    useEffect(() =&gt; {
        const initAuth = async () =&gt; {
            const storedToken = localStorage.getItem('token');
            if (!storedToken) {
                setIsLoading(false);
                return;
            }
&nbsp;
            try {
                const res = await fetch('/api/auth/me', {
                    headers: {
                        Authorization: `Bearer ${storedToken}`,
                    },
                });
&nbsp;
                if (res.ok) {
                    const data = await res.json();
                    setUser(data.user);
                    setToken(storedToken);
                } else <span class="missing-if-branch" title="else path not taken" >E</span>{
<span class="cstat-no" title="statement not covered" >                    localStorage.removeItem('token');</span>
<span class="cstat-no" title="statement not covered" >                    setToken(null);</span>
<span class="cstat-no" title="statement not covered" >                    setUser(null);</span>
                }
            } catch (error) {
<span class="cstat-no" title="statement not covered" >                console.error('Failed to restore authentication session:', error);</span>
<span class="cstat-no" title="statement not covered" >                localStorage.removeItem('token');</span>
<span class="cstat-no" title="statement not covered" >                setToken(null);</span>
<span class="cstat-no" title="statement not covered" >                setUser(null);</span>
            } finally {
                setIsLoading(false);
            }
        };
&nbsp;
        initAuth();
    }, []);
&nbsp;
    // ログイン処理
    const login = async (email: string, password: string) =&gt; {
        const res = await fetch('/api/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, password }),
        });
&nbsp;
        <span class="missing-if-branch" title="if path not taken" >I</span>if (!res.ok) {
            const errorData = <span class="cstat-no" title="statement not covered" >await res.json().<span class="fstat-no" title="function not covered" >catch(() =&gt; (<span class="cstat-no" title="statement not covered" >{</span>}))</span>;</span>
<span class="cstat-no" title="statement not covered" >            throw new Error(errorData.detail || 'Login failed');</span>
        }
&nbsp;
        const data = await res.json();
        localStorage.setItem('token', data.token);
        setToken(data.token);
        setUser(data.user);
    };
&nbsp;
    // ログアウト処理
    const logout = () =&gt; {
        localStorage.removeItem('token');
        setToken(null);
        setUser(null);
    };
&nbsp;
    return (
        &lt;AuthContext.Provider
            value={{
                user,
                token,
                isLoading,
                isAuthenticated: !!user,
                login,
                logout,
            }}
        &gt;
            {children}
        &lt;/AuthContext.Provider&gt;
    );
};
&nbsp;
export const useAuth = (): AuthContextType =&gt; {
    const context = useContext(AuthContext);
    <span class="missing-if-branch" title="if path not taken" >I</span>if (!context) {
<span class="cstat-no" title="statement not covered" >        throw new Error('useAuth must be used within an AuthProvider');</span>
    }
    return context;
};
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_25098

mkdir -p "coverage/apps/web/src/components"
echo "作成: coverage/apps/web/src/components/index.html"
cat << 'EOF_1785916429_32194' > "coverage/apps/web/src/components/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/web/src/components</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> apps/web/src/components</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>19/19</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">75% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>6/8</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>4/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>19/19</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="LoginForm.tsx"><a href="LoginForm.tsx.html">LoginForm.tsx</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="19" class="abs high">19/19</td>
	<td data-value="75" class="pct medium">75%</td>
	<td data-value="8" class="abs medium">6/8</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="4" class="abs high">4/4</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="19" class="abs high">19/19</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_32194

mkdir -p "coverage/apps/web/src/components"
echo "作成: coverage/apps/web/src/components/LoginForm.tsx.html"
cat << 'EOF_1785916429_18117' > "coverage/apps/web/src/components/LoginForm.tsx.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/web/src/components/LoginForm.tsx</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">apps/web/src/components</a> LoginForm.tsx</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>19/19</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">75% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>6/8</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>4/4</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>19/19</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a>
<a name='L28'></a><a href='#L28'>28</a>
<a name='L29'></a><a href='#L29'>29</a>
<a name='L30'></a><a href='#L30'>30</a>
<a name='L31'></a><a href='#L31'>31</a>
<a name='L32'></a><a href='#L32'>32</a>
<a name='L33'></a><a href='#L33'>33</a>
<a name='L34'></a><a href='#L34'>34</a>
<a name='L35'></a><a href='#L35'>35</a>
<a name='L36'></a><a href='#L36'>36</a>
<a name='L37'></a><a href='#L37'>37</a>
<a name='L38'></a><a href='#L38'>38</a>
<a name='L39'></a><a href='#L39'>39</a>
<a name='L40'></a><a href='#L40'>40</a>
<a name='L41'></a><a href='#L41'>41</a>
<a name='L42'></a><a href='#L42'>42</a>
<a name='L43'></a><a href='#L43'>43</a>
<a name='L44'></a><a href='#L44'>44</a>
<a name='L45'></a><a href='#L45'>45</a>
<a name='L46'></a><a href='#L46'>46</a>
<a name='L47'></a><a href='#L47'>47</a>
<a name='L48'></a><a href='#L48'>48</a>
<a name='L49'></a><a href='#L49'>49</a>
<a name='L50'></a><a href='#L50'>50</a>
<a name='L51'></a><a href='#L51'>51</a>
<a name='L52'></a><a href='#L52'>52</a>
<a name='L53'></a><a href='#L53'>53</a>
<a name='L54'></a><a href='#L54'>54</a>
<a name='L55'></a><a href='#L55'>55</a>
<a name='L56'></a><a href='#L56'>56</a>
<a name='L57'></a><a href='#L57'>57</a>
<a name='L58'></a><a href='#L58'>58</a>
<a name='L59'></a><a href='#L59'>59</a>
<a name='L60'></a><a href='#L60'>60</a>
<a name='L61'></a><a href='#L61'>61</a>
<a name='L62'></a><a href='#L62'>62</a>
<a name='L63'></a><a href='#L63'>63</a>
<a name='L64'></a><a href='#L64'>64</a>
<a name='L65'></a><a href='#L65'>65</a>
<a name='L66'></a><a href='#L66'>66</a>
<a name='L67'></a><a href='#L67'>67</a>
<a name='L68'></a><a href='#L68'>68</a>
<a name='L69'></a><a href='#L69'>69</a>
<a name='L70'></a><a href='#L70'>70</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">11x</span>
<span class="cline-any cline-yes">11x</span>
<span class="cline-any cline-yes">11x</span>
<span class="cline-any cline-yes">11x</span>
<span class="cline-any cline-yes">11x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">11x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">11x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
&nbsp;
interface LoginFormProps {
    onSuccess?: () =&gt; void;
}
&nbsp;
export const LoginForm: React.FC&lt;LoginFormProps&gt; = ({ onSuccess }) =&gt; {
    const { login } = useAuth();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState&lt;string | null&gt;(null);
    const [isSubmitting, setIsSubmitting] = useState(false);
&nbsp;
    const handleSubmit = async (e: React.FormEvent) =&gt; {
        e.preventDefault();
        setError(null);
        setIsSubmitting(true);
&nbsp;
        try {
            await login(email, password);
            <span class="missing-if-branch" title="else path not taken" >E</span>if (onSuccess) {
                onSuccess();
            }
        } catch (err: any) {
            setError(err.message || <span class="branch-1 cbranch-no" title="branch not covered" >'ログインに失敗しました。')</span>;
        } finally {
            setIsSubmitting(false);
        }
    };
&nbsp;
    return (
        &lt;form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1rem', maxWidth: '300px' }}&gt;
            &lt;h2&gt;ログイン&lt;/h2&gt;
            {error &amp;&amp; (
                &lt;div role="alert" style={{ color: 'red', fontSize: '0.875rem' }}&gt;
                    {error}
                &lt;/div&gt;
            )}
            &lt;div&gt;
                &lt;label htmlFor="email"&gt;メールアドレス&lt;/label&gt;
                &lt;input
                    id="email"
                    type="email"
                    value={email}
                    onChange={(e) =&gt; setEmail(e.target.value)}
                    required
                    disabled={isSubmitting}
                    style={{ width: '100%', padding: '0.5rem' }}
                /&gt;
            &lt;/div&gt;
            &lt;div&gt;
                &lt;label htmlFor="password"&gt;パスワード&lt;/label&gt;
                &lt;input
                    id="password"
                    type="password"
                    value={password}
                    onChange={(e) =&gt; setPassword(e.target.value)}
                    required
                    disabled={isSubmitting}
                    style={{ width: '100%', padding: '0.5rem' }}
                /&gt;
            &lt;/div&gt;
            &lt;button type="submit" disabled={isSubmitting} style={{ padding: '0.5rem 1rem', cursor: 'pointer' }}&gt;
                {isSubmitting ? '送信中...' : 'ログイン'}
            &lt;/button&gt;
        &lt;/form&gt;
    );
};
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_18117

mkdir -p "coverage/apps/api/src"
echo "作成: coverage/apps/api/src/index.html"
cat << 'EOF_1785916429_14742' > "coverage/apps/api/src/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/api/src</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> apps/api/src</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">89.58% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>43/48</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">66.66% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>14/21</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">85.71% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>6/7</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">89.36% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>42/47</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="env.ts"><a href="env.ts.html">env.ts</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="5" class="abs high">5/5</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="3" class="abs high">3/3</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="1" class="abs high">1/1</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="5" class="abs high">5/5</td>
	</tr>

<tr>
	<td class="file high" data-value="index.ts"><a href="index.ts.html">index.ts</a></td>
	<td data-value="88.37" class="pic high">
	<div class="chart"><div class="cover-fill" style="width: 88%"></div><div class="cover-empty" style="width: 12%"></div></div>
	</td>
	<td data-value="88.37" class="pct high">88.37%</td>
	<td data-value="43" class="abs high">38/43</td>
	<td data-value="61.11" class="pct medium">61.11%</td>
	<td data-value="18" class="abs medium">11/18</td>
	<td data-value="83.33" class="pct high">83.33%</td>
	<td data-value="6" class="abs high">5/6</td>
	<td data-value="88.09" class="pct high">88.09%</td>
	<td data-value="42" class="abs high">37/42</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_14742

mkdir -p "coverage/apps/api/src/routes"
echo "作成: coverage/apps/api/src/routes/auth.ts.html"
cat << 'EOF_1785916429_309' > "coverage/apps/api/src/routes/auth.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/api/src/routes/auth.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">apps/api/src/routes</a> auth.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">90% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>18/20</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">66.66% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>4/6</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>3/3</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">90% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>18/20</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a>
<a name='L28'></a><a href='#L28'>28</a>
<a name='L29'></a><a href='#L29'>29</a>
<a name='L30'></a><a href='#L30'>30</a>
<a name='L31'></a><a href='#L31'>31</a>
<a name='L32'></a><a href='#L32'>32</a>
<a name='L33'></a><a href='#L33'>33</a>
<a name='L34'></a><a href='#L34'>34</a>
<a name='L35'></a><a href='#L35'>35</a>
<a name='L36'></a><a href='#L36'>36</a>
<a name='L37'></a><a href='#L37'>37</a>
<a name='L38'></a><a href='#L38'>38</a>
<a name='L39'></a><a href='#L39'>39</a>
<a name='L40'></a><a href='#L40'>40</a>
<a name='L41'></a><a href='#L41'>41</a>
<a name='L42'></a><a href='#L42'>42</a>
<a name='L43'></a><a href='#L43'>43</a>
<a name='L44'></a><a href='#L44'>44</a>
<a name='L45'></a><a href='#L45'>45</a>
<a name='L46'></a><a href='#L46'>46</a>
<a name='L47'></a><a href='#L47'>47</a>
<a name='L48'></a><a href='#L48'>48</a>
<a name='L49'></a><a href='#L49'>49</a>
<a name='L50'></a><a href='#L50'>50</a>
<a name='L51'></a><a href='#L51'>51</a>
<a name='L52'></a><a href='#L52'>52</a>
<a name='L53'></a><a href='#L53'>53</a>
<a name='L54'></a><a href='#L54'>54</a>
<a name='L55'></a><a href='#L55'>55</a>
<a name='L56'></a><a href='#L56'>56</a>
<a name='L57'></a><a href='#L57'>57</a>
<a name='L58'></a><a href='#L58'>58</a>
<a name='L59'></a><a href='#L59'>59</a>
<a name='L60'></a><a href='#L60'>60</a>
<a name='L61'></a><a href='#L61'>61</a>
<a name='L62'></a><a href='#L62'>62</a>
<a name='L63'></a><a href='#L63'>63</a>
<a name='L64'></a><a href='#L64'>64</a>
<a name='L65'></a><a href='#L65'>65</a>
<a name='L66'></a><a href='#L66'>66</a>
<a name='L67'></a><a href='#L67'>67</a>
<a name='L68'></a><a href='#L68'>68</a>
<a name='L69'></a><a href='#L69'>69</a>
<a name='L70'></a><a href='#L70'>70</a>
<a name='L71'></a><a href='#L71'>71</a>
<a name='L72'></a><a href='#L72'>72</a>
<a name='L73'></a><a href='#L73'>73</a>
<a name='L74'></a><a href='#L74'>74</a>
<a name='L75'></a><a href='#L75'>75</a>
<a name='L76'></a><a href='#L76'>76</a>
<a name='L77'></a><a href='#L77'>77</a>
<a name='L78'></a><a href='#L78'>78</a>
<a name='L79'></a><a href='#L79'>79</a>
<a name='L80'></a><a href='#L80'>80</a>
<a name='L81'></a><a href='#L81'>81</a>
<a name='L82'></a><a href='#L82'>82</a>
<a name='L83'></a><a href='#L83'>83</a>
<a name='L84'></a><a href='#L84'>84</a>
<a name='L85'></a><a href='#L85'>85</a>
<a name='L86'></a><a href='#L86'>86</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { Hono } from 'hono';
import { z } from 'zod';
import { eq } from 'drizzle-orm';
import { db, schema, UnauthorizedError } from '@app/core';
import { verifyPassword, signJwt } from '@app/plugins-auth-local';
import { authMiddleware } from '../middlewares/auth-middleware';
&nbsp;
// ログインリクエストのバリデーションスキーマ
const loginSchema = z.object({
    email: z.string().email(),
    password: z.string().min(1),
});
&nbsp;
/**
 * 認証関連の API ルーター
 */
export function authRouter(jwtSecret: string) {
    const app = new Hono();
&nbsp;
    // ----------------------------------------------------
    // 1. POST /login (ログイン &amp; トークン発行)
    // ----------------------------------------------------
    app.post('/login', async (c) =&gt; {
        const body = await c.req.json();
        const result = loginSchema.safeParse(body);
&nbsp;
        <span class="missing-if-branch" title="if path not taken" >I</span>if (!result.success) {
<span class="cstat-no" title="statement not covered" >            throw new UnauthorizedError('Invalid email or password format.');</span>
        }
&nbsp;
        const { email, password } = result.data;
&nbsp;
        // DB からユーザーを検索
        const user = await db.query.users.findFirst({
            where: eq(schema.users.email, email),
        });
&nbsp;
        <span class="missing-if-branch" title="if path not taken" >I</span>if (!user) {
            // セキュリティ上「ユーザーが存在しない」メッセージは出さず 401 を返す
<span class="cstat-no" title="statement not covered" >            throw new UnauthorizedError('Invalid credentials.');</span>
        }
&nbsp;
        // パスワードの照合
        const isPasswordValid = await verifyPassword(password, user.passwordHash);
        if (!isPasswordValid) {
            throw new UnauthorizedError('Invalid credentials.');
        }
&nbsp;
        // JWT アクセストークンの発行
        const token = await signJwt(
            {
                userId: user.id,
                email: user.email,
                role: user.role,
            },
            jwtSecret
        );
&nbsp;
        return c.json({
            token,
            user: {
                id: user.id,
                email: user.email,
                role: user.role,
            },
        });
    });
&nbsp;
    // ----------------------------------------------------
    // 2. GET /me (ログインユーザー情報取得)
    // ----------------------------------------------------
    app.get('/me', authMiddleware(jwtSecret), async (c) =&gt; {
        const currentUser = c.get('user');
&nbsp;
        return c.json({
            user: {
                id: currentUser.userId,
                email: currentUser.email,
                role: currentUser.role,
            },
        });
    });
&nbsp;
    return app;
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_309

mkdir -p "coverage/apps/api/src/routes"
echo "作成: coverage/apps/api/src/routes/index.html"
cat << 'EOF_1785916429_3748' > "coverage/apps/api/src/routes/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/api/src/routes</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> apps/api/src/routes</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">90% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>18/20</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">66.66% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>4/6</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>3/3</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">90% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>18/20</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="auth.ts"><a href="auth.ts.html">auth.ts</a></td>
	<td data-value="90" class="pic high">
	<div class="chart"><div class="cover-fill" style="width: 90%"></div><div class="cover-empty" style="width: 10%"></div></div>
	</td>
	<td data-value="90" class="pct high">90%</td>
	<td data-value="20" class="abs high">18/20</td>
	<td data-value="66.66" class="pct medium">66.66%</td>
	<td data-value="6" class="abs medium">4/6</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="3" class="abs high">3/3</td>
	<td data-value="90" class="pct high">90%</td>
	<td data-value="20" class="abs high">18/20</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_3748

mkdir -p "coverage/apps/api/src"
echo "作成: coverage/apps/api/src/env.ts.html"
cat << 'EOF_1785916429_1597' > "coverage/apps/api/src/env.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/api/src/env.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> / <a href="index.html">apps/api/src</a> env.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>5/5</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>3/3</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>1/1</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>5/5</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { z } from 'zod';
&nbsp;
const envSchema = z.object({
    DATABASE_URL: z.string().min(1, '環境変数の検証に失敗しました'),
    PORT: z.string().optional(),
});
&nbsp;
export function validateEnv(env: Record&lt;string, string | undefined&gt; = process.env) {
    const result = envSchema.safeParse(env);
    if (!result.success) {
        throw new Error('環境変数の検証に失敗しました');
    }
    return result.data;
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_1597

mkdir -p "coverage/apps/api/src"
echo "作成: coverage/apps/api/src/index.ts.html"
cat << 'EOF_1785916429_28916' > "coverage/apps/api/src/index.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/api/src/index.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../prettify.css" />
    <link rel="stylesheet" href="../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../index.html">All files</a> / <a href="index.html">apps/api/src</a> index.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">88.37% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>38/43</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">61.11% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>11/18</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">83.33% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>5/6</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">88.09% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>37/42</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a>
<a name='L28'></a><a href='#L28'>28</a>
<a name='L29'></a><a href='#L29'>29</a>
<a name='L30'></a><a href='#L30'>30</a>
<a name='L31'></a><a href='#L31'>31</a>
<a name='L32'></a><a href='#L32'>32</a>
<a name='L33'></a><a href='#L33'>33</a>
<a name='L34'></a><a href='#L34'>34</a>
<a name='L35'></a><a href='#L35'>35</a>
<a name='L36'></a><a href='#L36'>36</a>
<a name='L37'></a><a href='#L37'>37</a>
<a name='L38'></a><a href='#L38'>38</a>
<a name='L39'></a><a href='#L39'>39</a>
<a name='L40'></a><a href='#L40'>40</a>
<a name='L41'></a><a href='#L41'>41</a>
<a name='L42'></a><a href='#L42'>42</a>
<a name='L43'></a><a href='#L43'>43</a>
<a name='L44'></a><a href='#L44'>44</a>
<a name='L45'></a><a href='#L45'>45</a>
<a name='L46'></a><a href='#L46'>46</a>
<a name='L47'></a><a href='#L47'>47</a>
<a name='L48'></a><a href='#L48'>48</a>
<a name='L49'></a><a href='#L49'>49</a>
<a name='L50'></a><a href='#L50'>50</a>
<a name='L51'></a><a href='#L51'>51</a>
<a name='L52'></a><a href='#L52'>52</a>
<a name='L53'></a><a href='#L53'>53</a>
<a name='L54'></a><a href='#L54'>54</a>
<a name='L55'></a><a href='#L55'>55</a>
<a name='L56'></a><a href='#L56'>56</a>
<a name='L57'></a><a href='#L57'>57</a>
<a name='L58'></a><a href='#L58'>58</a>
<a name='L59'></a><a href='#L59'>59</a>
<a name='L60'></a><a href='#L60'>60</a>
<a name='L61'></a><a href='#L61'>61</a>
<a name='L62'></a><a href='#L62'>62</a>
<a name='L63'></a><a href='#L63'>63</a>
<a name='L64'></a><a href='#L64'>64</a>
<a name='L65'></a><a href='#L65'>65</a>
<a name='L66'></a><a href='#L66'>66</a>
<a name='L67'></a><a href='#L67'>67</a>
<a name='L68'></a><a href='#L68'>68</a>
<a name='L69'></a><a href='#L69'>69</a>
<a name='L70'></a><a href='#L70'>70</a>
<a name='L71'></a><a href='#L71'>71</a>
<a name='L72'></a><a href='#L72'>72</a>
<a name='L73'></a><a href='#L73'>73</a>
<a name='L74'></a><a href='#L74'>74</a>
<a name='L75'></a><a href='#L75'>75</a>
<a name='L76'></a><a href='#L76'>76</a>
<a name='L77'></a><a href='#L77'>77</a>
<a name='L78'></a><a href='#L78'>78</a>
<a name='L79'></a><a href='#L79'>79</a>
<a name='L80'></a><a href='#L80'>80</a>
<a name='L81'></a><a href='#L81'>81</a>
<a name='L82'></a><a href='#L82'>82</a>
<a name='L83'></a><a href='#L83'>83</a>
<a name='L84'></a><a href='#L84'>84</a>
<a name='L85'></a><a href='#L85'>85</a>
<a name='L86'></a><a href='#L86'>86</a>
<a name='L87'></a><a href='#L87'>87</a>
<a name='L88'></a><a href='#L88'>88</a>
<a name='L89'></a><a href='#L89'>89</a>
<a name='L90'></a><a href='#L90'>90</a>
<a name='L91'></a><a href='#L91'>91</a>
<a name='L92'></a><a href='#L92'>92</a>
<a name='L93'></a><a href='#L93'>93</a>
<a name='L94'></a><a href='#L94'>94</a>
<a name='L95'></a><a href='#L95'>95</a>
<a name='L96'></a><a href='#L96'>96</a>
<a name='L97'></a><a href='#L97'>97</a>
<a name='L98'></a><a href='#L98'>98</a>
<a name='L99'></a><a href='#L99'>99</a>
<a name='L100'></a><a href='#L100'>100</a>
<a name='L101'></a><a href='#L101'>101</a>
<a name='L102'></a><a href='#L102'>102</a>
<a name='L103'></a><a href='#L103'>103</a>
<a name='L104'></a><a href='#L104'>104</a>
<a name='L105'></a><a href='#L105'>105</a>
<a name='L106'></a><a href='#L106'>106</a>
<a name='L107'></a><a href='#L107'>107</a>
<a name='L108'></a><a href='#L108'>108</a>
<a name='L109'></a><a href='#L109'>109</a>
<a name='L110'></a><a href='#L110'>110</a>
<a name='L111'></a><a href='#L111'>111</a>
<a name='L112'></a><a href='#L112'>112</a>
<a name='L113'></a><a href='#L113'>113</a>
<a name='L114'></a><a href='#L114'>114</a>
<a name='L115'></a><a href='#L115'>115</a>
<a name='L116'></a><a href='#L116'>116</a>
<a name='L117'></a><a href='#L117'>117</a>
<a name='L118'></a><a href='#L118'>118</a>
<a name='L119'></a><a href='#L119'>119</a>
<a name='L120'></a><a href='#L120'>120</a>
<a name='L121'></a><a href='#L121'>121</a>
<a name='L122'></a><a href='#L122'>122</a>
<a name='L123'></a><a href='#L123'>123</a>
<a name='L124'></a><a href='#L124'>124</a>
<a name='L125'></a><a href='#L125'>125</a>
<a name='L126'></a><a href='#L126'>126</a>
<a name='L127'></a><a href='#L127'>127</a>
<a name='L128'></a><a href='#L128'>128</a>
<a name='L129'></a><a href='#L129'>129</a>
<a name='L130'></a><a href='#L130'>130</a>
<a name='L131'></a><a href='#L131'>131</a>
<a name='L132'></a><a href='#L132'>132</a>
<a name='L133'></a><a href='#L133'>133</a>
<a name='L134'></a><a href='#L134'>134</a>
<a name='L135'></a><a href='#L135'>135</a>
<a name='L136'></a><a href='#L136'>136</a>
<a name='L137'></a><a href='#L137'>137</a>
<a name='L138'></a><a href='#L138'>138</a>
<a name='L139'></a><a href='#L139'>139</a>
<a name='L140'></a><a href='#L140'>140</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-no">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import { Hono } from 'hono';
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
&nbsp;
// 1. 起動時に環境変数を検証・取得
const env = validateEnv();
&nbsp;
// 2. コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
<span class="missing-if-branch" title="if path not taken" >I</span>if (process.env.NODE_ENV !== 'test') {
<span class="cstat-no" title="statement not covered" >    console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog(env));</span>
}
&nbsp;
// 3. プラグインの登録
AuthRegistry.register(new LocalAuthPlugin());
AuthRegistry.register(new ActiveDirectoryAuthPlugin());
&nbsp;
const app = new Hono();
&nbsp;
// -----------------------------------------------------------------------------
// テスト専用ルート (NODE_ENV === 'test' の場合のみ有効化)
// -----------------------------------------------------------------------------
<span class="missing-if-branch" title="else path not taken" >E</span>if (process.env.NODE_ENV === 'test') {
    app.get('/test/error', () =&gt; {
        throw new Error('Test internal error');
    });
}
&nbsp;
// -----------------------------------------------------------------------------
// ルーティング・モジュール読み込み
// -----------------------------------------------------------------------------
// 💡 authRouter(env.JWT_SECRET) のように実行して Hono インスタンスを渡す
app.route('/api/auth', authRouter(env.JWT_SECRET));
&nbsp;
await loadFeatureModules(app, 'packages/features/*/src/index.ts');
&nbsp;
// -----------------------------------------------------------------------------
// テスト専用バリデーションルート (NODE_ENV === 'test' の場合のみ)
// -----------------------------------------------------------------------------
<span class="missing-if-branch" title="else path not taken" >E</span>if (process.env.NODE_ENV === 'test') {
    const sampleSchema = z.object({
        name: z.string().min(2, 'Name must be at least 2 characters'),
        email: z.string().email('Invalid email address'),
    });
&nbsp;
    app.post(
        '/test/validation',
        zValidator('json', sampleSchema, (result, c) =&gt; {
            <span class="missing-if-branch" title="else path not taken" >E</span>if (!result.success) {
                // Zod のエラー結果を統一した InvalidParam 形式に変換
                const invalidParams = result.error.issues.map((issue) =&gt; ({
                    name: issue.path.join('.'),
                    reason: issue.message,
                }));
                // カスタムValidationErrorをスローして共通onErrorに流す
                throw new ValidationError(invalidParams);
            }
        }<span class="fstat-no" title="function not covered" >),</span>
        (c) =&gt; {
<span class="cstat-no" title="statement not covered" >            return c.json({ success: true });</span>
        }
    );
}
&nbsp;
// -----------------------------------------------------------------------------
// 404 Not Found ハンドラー (RFC 7807 形式)
// -----------------------------------------------------------------------------
app.notFound((c) =&gt; {
    const problem: ProblemDetails = {
        type: 'https://api.example.com/errors/not-found',
        title: 'Not Found',
        status: 404,
        detail: 'The requested resource was not found',
        instance: c.req.path,
    };
    return c.json(problem, 404);
});
&nbsp;
// -----------------------------------------------------------------------------
// 共通エラーハンドラー (app.onError - RFC 7807 形式)
// -----------------------------------------------------------------------------
app.onError((err, c) =&gt; {
    <span class="missing-if-branch" title="if path not taken" >I</span>if (process.env.NODE_ENV !== 'test') {
<span class="cstat-no" title="statement not covered" >        console.error(`[Error] ${c.req.method} ${c.req.path}:`, err);</span>
    }
&nbsp;
    let status = 500;
    let type = 'https://api.example.com/errors/internal-server-error';
    let title = 'Internal Server Error';
    let detail = 'An unexpected error occurred';
    let invalidParams: any = undefined;
&nbsp;
    if (err instanceof AppError) {
        status = err.status;
        type = `https://api.example.com/errors/${err.code}`;
        title = err.title;
        detail = err.message;
&nbsp;
        // ValidationError の場合は invalidParams を抽出
        <span class="missing-if-branch" title="else path not taken" >E</span>if (err instanceof ValidationError) {
            invalidParams = err.invalidParams;
        }
    }
&nbsp;
    const problem: ProblemDetails = {
        type,
        title,
        status,
        detail,
        instance: c.req.path,
        ...(invalidParams &amp;&amp; { invalidParams }),
    };
&nbsp;
    return c.json(problem, status as any);
});
&nbsp;
// -----------------------------------------------------------------------------
// サーバーバインド &amp; 起動処理
// -----------------------------------------------------------------------------
const port = env.PORT; // 型安全な数値ポート番号を使用
&nbsp;
// 💡 テスト環境（NODE_ENV === 'test'）以外の場合のみ、実際の HTTP サーバーを起動する
<span class="missing-if-branch" title="if path not taken" >I</span>if (process.env.NODE_ENV !== 'test') {
<span class="cstat-no" title="statement not covered" >    console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);</span>
<span class="cstat-no" title="statement not covered" >    serve({</span>
        fetch: app.fetch,
        port,
        hostname: '0.0.0.0',
    });
}
&nbsp;
export default app;
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../sorter.js"></script>
        <script src="../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_28916

mkdir -p "coverage/apps/api/src/middlewares"
echo "作成: coverage/apps/api/src/middlewares/auth-middleware.ts.html"
cat << 'EOF_1785916429_20619' > "coverage/apps/api/src/middlewares/auth-middleware.ts.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/api/src/middlewares/auth-middleware.ts</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> / <a href="index.html">apps/api/src/middlewares</a> auth-middleware.ts</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>10/10</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>6/6</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>2/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>10/10</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <pre><table class="coverage">
<tr><td class="line-count quiet"><a name='L1'></a><a href='#L1'>1</a>
<a name='L2'></a><a href='#L2'>2</a>
<a name='L3'></a><a href='#L3'>3</a>
<a name='L4'></a><a href='#L4'>4</a>
<a name='L5'></a><a href='#L5'>5</a>
<a name='L6'></a><a href='#L6'>6</a>
<a name='L7'></a><a href='#L7'>7</a>
<a name='L8'></a><a href='#L8'>8</a>
<a name='L9'></a><a href='#L9'>9</a>
<a name='L10'></a><a href='#L10'>10</a>
<a name='L11'></a><a href='#L11'>11</a>
<a name='L12'></a><a href='#L12'>12</a>
<a name='L13'></a><a href='#L13'>13</a>
<a name='L14'></a><a href='#L14'>14</a>
<a name='L15'></a><a href='#L15'>15</a>
<a name='L16'></a><a href='#L16'>16</a>
<a name='L17'></a><a href='#L17'>17</a>
<a name='L18'></a><a href='#L18'>18</a>
<a name='L19'></a><a href='#L19'>19</a>
<a name='L20'></a><a href='#L20'>20</a>
<a name='L21'></a><a href='#L21'>21</a>
<a name='L22'></a><a href='#L22'>22</a>
<a name='L23'></a><a href='#L23'>23</a>
<a name='L24'></a><a href='#L24'>24</a>
<a name='L25'></a><a href='#L25'>25</a>
<a name='L26'></a><a href='#L26'>26</a>
<a name='L27'></a><a href='#L27'>27</a>
<a name='L28'></a><a href='#L28'>28</a>
<a name='L29'></a><a href='#L29'>29</a>
<a name='L30'></a><a href='#L30'>30</a>
<a name='L31'></a><a href='#L31'>31</a>
<a name='L32'></a><a href='#L32'>32</a>
<a name='L33'></a><a href='#L33'>33</a>
<a name='L34'></a><a href='#L34'>34</a>
<a name='L35'></a><a href='#L35'>35</a>
<a name='L36'></a><a href='#L36'>36</a>
<a name='L37'></a><a href='#L37'>37</a></td><td class="line-coverage quiet"><span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">7x</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">4x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">3x</span>
<span class="cline-any cline-yes">1x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-yes">2x</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span>
<span class="cline-any cline-neutral">&nbsp;</span></td><td class="text"><pre class="prettyprint lang-js">import type { MiddlewareHandler } from 'hono';
import { verifyJwt } from '@app/plugins-auth-local';
import { UnauthorizedError } from '@app/core';
&nbsp;
// Hono の ContextVariableMap を拡張
declare module 'hono' {
    interface ContextVariableMap {
        user: Record&lt;string, unknown&gt;;
    }
}
&nbsp;
/**
 * JWT Bearer トークンを検証する Hono ミドルウェア
 */
export function authMiddleware(secret: string): MiddlewareHandler {
    return async (c, next) =&gt; {
        const authHeader = c.req.header('Authorization');
&nbsp;
        // 1. Authorization ヘッダーの存在チェック
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new UnauthorizedError('Authentication token is missing or invalid format.');
        }
&nbsp;
        // 2. トークンの抽出と検証
        const token = authHeader.substring(7);
        const payload = await verifyJwt(token, secret);
&nbsp;
        if (!payload) {
            throw new UnauthorizedError('Token is invalid or expired.');
        }
&nbsp;
        // 3. コンテキストにユーザー情報をセットして次の処理へ
        c.set('user', payload);
        await next();
    };
}
&nbsp;</pre></td></tr></table></pre>

                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_20619

mkdir -p "coverage/apps/api/src/middlewares"
echo "作成: coverage/apps/api/src/middlewares/index.html"
cat << 'EOF_1785916429_24957' > "coverage/apps/api/src/middlewares/index.html"

<!doctype html>
<html lang="en">

<head>
    <title>Code coverage report for apps/api/src/middlewares</title>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="../../../../prettify.css" />
    <link rel="stylesheet" href="../../../../base.css" />
    <link rel="shortcut icon" type="image/x-icon" href="../../../../favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type='text/css'>
        .coverage-summary .sorter {
            background-image: url(../../../../sort-arrow-sprite.png);
        }
    </style>
</head>
    
<body>
<div class='wrapper'>
    <div class='pad1'>
        <h1><a href="../../../../index.html">All files</a> apps/api/src/middlewares</h1>
        <div class='clearfix'>
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Statements</span>
                <span class='fraction'>10/10</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Branches</span>
                <span class='fraction'>6/6</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Functions</span>
                <span class='fraction'>2/2</span>
            </div>
        
            
            <div class='fl pad1y space-right2'>
                <span class="strong">100% </span>
                <span class="quiet">Lines</span>
                <span class='fraction'>10/10</span>
            </div>
        
            
        </div>
        <p class="quiet">
            Press <em>n</em> or <em>j</em> to go to the next uncovered block, <em>b</em>, <em>p</em> or <em>k</em> for the previous block.
        </p>
        <template id="filterTemplate">
            <div class="quiet">
                Filter:
                <input type="search" id="fileSearch">
            </div>
        </template>
    </div>
    <div class='status-line high'></div>
    <div class="pad1">
<table class="coverage-summary">
<thead>
<tr>
   <th data-col="file" data-fmt="html" data-html="true" class="file">File</th>
   <th data-col="pic" data-type="number" data-fmt="html" data-html="true" class="pic"></th>
   <th data-col="statements" data-type="number" data-fmt="pct" class="pct">Statements</th>
   <th data-col="statements_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="branches" data-type="number" data-fmt="pct" class="pct">Branches</th>
   <th data-col="branches_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="functions" data-type="number" data-fmt="pct" class="pct">Functions</th>
   <th data-col="functions_raw" data-type="number" data-fmt="html" class="abs"></th>
   <th data-col="lines" data-type="number" data-fmt="pct" class="pct">Lines</th>
   <th data-col="lines_raw" data-type="number" data-fmt="html" class="abs"></th>
</tr>
</thead>
<tbody><tr>
	<td class="file high" data-value="auth-middleware.ts"><a href="auth-middleware.ts.html">auth-middleware.ts</a></td>
	<td data-value="100" class="pic high">
	<div class="chart"><div class="cover-fill cover-full" style="width: 100%"></div><div class="cover-empty" style="width: 0%"></div></div>
	</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="10" class="abs high">10/10</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="6" class="abs high">6/6</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="2" class="abs high">2/2</td>
	<td data-value="100" class="pct high">100%</td>
	<td data-value="10" class="abs high">10/10</td>
	</tr>

</tbody>
</table>
</div>
                <div class='push'></div><!-- for sticky footer -->
            </div><!-- /wrapper -->
            <div class='footer quiet pad2 space-top1 center small'>
                Code coverage generated by
                <a href="https://istanbul.js.org/" target="_blank" rel="noopener noreferrer">istanbul</a>
                at 2026-08-05T02:37:19.545Z
            </div>
        <script src="../../../../prettify.js"></script>
        <script>
            window.onload = function () {
                prettyPrint();
            };
        </script>
        <script src="../../../../sorter.js"></script>
        <script src="../../../../block-navigation.js"></script>
    </body>
</html>
    
EOF_1785916429_24957

mkdir -p "coverage"
echo "作成: coverage/prettify.css"
cat << 'EOF_1785916429_13415' > "coverage/prettify.css"
.pln{color:#000}@media screen{.str{color:#080}.kwd{color:#008}.com{color:#800}.typ{color:#606}.lit{color:#066}.pun,.opn,.clo{color:#660}.tag{color:#008}.atn{color:#606}.atv{color:#080}.dec,.var{color:#606}.fun{color:red}}@media print,projection{.str{color:#060}.kwd{color:#006;font-weight:bold}.com{color:#600;font-style:italic}.typ{color:#404;font-weight:bold}.lit{color:#044}.pun,.opn,.clo{color:#440}.tag{color:#006;font-weight:bold}.atn{color:#404}.atv{color:#060}}pre.prettyprint{padding:2px;border:1px solid #888}ol.linenums{margin-top:0;margin-bottom:0}li.L0,li.L1,li.L2,li.L3,li.L5,li.L6,li.L7,li.L8{list-style-type:none}li.L1,li.L3,li.L5,li.L7,li.L9{background:#eee}
EOF_1785916429_13415

echo "作成: vitest.config.ts"
cat << 'EOF_1785916429_5540' > "vitest.config.ts"
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
EOF_1785916429_5540

mkdir -p "packages/plugins/auth-ad"
echo "作成: packages/plugins/auth-ad/package.json"
cat << 'EOF_1785916429_19922' > "packages/plugins/auth-ad/package.json"
{
  "name": "@app/plugins-auth-ad",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785916429_19922

mkdir -p "packages/plugins/auth-ad/src"
echo "作成: packages/plugins/auth-ad/src/index.ts"
cat << 'EOF_1785916429_25798' > "packages/plugins/auth-ad/src/index.ts"
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
EOF_1785916429_25798

mkdir -p "packages/plugins/auth-local"
echo "作成: packages/plugins/auth-local/package.json"
cat << 'EOF_1785916429_4566' > "packages/plugins/auth-local/package.json"
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
EOF_1785916429_4566

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/index.ts"
cat << 'EOF_1785916429_23336' > "packages/plugins/auth-local/src/index.ts"
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
EOF_1785916429_23336

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/auth-utils.ts"
cat << 'EOF_1785916429_17207' > "packages/plugins/auth-local/src/auth-utils.ts"
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
EOF_1785916429_17207

mkdir -p "packages/plugins/auth-local/src"
echo "作成: packages/plugins/auth-local/src/auth-utils.test.ts"
cat << 'EOF_1785916429_509' > "packages/plugins/auth-local/src/auth-utils.test.ts"
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
EOF_1785916429_509

mkdir -p "packages/core"
echo "作成: packages/core/package.json"
cat << 'EOF_1785916429_27975' > "packages/core/package.json"
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
EOF_1785916429_27975

mkdir -p "packages/core"
echo "作成: packages/core/drizzle-test.config.ts"
cat << 'EOF_1785916429_27672' > "packages/core/drizzle-test.config.ts"
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
EOF_1785916429_27672

mkdir -p "packages/core"
echo "作成: packages/core/vitest.config.ts"
cat << 'EOF_1785916429_21097' > "packages/core/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
    test: {
        globalSetup: ['./src/test/global-setup.ts'],    // ① テスト前に自動で db:push:test
        setupFiles: ['./src/test/setup.ts'],            // ② 各テスト実行前にテーブルデータを全消去
        fileParallelism: false,                         // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
    },
});
EOF_1785916429_21097

mkdir -p "packages/core/src/registry"
echo "作成: packages/core/src/registry/hono-auto-loader.ts"
cat << 'EOF_1785916429_16007' > "packages/core/src/registry/hono-auto-loader.ts"
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
EOF_1785916429_16007

mkdir -p "packages/core/src"
echo "作成: packages/core/src/index.ts"
cat << 'EOF_1785916429_25711' > "packages/core/src/index.ts"
export * from './auth/auth-registry';
export * from './registry/hono-auto-loader';
export * from './db';
export * from './config/env';
export * from './errors';
EOF_1785916429_25711

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.test.ts"
cat << 'EOF_1785916429_2511' > "packages/core/src/config/env.test.ts"
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
EOF_1785916429_2511

mkdir -p "packages/core/src/config"
echo "作成: packages/core/src/config/env.ts"
cat << 'EOF_1785916430_27362' > "packages/core/src/config/env.ts"
import { z } from 'zod';

// ==========================================
// 1. バックエンド用 (Node.js) スキーマ & 関数
// ==========================================
export const envSchema = z.object({
    NODE_ENV: z.enum(['development', 'test', 'production'])
        .default('development'),
    PORT: z.coerce.number()
        .default(3001),
    DATABASE_URL: z.string().url({ message: 'DATABASE_URL は有効なURL形式である必要があります' }),
    TEST_DATABASE_URL: z.string().url({ message: 'TEST_DATABASE_URL は有効なURL形式である必要があります' })
        .default('postgresql://postgres:postgres@localhost:5432/app_db_test'),
    JWT_SECRET: z.string().min(32)
        .default('super-secret-jwt-key-for-testing-purposes-123456'),
});

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

// /**
//  * ログ出力用に環境変数を整形（パスワード等はマスク）する関数
//  */
// export function formatEnvForLog(envObj: Env): string {
//     const maskedEnv = { ...envObj };

//     if (maskedEnv.DATABASE_URL) {
//         maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL.replace(/:\/\/(.*):(.*)@/, '://$1:***@');
//     }
//     if (maskedEnv.TEST_DATABASE_URL) {
//         maskedEnv.TEST_DATABASE_URL = maskedEnv.TEST_DATABASE_URL.replace(/:\/\/(.*):(.*)@/, '://$1:***@');
//     }
//     if (maskedEnv.JWT_SECRET) {
//         maskedEnv.JWT_SECRET = '***';
//     }

//     return JSON.stringify(maskedEnv, null, 2);
// }

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
EOF_1785916430_27362

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/index.ts"
cat << 'EOF_1785916430_13839' > "packages/core/src/db/index.ts"
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

// 💡 スキーマも外部から参照できるように export します
export { schema };
EOF_1785916430_13839

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/db.test.ts"
cat << 'EOF_1785916430_31673' > "packages/core/src/db/db.test.ts"
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
EOF_1785916430_31673

mkdir -p "packages/core/src/db"
echo "作成: packages/core/src/db/schema.ts"
cat << 'EOF_1785916430_25319' > "packages/core/src/db/schema.ts"
import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
    id: serial('id').primaryKey(),
    name: text('name').notNull(),
    email: text('email').notNull().unique(),
    passwordHash: text('password_hash').notNull(),
    role: text('role').notNull().default('user'),
    createdAt: timestamp('created_at').defaultNow().notNull(),
});
EOF_1785916430_25319

mkdir -p "packages/core/src/auth"
echo "作成: packages/core/src/auth/auth-registry.ts"
cat << 'EOF_1785916430_9465' > "packages/core/src/auth/auth-registry.ts"
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
EOF_1785916430_9465

mkdir -p "packages/core/src/errors"
echo "作成: packages/core/src/errors/index.ts"
cat << 'EOF_1785916430_32634' > "packages/core/src/errors/index.ts"
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
EOF_1785916430_32634

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/setup.ts"
cat << 'EOF_1785916430_3152' > "packages/core/src/test/setup.ts"
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
EOF_1785916430_3152

mkdir -p "packages/core/src/test"
echo "作成: packages/core/src/test/global-setup.ts"
cat << 'EOF_1785916430_23623' > "packages/core/src/test/global-setup.ts"
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
EOF_1785916430_23623

mkdir -p "packages/core/src"
echo "作成: packages/core/src/seed-dev-user.ts"
cat << 'EOF_1785916430_31208' > "packages/core/src/seed-dev-user.ts"
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
EOF_1785916430_31208

mkdir -p "packages/core"
echo "作成: packages/core/drizzle.config.ts"
cat << 'EOF_1785916430_23018' > "packages/core/drizzle.config.ts"
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
EOF_1785916430_23018

mkdir -p "packages/features/sample"
echo "作成: packages/features/sample/package.json"
cat << 'EOF_1785916430_2291' > "packages/features/sample/package.json"
{
  "name": "@app/features-sample",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts"
}
EOF_1785916430_2291

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.ts"
cat << 'EOF_1785916430_2617' > "packages/features/sample/src/index.ts"
import { Hono } from 'hono';

export default function createSampleFeature() {
  const app = new Hono();

  app.get('/sample', (c) => {
    return c.json({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
  });

  return app;
}
EOF_1785916430_2617

mkdir -p "packages/features/sample/src"
echo "作成: packages/features/sample/src/index.test.ts"
cat << 'EOF_1785916430_21129' > "packages/features/sample/src/index.test.ts"
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
EOF_1785916430_21129

echo "作成: doc.md"
cat << 'EOF_1785916430_8527' > "doc.md"
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
EOF_1785916430_8527

echo "作成: SUMMRY.md"
cat << 'EOF_1785916430_22982' > "SUMMRY.md"
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
EOF_1785916430_22982

mkdir -p "apps/web"
echo "作成: apps/web/package.json"
cat << 'EOF_1785916430_2852' > "apps/web/package.json"
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
EOF_1785916430_2852

mkdir -p "apps/web"
echo "作成: apps/web/index.html"
cat << 'EOF_1785916430_6339' > "apps/web/index.html"
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
EOF_1785916430_6339

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.json"
cat << 'EOF_1785916430_11176' > "apps/web/tsconfig.json"
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
EOF_1785916430_11176

mkdir -p "apps/web"
echo "作成: apps/web/vitest.config.ts"
cat << 'EOF_1785916430_1484' > "apps/web/vitest.config.ts"
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
EOF_1785916430_1484

mkdir -p "apps/web"
echo "作成: apps/web/tsconfig.node.json"
cat << 'EOF_1785916430_22946' > "apps/web/tsconfig.node.json"
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
EOF_1785916430_22946

mkdir -p "apps/web/src/test"
echo "作成: apps/web/src/test/setup.ts"
cat << 'EOF_1785916430_27127' > "apps/web/src/test/setup.ts"
import '@testing-library/jest-dom';
EOF_1785916430_27127

mkdir -p "apps/web/src"
echo "作成: apps/web/src/main.tsx"
cat << 'EOF_1785916430_3571' > "apps/web/src/main.tsx"
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF_1785916430_3571

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.test.tsx"
cat << 'EOF_1785916430_30461' > "apps/web/src/context/AuthContext.test.tsx"
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
EOF_1785916430_30461

mkdir -p "apps/web/src/context"
echo "作成: apps/web/src/context/AuthContext.tsx"
cat << 'EOF_1785916430_4020' > "apps/web/src/context/AuthContext.tsx"
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
EOF_1785916430_4020

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.tsx"
cat << 'EOF_1785916430_31585' > "apps/web/src/components/LoginForm.tsx"
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
EOF_1785916430_31585

mkdir -p "apps/web/src/components"
echo "作成: apps/web/src/components/LoginForm.test.tsx"
cat << 'EOF_1785916430_10881' > "apps/web/src/components/LoginForm.test.tsx"
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
EOF_1785916430_10881

mkdir -p "apps/web/src"
echo "作成: apps/web/src/App.tsx"
cat << 'EOF_1785916430_28742' > "apps/web/src/App.tsx"
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
EOF_1785916430_28742

mkdir -p "apps/web/src"
echo "作成: apps/web/src/env.ts"
cat << 'EOF_1785916430_30254' > "apps/web/src/env.ts"
import { clientEnvSchema, type ClientEnv } from '@app/core';

// Vite の import.meta.env を Zod で検証・補完
export const env: ClientEnv = clientEnvSchema.parse({
    VITE_PORT: import.meta.env.VITE_PORT,
    VITE_API_TARGET_URL: import.meta.env.VITE_API_TARGET_URL,
    VITE_APP_TITLE: import.meta.env.VITE_APP_TITLE,
});
EOF_1785916430_30254

mkdir -p "apps/web"
echo "作成: apps/web/vite.config.ts"
cat << 'EOF_1785916430_16444' > "apps/web/vite.config.ts"
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
            host: true,
            port: webPort,
            proxy: {
                '/api': apiTarget,
                '/sample': apiTarget,
            },
        },
    };
});
EOF_1785916430_16444

mkdir -p "apps/api"
echo "作成: apps/api/package.json"
cat << 'EOF_1785916430_6968' > "apps/api/package.json"
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
EOF_1785916430_6968

mkdir -p "apps/api"
echo "作成: apps/api/tsconfig.json"
cat << 'EOF_1785916430_24999' > "apps/api/tsconfig.json"
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
EOF_1785916430_24999

mkdir -p "apps/api"
echo "作成: apps/api/vitest.config.ts"
cat << 'EOF_1785916430_7435' > "apps/api/vitest.config.ts"
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
  },
});
EOF_1785916430_7435

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.ts"
cat << 'EOF_1785916430_10013' > "apps/api/src/index.ts"
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

// コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
if (env.NODE_ENV !== 'test') {
    console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog());
}

// 3. プラグインの登録
AuthRegistry.register(new LocalAuthPlugin());
AuthRegistry.register(new ActiveDirectoryAuthPlugin());

const app = new Hono();

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
// 💡 authRouter(env.JWT_SECRET) のように実行して Hono インスタンスを渡す
app.route('/api/auth', authRouter(env.JWT_SECRET));

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
    if (env.NODE_ENV !== 'test') {
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
if (env.NODE_ENV !== 'test') {
    console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);
    serve({
        fetch: app.fetch,
        port,
        hostname: '0.0.0.0',
    });
}

export default app;
EOF_1785916430_10013

mkdir -p "apps/api/src"
echo "作成: apps/api/src/index.test.ts"
cat << 'EOF_1785916430_9317' > "apps/api/src/index.test.ts"
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import app from './index';

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
EOF_1785916430_9317

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.ts"
cat << 'EOF_1785916430_29801' > "apps/api/src/routes/auth.ts"
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
EOF_1785916430_29801

mkdir -p "apps/api/src/routes"
echo "作成: apps/api/src/routes/auth.test.ts"
cat << 'EOF_1785916430_14603' > "apps/api/src/routes/auth.test.ts"
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
EOF_1785916430_14603

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.ts"
cat << 'EOF_1785916430_17320' > "apps/api/src/middlewares/auth-middleware.ts"
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
EOF_1785916430_17320

mkdir -p "apps/api/src/middlewares"
echo "作成: apps/api/src/middlewares/auth-middleware.test.ts"
cat << 'EOF_1785916430_4536' > "apps/api/src/middlewares/auth-middleware.test.ts"
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
EOF_1785916430_4536

echo "作成: README.md"
cat << 'EOF_1785916430_5132' > "README.md"
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
EOF_1785916430_5132

echo "作成: .env"
cat << 'EOF_1785916430_25222' > ".env"
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
EOF_1785916430_25222

echo -e "\n復元が完了しました！"
