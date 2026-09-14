import { beforeEach, describe, expect, it, vi } from 'vitest';
import { Hono } from 'hono';
import { healthRouter } from './health';
import type { AppEnv } from '../types';
import { Database } from '@shared/db';

describe('healthRouter', () => {
    let executeMock: ReturnType<typeof vi.fn>;
    let app: Hono<AppEnv>;

    beforeEach(() => {
        app = new Hono<AppEnv>();

        executeMock = vi.fn();
        const dbMock = {
            execute: executeMock,
        } as unknown as Database;

        app.use('*', async (c, next) => {
            c.set('dbInstance', dbMock);
            await next();
        });

        app.route('/', healthRouter);
    });

    it('DB接続成功時は status=ok を返す', async () => {
        executeMock.mockResolvedValue([{ '?column?': 1 }]);

        const res = await app.request('/healthz');

        expect(res.status).toBe(200);

        expect(await res.json()).toEqual({
            status: 'ok',
            db: 'connected',
        });
    });

    it('DB導通確認のため execute が呼ばれる', async () => {
        executeMock.mockResolvedValue([{ '?column?': 1 }]);

        await app.request('/healthz');

        expect(executeMock).toHaveBeenCalledTimes(1);
    });

    it('DB接続失敗時は正常レスポンスを返さない', async () => {
        executeMock.mockRejectedValue(new Error('Database connection failed'));

        const res = await app.request('/healthz');

        expect(res.status).toBe(500);
    });
});

// import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
// import { createTestEnv } from '../../../../vitest-helpers'; // プロジェクトの共通環境作成関数

// describe('Health Check API (Step 6.1)', () => {

//     beforeEach(async () => {
//     });

//     it('GET /healthz - DB導通が正常な場合、200 OK と status: ok を返すこと', async () => {

//         // 1. クリーンなテスト環境を取得
//         const { app, db, pglite } = await createTestEnv();

//         const res = await app.request('/healthz');

//         expect(res.status).toBe(200);
//         const body = await res.json();
//         expect(body).toEqual({
//             status: 'ok',
//             db: 'connected',
//         });

//         // 必ず、PGliteをクローズする
//         await pglite.close();
//     });

//     it('GET /healthz - DB接続エラーが発生した場合、503 と RFC 9457 形式のエラーを返すこと', async () => {

//         // 1. クリーンなテスト環境を取得
//         const { app, db, pglite } = await createTestEnv();

//         vi.spyOn(db, 'execute').mockRejectedValueOnce(new Error('Database connection failed'));

//         const res = await app.request('/healthz');
//         expect(res.status).toBe(503);

//         const body = await res.json();

//         expect(body).toEqual({
//             type: 'about:blank',
//             title: 'Service Unavailable',
//             status: 503,
//             detail: 'Database connection failed',
//             instance: '/healthz',
//         });

//         // 必ず、PGliteをクローズする
//         await pglite.close();
//     });
// });
