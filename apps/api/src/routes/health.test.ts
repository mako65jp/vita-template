import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { createTestEnv } from '../../../../vitest-helpers'; // プロジェクトの共通環境作成関数

describe('Health Check API (Step 6.1)', () => {

    beforeEach(async () => {
    });

    it('GET /healthz - DB導通が正常な場合、200 OK と status: ok を返すこと', async () => {

        // 1. クリーンなテスト環境を取得
        const { app, db, pglite } = await createTestEnv();

        const res = await app.request('/healthz');

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body).toEqual({
            status: 'ok',
            db: 'connected',
        });

        // 必ず、PGliteをクローズする
        await pglite.close();
    });

    it('GET /healthz - DB接続エラーが発生した場合、503 と RFC 9457 形式のエラーを返すこと', async () => {

        // 1. クリーンなテスト環境を取得
        const { app, db, pglite } = await createTestEnv();

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

        // 必ず、PGliteをクローズする
        await pglite.close();
    });
});

