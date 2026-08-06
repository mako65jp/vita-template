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
