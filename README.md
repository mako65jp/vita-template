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
