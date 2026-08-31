import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { createTestEnv } from '../../../../vitest-clear'; // 💡 作り直し関数をインポート

describe('Health Check API (Step 6.1)', () => {
    let app: any;
    let db: any; // 検証用にdbも受け取れるように定義

    beforeEach(async () => {
        // 💡 完璧なアプローチ：テストごとに、DBごと app を丸ごと新しく作り直す！
        const testEnv = await createTestEnv();
        app = testEnv.app;
        db = testEnv.db;
    });

    it('GET /healthz - DB導通が正常な場合、200 OK と status: ok を返すこと', async () => {
        const res = await app.request('/healthz');

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body).toEqual({
            status: 'ok',
            db: 'connected',
        });
    });

    it('GET /healthz - DB接続エラーが発生した場合、503 と RFC 9457 形式のエラーを返すこと', async () => {
        vi.spyOn(db, 'execute').mockRejectedValueOnce(new Error('Database connection failed'));

        const res = await app.request('/healthz');
        expect(res.status).toBe(503);

        const body = await res.json();

        expect(body).toEqual({
            type: 'about:blank',
            title: 'Service Unavailable',
            status: 503,
            detail: 'Database connection failed',
            instance: '/healthz',
        });
    });
});

