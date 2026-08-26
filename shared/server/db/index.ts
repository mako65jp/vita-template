import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import { env } from '@shared/functions';
import * as schema from '@shared/schemas';

const activeQueryClient = postgres(env.DATABASE_URL);
const db = drizzle(activeQueryClient, { schema });
export { activeQueryClient, db };

// 1. スキーマオブジェクト全体を export
export { schema };

// 2. 個別のテーブルも直接参照できるように directly re-export
export * from '@shared/schemas';
