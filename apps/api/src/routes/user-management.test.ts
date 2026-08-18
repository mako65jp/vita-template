import { describe, it, expect, beforeEach } from 'vitest';
import app from '../index';
import { signJwt } from '@app/plugins-auth-local';
import { env } from '@app/core';
import { db, users } from '@app/core/server';
import { eq } from 'drizzle-orm';

async function createToken(role: 'admin' | 'user', id: string = '1') {
    return await signJwt({ sub: id, role }, env.JWT_SECRET);
}

describe('User Management API Routes (PostgreSQL Integration)', () => {
    beforeEach(async () => {
        await db.delete(users);
        await db.insert(users).values([
            {
                id: 1,
                name: '管理者',
                email: 'admin@example.com',
                passwordHash: 'dummy_hash',
                role: 'admin',
                isActive: true,
            },
            {
                id: 2,
                name: '一般ユーザー',
                email: 'user@example.com',
                passwordHash: 'dummy_hash',
                role: 'user',
                isActive: true,
            },
        ]);
    });

    it('認証ヘッダーがない場合は 401 を返すこと', async () => {
        const res = await app.request('/api/user-management');
        expect(res.status).toBe(401);
    });

    it('一般ユーザーからのアクセスは 403 を返すこと', async () => {
        const token = await createToken('user', '2');
        const res = await app.request('/api/user-management', {
            headers: { Authorization: `Bearer ${token}` },
        });
        expect(res.status).toBe(403);
    });

    it('GET /api/user-management - ユーザー一覧を取得できること', async () => {
        const token = await createToken('admin', '1');
        const res = await app.request('/api/user-management', {
            headers: { Authorization: `Bearer ${token}` },
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(200);
        const data = (await res.json()) as any;
        expect(data.users.length).toBe(2);
        expect(data.users[0].email).toBe('admin@example.com');
    });

    it('POST /api/user-management - パスワード未指定時にユーザーを作成し、自動生成された initialPassword を返却すること', async () => {
        const token = await createToken('admin', '1');
        const res = await app.request('/api/user-management', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
                name: '新規追加ユーザー',
                email: 'newuser@example.com',
                role: 'user',
            }),
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(201);
        const data = (await res.json()) as any;
        expect(data.user).toHaveProperty('id');
        expect(data.user.email).toBe('newuser@example.com');
        expect(data.initialPassword).toBeDefined();

        const [savedUser] = await db.select().from(users).where(eq(users.email, 'newuser@example.com'));
        expect(savedUser).toBeDefined();
        expect(savedUser.passwordHash).not.toBe('default_hash');
    });

    it('POST /api/user-management - パスワードを明示的に指定してユーザーを作成できること', async () => {
        const token = await createToken('admin', '1');
        const customPassword = 'MyCustomPassword123!';
        const res = await app.request('/api/user-management', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
                name: 'カスタムパスワードユーザー',
                email: 'custompass@example.com',
                role: 'user',
                password: customPassword,
            }),
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(201);
        const data = (await res.json()) as any;
        expect(data.user.email).toBe('custompass@example.com');
        expect(data.initialPassword).toBe(customPassword);

        const [savedUser] = await db.select().from(users).where(eq(users.email, 'custompass@example.com'));
        expect(savedUser).toBeDefined();
    });

    it('POST /api/user-management - 短すぎるパスワード（8文字未満）の場合はバリデーションエラーを返すこと', async () => {
        const token = await createToken('admin', '1');
        const res = await app.request('/api/user-management', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
                name: 'エラーユーザー',
                email: 'erroruser@example.com',
                role: 'user',
                password: 'short',
            }),
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(400);
    });

    describe('安全策（自己操作の禁止）', () => {
        it('管理者自身（ID: 1）を削除しようとした場合、400 エラーになること', async () => {
            const token = await createToken('admin', '1');
            const res = await app.request('/api/user-management/1', {
                method: 'DELETE',
                headers: { Authorization: `Bearer ${token}` },
            });

            expect(res.status).toBe(400);
            const data = (await res.json()) as any;
            expect(data).toHaveProperty('title');
        });

        it('管理者自身（ID: 1）のロールを user に変更しようとした場合、400 エラーになること', async () => {
            const token = await createToken('admin', '1');
            const res = await app.request('/api/user-management/1/role', {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify({ role: 'user' }),
            });

            expect(res.status).toBe(400);
        });

        it('管理者自身（ID: 1）を無効化しようとした場合、400 エラーになること', async () => {
            const token = await createToken('admin', '1');
            const res = await app.request('/api/user-management/1/status', {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    Authorization: `Bearer ${token}`,
                },
                body: JSON.stringify({ isActive: false }),
            });

            expect(res.status).toBe(400);
        });
    });

    it('DELETE /api/user-management/:id - 他のユーザー（ID: 2）を正しく削除できること', async () => {
        const token = await createToken('admin', '1');
        const res = await app.request('/api/user-management/2', {
            method: 'DELETE',
            headers: { Authorization: `Bearer ${token}` },
        });

        if (res.status === 500) {
            console.error('500 Error Response Body:', await res.text());
        }

        expect(res.status).toBe(200);

        const [deletedUser] = await db.select().from(users).where(eq(users.id, 2));
        expect(deletedUser).toBeUndefined();
    });
});
