import { vi, beforeEach } from 'vitest';
import { newDb } from 'pg-mem';
import { drizzle } from 'drizzle-orm/node-postgres';
import { applyIntegrationsToPool } from 'drizzle-pgmem';
import * as actualSchema from '@shared/schemas'; // パスはプロジェクトに合わせて調整してください

// 1. メモリDBインスタンスの作成
const mem = newDb({
    autoCreateForeignKeyIndices: true,
});

const { Pool } = mem.adapters.createPg();
const pool = new Pool();

applyIntegrationsToPool(pool);

const memDb = drizzle(pool, { schema: actualSchema });

// 2. 💡 テーブルの初期作成（ここはファイル読み込み時に一度だけ実行する。DROPは絶対に書かない）
mem.public.none(`
  CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL
  );

  CREATE TABLE IF NOT EXISTS plugins (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL
  );
`);

// 3. モックの設定
vi.mock('@shared/server', async (importOriginal) => {
    const actual = await importOriginal<typeof import('@shared/server')>();
    return {
        ...actual,
        db: memDb,
        activeQueryClient: pool,
    };
});

// 4. 💡 各テスト実行前の処理（テーブル構造は壊さず、データとシーケンスだけをきれいにする）
beforeEach(() => {
    mem.public.none(`
    DELETE FROM users;
    DELETE FROM plugins;
  `);

    // SERIALのカウンターを1に戻す
    try {
        mem.public.none(`ALTER SEQUENCE users_id_seq RESTART WITH 1;`);
    } catch (e) {
        // 無視
    }
});
