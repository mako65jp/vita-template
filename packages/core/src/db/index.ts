import { drizzle } from 'drizzle-orm/postgres-js';

import postgres from 'postgres';
import * as schema from './schema';
import { env, isTest } from '../config/env';

// 必要な接続のみを 1 つだけ生成
const dbUrl = isTest ? env.TEST_DATABASE_URL : env.DATABASE_URL;
export const activeQueryClient = postgres(dbUrl);
export const db = drizzle(activeQueryClient, { schema });

// // 開発用（本番用）PostgreSQL 接続クライアントの作成
// const queryClient = postgres(env.DATABASE_URL);
// export const dev_db = drizzle(queryClient, { schema });

// // テスト用PostgreSQL 接続クライアントの作成
// const queryTestClient = postgres(env.TEST_DATABASE_URL);
// export const test_db = drizzle(queryTestClient, { schema });

// // テスト用と開発用（本番用）の接続クライアント動的に選択
// export const db = isTest ? test_db : dev_db;

// // テスト終了時などにコネクションを安全に破棄するためのクライアント
// export const activeQueryClient = isTest ? queryTestClient : queryClient;

// 1. スキーマオブジェクト全体を export (drizzleConfig や drizzle(client, { schema }) 用)
export { schema };

// 2. 個別のテーブルも直接 import { users, plugins } から使えるように re-export
export * from './schema';
