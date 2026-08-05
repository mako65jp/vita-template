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
