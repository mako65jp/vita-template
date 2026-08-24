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
