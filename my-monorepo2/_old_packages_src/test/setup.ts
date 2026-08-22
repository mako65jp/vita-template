import { beforeEach } from 'vitest';
import { db } from '../server'; // テスト用DBに接続しているDrizzleインスタンス
import { sql } from 'drizzle-orm';
import '@testing-library/jest-dom';

beforeEach(async () => {
    // 全テーブルのデータをクリーンアップ（例: public スキーマ内の全テーブルを TRUNCATE）
    await db.execute(sql`
    DO $$ DECLARE
        r RECORD;
    BEGIN
        FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
            EXECUTE 'TRUNCATE TABLE ' || quote_ident(r.tablename) || ' CASCADE;';
        END LOOP;
    END $$;
  `);
});
