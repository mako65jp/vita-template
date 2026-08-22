import { describe, it, expect } from 'vitest';
import { Hono } from 'hono';

import { authMiddleware } from './auth-middleware';
import { AppError } from '@shared/errors';
import { signJwt } from '@plugins/auth-local';

describe('Auth Middleware (Step 4.2)', () => {
    const secret = 'test-secret-key-at-least-32-chars-long';

    // テスト用の Hono アプリセットアップ
    const createTestApp = () => {
        const app = new Hono();

        // 💡 統一エラーハンドラを設定する
        app.onError((err, c) => {
            if (err instanceof AppError) {
                return c.json(
                    {
                        type: 'about:blank',
                        title: err.title,
                        status: err.status,
                        detail: err.message,
                        instance: c.req.path,
                    },
                    err.status as any
                );
            }
            return c.json({ title: 'Internal Server Error', status: 500 }, 500);
        });

        // 認証が必要な保護ルート
        app.use('/protected/*', authMiddleware(secret));
        app.get('/protected/profile', (c) => {
            const user = c.get('user');
            return c.json({ message: 'Success', user });
        });


        return app;
    };


    it('Authorization ヘッダーがない場合、RFC 7807 形式で 401 エラーを返すこと', async () => {
        const app = createTestApp();
        const res = await app.request('/protected/profile');

        expect(res.status).toBe(401);
        const body = (await res.json()) as any;

        // RFC 7807 の形式チェック
        expect(body.status).toBe(401);
        expect(body.title).toBe('Unauthorized');
        expect(body.detail).toBeDefined();
    });

    it('不正なトークンの場合、401 エラーを返すこと', async () => {
        const app = createTestApp();
        const res = await app.request('/protected/profile', {
            headers: {
                Authorization: 'Bearer invalid-token-string',
            },
        });

        expect(res.status).toBe(401);
    });

    it('正常な Bearer トークンの場合、リクエストが通過しコンテキストにユーザー情報がセットされること', async () => {
        const app = createTestApp();
        const payload = { userId: 'user-123', role: 'admin' };
        const validToken = await signJwt(payload, secret);

        const res = await app.request('/protected/profile', {
            headers: {
                Authorization: `Bearer ${validToken}`,
            },
        });

        expect(res.status).toBe(200);
        const body = (await res.json()) as any;

        expect(body.message).toBe('Success');
        expect(body.user).toMatchObject(payload);
    });
});
