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
