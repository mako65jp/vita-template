import { describe, it, expect, beforeEach } from 'vitest';
import app from '../index';
import { signJwt } from '@app/plugins-auth-local';
import { env } from '@app/core';
import { db, users } from '@app/core/server';
import { eq } from 'drizzle-orm';

async function createToken(id: string, role: 'admin' | 'user') {
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
        const token = await createToken('2', 'user');
        const res = await app.request('/api/user-management', {
            headers: { Authorization: `Bearer ${token}` },
        });
        expect(res.status).toBe(403);
    });

    it('GET /api/user-management - ユーザー一覧を取得できること', async () => {
        const token = await createToken('1', 'admin');
        const res = await app.request('/api/user-management', {
            headers: { Authorization: `Bearer ${token}` },
        });

        expect(res.status).toBe(200);
        const data = await res.json();
        expect(data.users.length).toBe(2);
        expect(data.users[0].email).toBe('admin@example.com');
    });

    it('POST /api/user-management - テスト用DBに新規ユーザーを挿入できること', async () => {
        const token = await createToken('1', 'admin');
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

        expect(res.status).toBe(201);
        const data = await res.json();
        expect(data.user).toHaveProperty('id');
        expect(data.user.email).toBe('newuser@example.com');

        // 仮ハッシュ（'default_hash'）ではなく暗号化されていること
        const [savedUser] = await db.select().from(users).where(eq(users.email, 'newuser@example.com'));
        expect(savedUser).toBeDefined();
        expect(savedUser.passwordHash).not.toBe('default_hash');
    });

    describe('安全策（自己操作の禁止）', () => {
        it('管理者自身（ID: 1）を削除しようとした場合、400 エラーになること', async () => {
            const token = await createToken('1', 'admin');
            const res = await app.request('/api/user-management/1', {
                method: 'DELETE',
                headers: { Authorization: `Bearer ${token}` },
            });

            expect(res.status).toBe(400);
            const data = await res.json();
            // RFC 9457 エラー形式の確認
            expect(data).toHaveProperty('title');
        });

        it('管理者自身（ID: 1）のロールを user に変更しようとした場合、400 エラーになること', async () => {
            const token = await createToken('1', 'admin');
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
            const token = await createToken('1', 'admin');
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
        const token = await createToken('1', 'admin');
        const res = await app.request('/api/user-management/2', {
            method: 'DELETE',
            headers: { Authorization: `Bearer ${token}` },
        });

        expect(res.status).toBe(200);

        const [deletedUser] = await db.select().from(users).where(eq(users.id, 2));
        expect(deletedUser).toBeUndefined();
    });
});

// import { describe, it, expect, beforeEach } from 'vitest';
// import app from '../index';
// import { signJwt } from '@app/plugins-auth-local';
// import { env } from '@app/core';
// import { db, users } from '@app/core/server';
// import { eq } from 'drizzle-orm';

// async function createToken(role: 'admin' | 'user') {
//     return await signJwt({ sub: '1', role }, env.JWT_SECRET);
// }

// describe('User Management API Routes (PostgreSQL Integration)', () => {
//     beforeEach(async () => {
//         await db.delete(users);
//         await db.insert(users).values([
//             {
//                 id: 1,
//                 name: '管理者',
//                 email: 'admin@example.com',
//                 passwordHash: 'dummy_hash',
//                 role: 'admin',
//                 isActive: true,
//             },
//             {
//                 id: 2,
//                 name: '一般ユーザー',
//                 email: 'user@example.com',
//                 passwordHash: 'dummy_hash',
//                 role: 'user',
//                 isActive: true,
//             },
//         ]);
//     });

//     it('認証ヘッダーがない場合は 401 を返すこと', async () => {
//         const res = await app.request('/api/user-management');
//         expect(res.status).toBe(401);
//     });

//     it('一般ユーザーからのアクセスは 403 を返すこと', async () => {
//         const token = await createToken('user');
//         const res = await app.request('/api/user-management', {
//             headers: { Authorization: `Bearer ${token}` },
//         });
//         expect(res.status).toBe(403);
//     });

//     it('GET /api/user-management - ユーザー一覧を取得できること', async () => {
//         const token = await createToken('admin');
//         const res = await app.request('/api/user-management', {
//             headers: { Authorization: `Bearer ${token}` },
//         });

//         // 500の場合にレスポンスボディ（エラー内容）を出力してログで確認する
//         if (res.status === 500) {
//             console.error('500 Error Response Body:', await res.text());
//         }

//         expect(res.status).toBe(200);
//         const data = await res.json();
//         expect(data.users.length).toBe(2);
//         expect(data.users[0].email).toBe('admin@example.com');
//     });

//     it('POST /api/user-management - テスト用DBに新規ユーザーを挿入できること', async () => {
//         const token = await createToken('admin');
//         const res = await app.request('/api/user-management', {
//             method: 'POST',
//             headers: {
//                 'Content-Type': 'application/json',
//                 Authorization: `Bearer ${token}`,
//             },
//             body: JSON.stringify({
//                 name: '新規追加ユーザー',
//                 email: 'newuser@example.com',
//                 role: 'user',
//             }),
//         });

//         if (res.status === 500) {
//             console.error('500 Error Response Body:', await res.text());
//         }

//         expect(res.status).toBe(201);
//         const data = await res.json();
//         expect(data.user).toHaveProperty('id');
//         expect(data.user.email).toBe('newuser@example.com');

//         const [savedUser] = await db.select().from(users).where(eq(users.email, 'newuser@example.com'));
//         expect(savedUser).toBeDefined();
//     });

//     it('DELETE /api/user-management/:id - テスト用DBからユーザーを削除できること', async () => {
//         const token = await createToken('admin');
//         const res = await app.request('/api/user-management/2', {
//             method: 'DELETE',
//             headers: { Authorization: `Bearer ${token}` },
//         });

//         if (res.status === 500) {
//             console.error('500 Error Response Body:', await res.text());
//         }

//         expect(res.status).toBe(200);

//         const [deletedUser] = await db.select().from(users).where(eq(users.id, 2));
//         expect(deletedUser).toBeUndefined();
//     });
// });
