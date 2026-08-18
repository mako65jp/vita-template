import { describe, it, expect } from 'vitest';
import { Hono } from 'hono';

import { authMiddleware } from './auth-middleware';
import { rbacMiddleware } from './rbac-middleware';
import { AppError } from '@app/core';
import { signJwt } from '@app/plugins-auth-local';

describe('RBAC Middleware (Step 4.3)', () => {
    const secret = 'test-secret-key-at-least-32-chars-long';

    const createTestApp = () => {
        const app = new Hono();

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

        // 認証後に admin ロールのみ許可する管理者ルート
        app.use('/admin/*', authMiddleware(secret));
        app.use('/admin/*', rbacMiddleware(['admin']));

        app.get('/admin/dashboard', (c) => {
            return c.json({ message: 'Admin Dashboard' });
        });

        return app;
    };

    it('一般ユーザー (role: user) の場合、403 Forbidden を返すこと', async () => {
        const app = createTestApp();
        const userToken = await signJwt({ userId: 'u1', role: 'user' }, secret);
        const res = await app.request('/admin/dashboard', {
            headers: { Authorization: `Bearer ${userToken}` },
        });

        expect(res.status).toBe(403);
        const body = (await res.json()) as any;

        expect(body.title).toBe('Forbidden');
        expect(body.status).toBe(403);
    });

    it('管理者ユーザー (role: admin) の場合、200 OK でアクセス許可されること', async () => {
        const app = createTestApp();
        const adminToken = await signJwt({ userId: 'a1', role: 'admin' }, secret);
        const res = await app.request('/admin/dashboard', {
            headers: { Authorization: `Bearer ${adminToken}` },
        });

        expect(res.status).toBe(200);
        const body = (await res.json()) as any;

        expect(body.message).toBe('Admin Dashboard');
    });
});
