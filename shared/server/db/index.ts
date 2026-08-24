import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';

import { env, isTest } from '../../functions';
import * as schema from '../../schemas';

// テスト環境の場合は、テスト側で vi.mock により db / activeQueryClient が
// 丸ごと上書きされることを前提とし、実DBへの接続処理を実行させない（エラーを防ぐ）
let activeQueryClient: any;
let db: any;

if (!isTest) {
    // 本番・開発環境のみ実際に接続する
    activeQueryClient = postgres(env.DATABASE_URL);
    db = drizzle(activeQueryClient, { schema });
}

export { activeQueryClient, db };

// 1. スキーマオブジェクト全体を export
export { schema };

// 2. 個別のテーブルも directly re-export
export * from '../../schemas';
