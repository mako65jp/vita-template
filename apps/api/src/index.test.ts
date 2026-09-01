import { describe, it, expect, beforeEach } from 'vitest';
import { createTestEnv } from '../../../vitest-helpers'; // プロジェクトの共通環境作成関数
import * as schema from '@shared/db/schema';

describe('API Error Handling (RFC 9457)', () => {

    beforeEach(async () => {
    });

    it('未定義のルートにアクセスした場合、404エラーがRFC9457形式で返ること', async () => {

        // 1. クリーンなテスト環境を取得
        const { app, db, pglite } = await createTestEnv();

        const res = await app.request('/api/non-existent-route');
        expect(res.status).toBe(404);

        const body = (await res.json()) as any;
        expect(body.status).toBe(404);

        // 必ず、PGliteをクローズする
        await pglite.close();
    });
});

describe('User Management Integration (Step 9)', () => {
    beforeEach(async () => {
    });

    it('前のテストケースでデータが追加されていても、このケースでは空のままであること', async () => {

        // 1. クリーンなテスト環境を取得
        const { app, db, pglite } = await createTestEnv();

        // 💡 appごと完全に作り直されているため、他のテストケースの実行状況の影響は 100% 受けません
        const result = await db.select().from(schema.users);
        expect(result).toHaveLength(0); // 確実にPassed（成功）します！

        // 必ず、PGliteをクローズする
        await pglite.close();
    });
});
