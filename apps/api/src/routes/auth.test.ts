import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { authRouter } from './auth';
import { db, users } from '@shared/server';
import { AppError } from '@shared/errors';
import { hashPassword } from '@plugins/auth-local';

describe('Auth Routes (Step 4.3)', () => {
    const secret = 'test-secret-key-at-least-32-chars-long';

    // テスト用アプリのセットアップ
    const createTestApp = () => {
        const app = new Hono();

        // 統一エラーハンドラ
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

        app.route('/api/auth', authRouter(secret));
        return app;
    };

    // テスト用初期ユーザーのセットアップ
    beforeEach(async () => {
        // 既存データのクリーンアップ
        await db.delete(users);

        // テストユーザーを挿入
        const hashedPassword = await hashPassword('password123');
        await db.insert(users).values({
            name: 'Test User',
            email: 'test@example.com',
            passwordHash: hashedPassword,
            role: 'user',
        });
    });

    describe('POST /api/auth/login', () => {
        it('正しい資格情報でログインし、JWT トークンが返ること', async () => {
            const app = createTestApp();
            const res = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'test@example.com',
                    password: 'password123',
                }),
            });

            expect(res.status).toBe(200);
            const body = (await res.json()) as any;

            expect(body.token).toBeDefined();
            expect(body.user.email).toBe('test@example.com');
            expect(body.user.passwordHash).toBeUndefined();
        });

        it('誤ったパスワードの場合、401 エラーを返すこと', async () => {
            const app = createTestApp();
            const res = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'test@example.com',
                    password: 'wrongpassword',
                }),
            });

            expect(res.status).toBe(401);
        });


        it('存在しないメールアドレスの場合、401 エラーを返すこと', async () => {
            const app = createTestApp();
            const res = await app.request('/api/auth/login', {

                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'nonexistent@example.com',
                    password: 'password123',
                }),
            });

            expect(res.status).toBe(401);
        });
    });

    describe('GET /api/auth/me', () => {
        it('有効な JWT トークンで自分のプロファイルを取得できること', async () => {
            const app = createTestApp();

            // 1. ログインしてトークン取得
            const loginRes = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'test@example.com',
                    password: 'password123',
                }),
            });
            const { token } = (await loginRes.json()) as any;

            // 2. /me にリクエスト


            const meRes = await app.request('/api/auth/me', {
                headers: { Authorization: `Bearer ${token}` },


            });

            expect(meRes.status).toBe(200);
            const meBody = (await meRes.json()) as any;
            expect(meBody.user.email).toBe('test@example.com');
            expect(meBody.user.passwordHash).toBeUndefined();
        });

        it('Authorization ヘッダーがない場合、401 エラーを返すこと', async () => {
            const app = createTestApp();
            const res = await app.request('/api/auth/me');

            expect(res.status).toBe(401);
        });
    });
});
