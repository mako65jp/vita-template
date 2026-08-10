# 📋 共通ひな形機能 一覧表（最新版）

### 凡例

* ✅ **完了:** 機能要件およびテストがすべて実装・通過済み（ビルド確認完了）
* ⏳ **未実装:** まだ手をつけていない状態
* ⏸️ **保留:** 応用拡張機能のため、基本画面・業務機能サンプル完成後に着手

---

| 機能名 | 担当パッケージ | 機能優先順位 | TDD実装順序 | 現状 | 実績と現状の対応 |
| --- | --- | --- | --- | --- | --- |
| **環境変数・設定基盤** | `packages/core` | 🔴 **高** | **Step 0** | ✅ **完了** | クライアント/サーバー設定の分離、Zod検証、`PORT` による `VITE_API_TARGET_URL` 動的補完、セキュリティマスク、全ビルド・テスト通過。 |
| **統一エラーハンドリング** | `apps/api` / `packages/core` | 🔴 **高** | **Step 1** | ✅ **完了** | RFC 9457（`about:blank`）準拠。404 / 500 / 共通例外の単体・統合テスト完了。 |
| **Zod リクエスト検証** | `apps/api` / `packages/core` | 🔴 **高** | **Step 2** | ✅ **完了** | 不正 payload 時に `invalidParams` を含む 400 Bad Request 返却のテスト完了。 |
| **DB スキーマ & ORM** | `apps/api` / `packages/core` | 🔴 **高** | **Step 3** | ✅ **完了** | `users` テーブル定義、`TEST_DATABASE_URL` 動的切替、`postgres(...)` 型安全性確保、CRUD / Unique 制約の DB 統合テスト完了。 |
| **認証・認可基盤 (Auth)** | `packages/plugins/auth-*` / `apps/api` | 🔴 **高** | **Step 4** | ✅ **完了** | JWT/ハッシュ化、`/login`, `/me` API、および `ForbiddenError` (403) を含む RBAC (権限制御) ミドルウェアの単体・結合テストまで全完了。 |
| **構造化ロギング & ヘルス** | `apps/api` | 🟡 **中** | **Step 5** | ✅ **完了** | JSON ログ、機密情報マスク（`DATABASE_URL`等）、`/healthz` (503 DB切断テスト) 完了。 |
| **UI 基本コンポーネント** | `apps/web` / `packages/ui` | 🟡 **中** | **Step 6** | ✅ **完了** | Tailwind CSS v4 導入、共通 Layout（Header/Sidebar）、Sonner+RFC 9457 Toast 通知、Vitest+RTL テスト（コロケーション構成）完了。 |
| **API 連携 & 状態管理基盤** | `apps/web` | 🔴 **高** | **Step 7** | ✅ **完了** | 型安全 API クライアント（`apiClient`）、`token` を含む `AuthContext` / `useAuth` による認証状態管理基盤、`/api/auth/login`・`/api/auth/me` 連携、単体テスト・型チェック・プロダクションビルド全通過および `LoginForm` との整合性確認完了。 |
| **認証画面 & アクセス制御** | `apps/web` | 🔴 **高** | **Step 8** | ✅ **完了** | ログイン画面（`LoginForm`）、`ProtectedRoute` による認証ガード、API CORS 設定修正、およびログイン成功後のダッシュボード表示確認完了。 |
| **サンプル CRUD 業務機能** | `packages/features` / `apps/web` | 🟡 **中** | **Step 9** | ⏳ **【次に着手】** | 実践サンプル（プロジェクト/タスク管理等）の API・一覧/作成/編集/削除画面・結合テスト一気通貫開発。 |
| **ストレージ抽象化** | `packages/core` / `apps/api` | 🟢 **低** | **Step 10** | ⏸️ **保留** | ローカル / S3 ファイル保存機能、モックテスト（画面基盤完成後に着手）。 |
| **メール・通知基盤** | `packages/core` | 🟢 **低** | **Step 11** | ⏸️ **保留** | Nodemailer / Resend 連携、HTML テンプレートテスト（画面基盤完成後に着手）。 |

---
