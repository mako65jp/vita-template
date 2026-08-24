import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { db, users } from '@shared/server';
import { eq } from 'drizzle-orm';
import { userRoutes } from './routes';

describe('User Management Plugin API', () => {
    const app = new Hono();
    app.route('/', userRoutes);

    // テスト内で動的に取得したユーザーの ID を保持する変数
    let adminId: number;
    let userId: number;

    beforeEach(async () => {
        await db.delete(users);

        // id を指定せず、DBの自動採番（SERIAL）に任せて挿入
        const insertedUsers = await db.insert(users).values([
            {
                name: '管理者',
                email: 'admin@example.com',
                passwordHash: 'hashed',
                role: 'admin',
                isActive: true,
            },
            {
                name: '一般ユーザー',
                email: 'user@example.com',
                passwordHash: 'hashed',
                role: 'user',
                isActive: true,
            },
        ]).returning();

        // 挿入されたレコードから実際の ID を取得して変数に格納
        adminId = insertedUsers[0].id;
        userId = insertedUsers[1].id;
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
                password: 'securePassword123', // ルート側が必要としている場合は追加
            }),
        });

        if (res.status === 500) {
            const errorText = await res.text();
            console.error('--- POST 500 ERROR DETAILS ---', errorText);
        }

        expect(res.status).toBe(201);
        const body = await res.json();
        expect(body.user.email).toBe('plugin_new@example.com');
    });

    it('PATCH /:id/role - ユーザーのロールを変更できること', async () => {
        // 固定の '2' ではなく、変数（userId）の動的なIDを使う
        const res = await app.request(`/${userId}/role`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ role: 'admin' }),
        });

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body.user.role).toBe('admin');
    });

    it('PATCH /:id/status - アカウント有効/無効を切り替えられること', async () => {
        // 固定の '2' ではなく、変数（userId）の動的なIDを使う
        const res = await app.request(`/${userId}/status`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ isActive: false }),
        });

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body.user.isActive).toBe(false);
    });

    it('DELETE /:id - ユーザーを削除できること', async () => {
        // 固定の '2' ではなく、変数（userId）の動的なIDを使う
        const res = await app.request(`/${userId}`, {
            method: 'DELETE',
        });
        expect(res.status).toBe(200);
    });
});
