import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';
import { validateEnv } from '../config/env';

const env = validateEnv();

// PostgreSQL 接続クライアントの作成
const queryClient = postgres(env.DATABASE_URL);
export const db = drizzle(queryClient, { schema });

// 💡 スキーマも外部から参照できるように export します
export { schema };
