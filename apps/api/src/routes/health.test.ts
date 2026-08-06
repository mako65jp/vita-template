import { describe, it, expect, vi } from 'vitest';
import app from '../index';
import { db } from '@app/core';

describe('Health Check API (Step 6.1)', () => {
    it('GET /healthz - DB導通が正常な場合、200 OK と status: ok を返すこと', async () => {
        const res = await app.request('/healthz');

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body).toEqual({
            status: 'ok',
            db: 'connected',
        });
    });

    it('GET /healthz - DB接続エラーが発生した場合、503 と RFC 7807 形式のエラーを返すこと', async () => {
        // db.execute をモック化してエラーを発生させる
        const spy = vi.spyOn(db, 'execute').mockRejectedValueOnce(new Error('DB Connection Failed'));

        const res = await app.request('/healthz');

        expect(res.status).toBe(503);
        const body = await res.json();

        // 共通エラーハンドラーの出力形式（toEqual で完全一致）
        expect(body).toEqual({
            type: 'https://api.example.com/errors/SERVICE_UNAVAILABLE',
            title: 'Service Unavailable',
            status: 503,
            detail: 'Database connection failed',
            instance: '/healthz',
        });

        spy.mockRestore();
    });
});
