import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { db, users } from '@shared/server';
import { userRoutes } from './routes';

describe('User Management Plugin API', () => {
    const app = new Hono();
    app.route('/', userRoutes);

    beforeEach(async () => {
        await db.delete(users);

        await db.insert(users).values([
            {
                id: 1,
                name: '管理者',
                email: 'admin@example.com',
                passwordHash: 'hashed',
                role: 'admin',
                isActive: true,
            },
            {
                id: 2,
                name: '一般ユーザー',
                email: 'user@example.com',
                passwordHash: 'hashed',
                role: 'user',
                isActive: true,
            },
        ]);
    });

    it('GET / - ユーザー一覧を取得できること', async () => {
        const res = await app.request('/');
        expect(res.status).toBe(200);

        const body = await res.json();
        expect(body.users.length).toBe(2);
    });

    it('POST / - 新規ユーザーを追加できること', async () => {
        const res = await app.request('/', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                name: '新規プラグインユーザー',
                email: 'plugin_new@example.com',
                role: 'user',
            }),
        });

        expect(res.status).toBe(201);
        const body = await res.json();
        expect(body.user.email).toBe('plugin_new@example.com');
    });

    it('PATCH /:id/role - ユーザーのロールを変更できること', async () => {
        const res = await app.request('/2/role', {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ role: 'admin' }),
        });

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body.user.role).toBe('admin');
    });

    it('PATCH /:id/status - アカウント有効/無効を切り替えられること', async () => {
        const res = await app.request('/2/status', {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ isActive: false }),
        });

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body.user.isActive).toBe(false);
    });

    it('DELETE /:id - ユーザーを削除できること', async () => {
        const res = await app.request('/2', {
            method: 'DELETE',
        });

        expect(res.status).toBe(200);
    });
});
