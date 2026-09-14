import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import { env } from '@shared/functions';
import * as schema from './src/schema';

const activeQueryClient = postgres(env.DATABASE_URL);
const db = drizzle(activeQueryClient, { schema });
export { activeQueryClient, db };

// 1. スキーマオブジェクト全体を export
export { schema };

// 2. 個別のテーブルも直接参照できるように directly re-export
export * from './src/schema';

export * from './src/database';

export * from './src/generated/repositories';
