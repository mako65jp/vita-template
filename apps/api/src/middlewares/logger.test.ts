import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { Hono } from 'hono';
import { loggerMiddleware } from './logger';

describe('Logger Middleware (Step 6.2)', () => {
    let consoleSpy: any;

    beforeEach(() => {
        consoleSpy = vi.spyOn(console, 'log').mockImplementation(() => { });
    });

    afterEach(() => {
        consoleSpy.mockRestore();
    });

    it('リクエスト完了時、メソッド・パス・ステータス・処理時間を JSON 形式でログ出力すること', async () => {
        const app = new Hono();
        app.use('*', loggerMiddleware);
        app.get('/test', (c) => c.text('OK', 200));

        const res = await app.request('/test');
        expect(res.status).toBe(200);

        expect(consoleSpy).toHaveBeenCalledTimes(1);
        const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);
        expect(logOutput).toMatchObject({
            level: 'info',
            method: 'GET',
            path: '/test',
            status: 200,
        });
        expect(typeof logOutput.durationMs).toBe('number');
    });

    it('Authorization ヘッダー等の機密情報がログに含まれる場合、マスク処理されること', async () => {
        const app = new Hono();
        app.use('*', loggerMiddleware);
        app.post('/login', (c) => c.text('OK', 200));

        await app.request('/login', {
            method: 'POST',
            headers: {
                Authorization: 'Bearer secret-token-123',
            },
        });

        const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);

        // 1. まず headers プロパティが確実に定義されている（undefinedでない）ことを検証
        expect(logOutput.headers).toBeDefined();

        // 2. その上で authorization がマスクされていることを検証
        expect(logOutput.headers.authorization).toBeDefined();
        expect(logOutput.headers.authorization).toBe('***');
    });

    it('4xx 系の業務エラー（401等）発生時、level が "info" でありスタックトレースが含まれないこと', async () => {
        const app = new Hono();
        app.use('*', loggerMiddleware);

        app.get('/unauthorized', () => {
            throw new Error('Invalid credentials');
        });

        app.onError((err, c) => {
            c.error = err;
            return c.json({ message: err.message }, 401);
        });

        const res = await app.request('/unauthorized');
        expect(res.status).toBe(401);

        const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);
        expect(logOutput).toMatchObject({
            level: 'info',
            method: 'GET',
            path: '/unauthorized',
            status: 401,
        });
        expect(logOutput.error).toBeUndefined();
    });

    it('500系エラー発生時、level が "error" となりエラーメッセージとスタックトレースが JSON に含まれること', async () => {
        const app = new Hono();
        app.use('*', loggerMiddleware);

        app.get('/error', () => {
            throw new Error('Internal Server Error Test');
        });

        app.onError((err, c) => {
            c.error = err;
            return c.json({ message: err.message }, 500);
        });

        const res = await app.request('/error');
        expect(res.status).toBe(500);

        const logOutput = JSON.parse(consoleSpy.mock.calls[0][0]);
        expect(logOutput).toMatchObject({
            level: 'error',
            method: 'GET',
            path: '/error',
            status: 500,
            error: {
                message: 'Internal Server Error Test',
            },
        });
        expect(typeof logOutput.error.stack).toBe('string');
    });
});
