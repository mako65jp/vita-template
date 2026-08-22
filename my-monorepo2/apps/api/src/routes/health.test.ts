import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { createApp } from '../index';
import { db } from '@shared/server';

describe('Health Check API (Step 6.1)', () => {
    let app: Awaited<ReturnType<typeof createApp>>;

    beforeEach(async () => {
        vi.clearAllMocks();
        vi.restoreAllMocks();
        // 非同期でアプリの初期化（ルートのロード完了）を待つ
        app = await createApp();
    });

    afterEach(() => {
        vi.restoreAllMocks();
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

