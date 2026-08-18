import { drizzle } from 'drizzle-orm/postgres-js';

import postgres from 'postgres';
import * as schema from './schema';
import { env, isTest } from '../config/env';

// 必要な接続のみを 1 つだけ生成
const dbUrl = isTest ? env.TEST_DATABASE_URL : env.DATABASE_URL;
export const activeQueryClient = postgres(dbUrl);
export const db = drizzle(activeQueryClient, { schema });

// 1. スキーマオブジェクト全体を export (drizzleConfig や drizzle(client, { schema }) 用)
export { schema };

// 2. 個別のテーブルも直接 import { users, plugins } から使えるように re-export
export * from './schema';
