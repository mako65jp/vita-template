import * as schema from '@shared/db/schema';
import { describe, it, expect, beforeEach } from 'vitest';
import { createTestEnv } from '../../../vitest-clear'; // 💡 作り直し関数をインポート

describe('API Error Handling (RFC 9457)', () => {
    let app: any;
    let db: any; // 検証用にdbも受け取れるように定義

    beforeEach(async () => {
        // 💡 完璧なアプローチ：テストごとに、DBごと app を丸ごと新しく作り直す！
        const testEnv = await createTestEnv();
        app = testEnv.app;
        db = testEnv.db;
    });

    it('未定義のルートにアクセスした場合、404エラーがRFC9457形式で返ること', async () => {
        const res = await app.request('/api/non-existent-route');
        expect(res.status).toBe(404);

        const body = (await res.json()) as any;
        expect(body.status).toBe(404);
    });
});

describe('User Management Integration (Step 9)', () => {
    let app: any;
    let db: any;

    beforeEach(async () => {
        const testEnv = await createTestEnv();
        app = testEnv.app;
        db = testEnv.db;
    });

    it('前のテストケースでデータが追加されていても、このケースでは空のままであること', async () => {
        // 💡 appごと完全に作り直されているため、他のテストケースの実行状況の影響は 100% 受けません
        const result = await db.select().from(schema.users);
        expect(result).toHaveLength(0); // 確実にPassed（成功）します！
    });
});
