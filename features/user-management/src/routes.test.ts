// @vitest-environment node
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Hono } from 'hono';
import * as schema from '@shared/db/schema';
import { createTestEnv } from '../../../vitest-clear'; // プロジェクトの共通環境作成関数
import { signJwt } from '@plugins/auth-local';

describe('User Management Plugin API - インメモリ完全隔離・正攻法結合テスト', async () => {
    let app: Hono<any>;
    let db: any;
    let adminToken: string; // 本物のアプリが100%正規のトークンとして認める、正真正銘の本物トークン

    const BASE_PATH = '/api/user-management';
    const TEST_JWT_SECRET = 'your-super-secret-jwt-key-must-be-at-least-32-bytes-long';

    beforeEach(async () => {
        vi.restoreAllMocks();

        // 1. 環境変数の鍵をテスト用に一時同期
        process.env.JWT_SECRET = TEST_JWT_SECRET;

        // 2. 本物の app と 隔離済みの db を取得
        const testEnv = await createTestEnv();
        app = testEnv.app;
        db = testEnv.db;

        // 3. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
        // 自動的に id: 1 になる（管理者）
        await db.insert(schema.users).values({
            name: 'Admin User',
            email: 'admin@example.com',
            passwordHash: 'dummy_hash_for_test',
            role: 'admin',
            isActive: true,
        });

        // 自動的に id: 2 になる（一般ユーザー）
        await db.insert(schema.users).values({
            name: 'General User',
            email: 'user@example.com',
            passwordHash: 'dummy_hash_for_test',
            role: 'user',
            isActive: true,
        });

        adminToken = await signJwt({ userId: '1', role: 'admin' }, TEST_JWT_SECRET);
    });

    // ----------------------------------------------------
    // 1. GET (ユーザー一覧取得)
    // ----------------------------------------------------
    describe('GET /', () => {
        it('正しい管理者トークンを付与した場合、200 OK でユーザー一覧を取得できること', async () => {
            const res = await app.request(`${BASE_PATH}`, {
                method: 'GET',
                headers: { 'Authorization': `Bearer ${adminToken}` },
            });
            expect(res.status).toBe(200);

            const body = await res.json();
            expect(body.users).toHaveLength(2);

            // 💡 崩れていた構文（タイポ）を100%完全に修復・整形しました
            expect(body.users).toContainEqual(
                expect.objectContaining({ id: 1, name: 'Admin User', email: 'admin@example.com', role: 'admin' })
            );
            expect(body.users).toContainEqual(
                expect.objectContaining({ id: 2, name: 'General User', email: 'user@example.com', role: 'user' })
            );
        });

        it('トークンを付与せずにアクセスした場合、401(Unauthorized) で厳格に弾かれること', async () => {
            const res = await app.request(`${BASE_PATH}`);
            expect(res.status).toBe(401);
        });
    });

    // ----------------------------------------------------
    // 2. POST (ユーザー新規追加)
    // ----------------------------------------------------
    describe('POST /', () => {
        const validUser = {
            name: '新規 ユーザー',
            email: 'new@example.com',
            password: 'password123',
            role: 'user',
        };

        it('正規の管理者が正しいデータで新規ユーザーを追加でき、201が返ること', async () => {
            const res = await app.request(`${BASE_PATH}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify(validUser),
            });

            expect(res.status).toBe(201);
            const body = await res.json();
            expect(body.user.email).toBe('new@example.com');
            expect(body.user.role).toBe('user');
        });

        it('既に存在するメールアドレスを指定した場合、400エラー(BadRequest)が返ること', async () => {
            const res = await app.request(`${BASE_PATH}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({
                    ...validUser,
                    email: 'user@example.com',
                }),
            });

            expect(res.status).toBe(400);
        });

        it('Zodによるバリデーションエラー（パスワードが短いなど）で、400が返ること', async () => {
            const res = await app.request(`${BASE_PATH}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ ...validUser, password: 'short' }),
            });

            expect(res.status).toBe(400);
        });
    });

    // ----------------------------------------------------
    // 3. PATCH (ロール変更)
    // ----------------------------------------------------
    describe('PATCH /:id/role', () => {
        it('管理者が自分以外のユーザーのロールを正常に変更できること', async () => {
            const res = await app.request(`${BASE_PATH}/2/role`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ role: 'admin' }),
            });

            expect(res.status).toBe(200);
            const body = await res.json();
            expect(body.user.role).toBe('admin');
        });

        it('自分自身(ログイン中の管理者自身)の権限を降格させようとすると 400 で却下されること', async () => {
            const res = await app.request(`${BASE_PATH}/1/role`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ role: 'user' }),
            });

            expect(res.status).toBe(400);
        });

        it('存在しないユーザーIDを指定した場合、404エラー(NotFound)が返ること', async () => {
            const res = await app.request(`${BASE_PATH}/999/role`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ role: 'admin' }),
            });

            expect(res.status).toBe(404);
        });
    });

    // ----------------------------------------------------
    // 4. PATCH (アカウント有効/無効化)
    // ----------------------------------------------------
    describe('PATCH /:id/status', () => {
        it('他のユーザーを正常に無効化できること', async () => {
            const res = await app.request(`${BASE_PATH}/2/status`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ isActive: false }),
            });

            expect(res.status).toBe(200);
            const body = await res.json();
            expect(body.user.isActive).toBe(false);
        });

        it('自分自身のアカウントを無効化しようとすると 400 で却下されること', async () => {
            const res = await app.request(`${BASE_PATH}/1/status`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ isActive: false }),
            });

            expect(res.status).toBe(400);
        });
    });

    // ----------------------------------------------------
    // 5. DELETE (ユーザー削除)
    // ----------------------------------------------------
    describe('DELETE /:id', () => {
        it('他のユーザーを正常に削除できること', async () => {
            const res = await app.request(`${BASE_PATH}/2`, {
                method: 'DELETE',
                headers: { 'Authorization': `Bearer ${adminToken}` },
            });

            expect(res.status).toBe(200);
            const body = await res.json();
            expect(body.message).toBe('ユーザーを削除しました');

            const currentUsers = await db.select().from(schema.users);
            expect(currentUsers).toHaveLength(1);
        });

        it('自分自身を削除しようとした場合、400 で却下されること', async () => {
            const res = await app.request(`${BASE_PATH}/1`, {
                method: 'DELETE',
                headers: { 'Authorization': `Bearer ${adminToken}` },
            });

            expect(res.status).toBe(400);
        });
    });
});


// import { describe, it, expect, beforeEach, vi } from 'vitest';
// import { Hono } from 'hono';
// import { userRoutes } from './routes'; // 実際のファイルパスに合わせて調整してください
// import * as schema from '@shared/db/schema';
// import { createTestEnv } from '../../../vitest-clear'; // プロジェクトの共通環境作成関数
// import { hashPassword } from '@plugins/auth-local';

// describe('User Management Plugin API - インメモリ完全隔離テスト', () => {
//     let app: Hono<any>;
//     let db: any;

//     beforeEach(async () => {
//         vi.clearAllMocks();

//         // 💡 100% 確実なアプローチ：DBごとテストケースごとに環境を完全新規作成する
//         const testEnv = await createTestEnv();
//         db = testEnv.db;

//         // ルーター単体を親 Hono にマウントして検証するためのテスト用アプリを構築
//         app = new Hono();
//         app.use('*', async (c, next) => {
//             // ハンドラーが要求する 'dbInstance' をコンテキストに注入
//             c.set('dbInstance', db);
//             await next();
//         });

//         // テスト対象のユーザールートをそのままルートにマウント
//         app.route('/', userRoutes);
//     });

//     // ----------------------------------------------------
//     // 1. GET / (ユーザー一覧取得)
//     // ----------------------------------------------------
//     describe('GET /', () => {
//         it('登録されているユーザー一覧を取得できること', async () => {
//             // 初期データを2件インサート
//             await db.insert(schema.users).values([
//                 { name: 'User A', email: 'a@example.com', passwordHash: 'hash1', role: 'admin', isActive: true },
//                 { name: 'User B', email: 'b@example.com', passwordHash: 'hash2', role: 'user', isActive: false },
//             ]);

//             const res = await app.request('/');
//             expect(res.status).toBe(200);

//             const body = await res.json();
//             expect(body.users).toHaveLength(2);
//             expect(body.users).toMatchObject([
//                 { name: 'User A', email: 'a@example.com', role: 'admin', isActive: true },
//                 { name: 'User B', email: 'b@example.com', role: 'user', isActive: false }
//             ]);
//         });

//         it('ユーザーが1件も存在しない場合は空配列が返ること', async () => {
//             const res = await app.request('/');
//             expect(res.status).toBe(200);
//             const body = await res.json();
//             expect(body.users).toEqual([]);
//         });
//     });

//     // ----------------------------------------------------
//     // 2. POST / (ユーザー新規追加)
//     // ----------------------------------------------------
//     describe('POST /', () => {
//         const validUser = {
//             name: '新規 ユーザー',
//             email: 'new@example.com',
//             password: 'password123',
//             role: 'user',
//         };

//         it('正しいデータで新規ユーザーを追加でき、201が返ること', async () => {
//             const res = await app.request('/', {
//                 method: 'POST',
//                 headers: { 'Content-Type': 'application/json' },
//                 body: JSON.stringify(validUser),
//             });

//             expect(res.status).toBe(201);
//             const body = await res.json();
//             expect(body.user).toHaveProperty('id');
//             expect(body.user.email).toBe('new@example.com');
//             expect(body.user.role).toBe('user');
//             expect(body.user.isActive).toBe(true);
//             expect(body.user).not.toHaveProperty('passwordHash'); // 返却値に含まれないことを検証
//         });

//         it('既に存在するメールアドレスを指定した場合、エラーが発生すること', async () => {
//             // あらかじめ同一メールアドレスを登録しておく
//             await db.insert(schema.users).values({
//                 name: '既存',
//                 email: 'new@example.com',
//                 passwordHash: 'hash',
//                 role: 'user',
//             });

//             // 💡 Honoは内部エラーをキャッチしてResponseオブジェクトに変えるため、普通にawaitします
//             const res = await app.request('/', {
//                 method: 'POST',
//                 headers: { 'Content-Type': 'application/json' },
//                 body: JSON.stringify(validUser),
//             });

//             // 素のルーター状態（c.onError未設定）では500になります。
//             // グローバルハンドラー設定後は各カスタムエラーコード（400等）に直してください。
//             expect(res.status).toBe(500);
//         });

//         it('Zodによるバリデーションエラー（パスワードが短いなど）でValidationErrorがスローされること', async () => {
//             const invalidUser = { ...validUser, password: 'short' }; // 8文字未満

//             const res = await app.request('/', {
//                 method: 'POST',
//                 headers: { 'Content-Type': 'application/json' },
//                 body: JSON.stringify(invalidUser),
//             });

//             expect(res.status).toBe(500);
//         });
//     });

//     // ----------------------------------------------------
//     // 3. PATCH /:id/role (ロール変更)
//     // ----------------------------------------------------
//     describe('PATCH /:id/role', () => {
//         beforeEach(async () => {
//             // テスト用ユーザーをあらかじめ作成 (ID: 1 となる)
//             await db.insert(schema.users).values({
//                 name: 'ロール変更対象',
//                 email: 'role@example.com',
//                 passwordHash: 'hash',
//                 role: 'user',
//             });
//         });

//         it('存在するユーザーのロールを正常に変更できること', async () => {
//             const res = await app.request('/1/role', {
//                 method: 'PATCH',
//                 headers: { 'Content-Type': 'application/json' },
//                 body: JSON.stringify({ role: 'admin' }),
//             });

//             expect(res.status).toBe(200);
//             const body = await res.json();
//             expect(body.user.role).toBe('admin');
//         });

//         it('自分自身(ログインユーザー)の管理者権限を降格させようとすると却下されること', async () => {
//             // 💡 c.get('user') をエミュレートするため、専用のテスト環境用親Honoを一時的にリビルド
//             app = new Hono();
//             app.use('*', async (c, next) => {
//                 c.set('dbInstance', db);
//                 c.set('user', { id: 1 }); // 自分を ID: 1 に強制設定
//                 await next();
//             });
//             app.route('/', userRoutes);

//             // 自分自身の権限を user へ降格させようとするリクエスト
//             const res = await app.request('/1/role', {
//                 method: 'PATCH',
//                 headers: { 'Content-Type': 'application/json' },
//                 body: JSON.stringify({ role: 'user' }),
//             });

//             expect(res.status).toBe(500);
//         });

//         it('存在しないユーザーIDを指定した場合、NotFoundErrorがスローされること', async () => {
//             const res = await app.request('/999/role', {
//                 method: 'PATCH',
//                 headers: { 'Content-Type': 'application/json' },
//                 body: JSON.stringify({ role: 'admin' }),
//             });

//             expect(res.status).toBe(500);
//         });
//     });

//     // ----------------------------------------------------
//     // 4. PATCH /:id/status (アカウント有効/無効化)
//     // ----------------------------------------------------
//     describe('PATCH /:id/status', () => {
//         beforeEach(async () => {
//             // テスト用ユーザーを作成 (ID: 1)
//             await db.insert(schema.users).values({
//                 name: 'ステータス変更対象',
//                 email: 'status@example.com',
//                 passwordHash: 'hash',
//                 role: 'user',
//                 isActive: true,
//             });
//         });

//         it('正常にアカウントを無効化できること', async () => {
//             const res = await app.request('/1/status', {
//                 method: 'PATCH',
//                 headers: { 'Content-Type': 'application/json' },
//                 body: JSON.stringify({ isActive: false }),
//             });

//             expect(res.status).toBe(200);
//             const body = await res.json();
//             expect(body.user.isActive).toBe(false);
//         });

//         it('自分自身(ログインユーザー)のアカウントを無効化しようとすると却下されること', async () => {
//             // 自分を ID: 1 として偽装マウント
//             app = new Hono();
//             app.use('*', async (c, next) => {
//                 c.set('dbInstance', db);
//                 c.set('user', { sub: '1' }); // サポートされている sub 形式で自分を設定
//                 await next();
//             });
//             app.route('/', userRoutes);

//             const res = await app.request('/1/status', {
//                 method: 'PATCH',
//                 headers: { 'Content-Type': 'application/json' },
//                 body: JSON.stringify({ isActive: false }),
//             });

//             expect(res.status).toBe(500);
//         });
//     });

//     // ----------------------------------------------------
//     // 5. DELETE /:id (ユーザー削除)
//     // ----------------------------------------------------
//     describe('DELETE /:id', () => {
//         beforeEach(async () => {
//             // テスト用ユーザーを作成 (ID: 1)
//             await db.insert(schema.users).values({
//                 name: '削除対象',
//                 email: 'delete@example.com',
//                 passwordHash: 'hash',
//                 role: 'user',
//             });
//         });

//         it('存在するユーザーを正常に削除できること', async () => {
//             const res = await app.request('/1', {
//                 method: 'DELETE',
//             });

//             expect(res.status).toBe(200);
//             const body = await res.json();
//             expect(body.message).toBe('ユーザーを削除しました');
//             expect(body.user.email).toBe('delete@example.com');

//             // 実際にDBから消えているか追加検証
//             const currentUsers = await db.select().from(schema.users);
//             expect(currentUsers).toHaveLength(0);
//         });

//         it('自分自身を削除しようとした場合、却下されること', async () => {
//             // 自分を ID: 1 として設定
//             app = new Hono();
//             app.use('*', async (c, next) => {
//                 c.set('dbInstance', db);
//                 c.set('user', { id: 1 });
//                 await next();
//             });
//             app.route('/', userRoutes);

//             const res = await app.request('/1', {
//                 method: 'DELETE',
//             });

//             expect(res.status).toBe(500);
//         });
//     });
// });




// // import { describe, it, expect, beforeEach } from 'vitest';
// // import { Hono } from 'hono';
// // import { db, users } from '@shared/server';
// // import { eq } from 'drizzle-orm';
// // import { userRoutes } from './routes';

// // describe('User Management Plugin API', () => {
// //     const app = new Hono();
// //     app.route('/', userRoutes);

// //     // テスト内で動的に取得したユーザーの ID を保持する変数
// //     let adminId: number;
// //     let userId: number;

// //     beforeEach(async () => {
// //         await db.delete(users);

// //         // id を指定せず、DBの自動採番（SERIAL）に任せて挿入
// //         const insertedUsers = await db.insert(users).values([
// //             {
// //                 name: '管理者',
// //                 email: 'admin@example.com',
// //                 passwordHash: 'hashed',
// //                 role: 'admin',
// //                 isActive: true,
// //             },
// //             {
// //                 name: '一般ユーザー',
// //                 email: 'user@example.com',
// //                 passwordHash: 'hashed',
// //                 role: 'user',
// //                 isActive: true,
// //             },
// //         ]).returning();

// //         // 挿入されたレコードから実際の ID を取得して変数に格納
// //         adminId = insertedUsers[0].id;
// //         userId = insertedUsers[1].id;
// //     });

// //     it('GET / - ユーザー一覧を取得できること', async () => {
// //         const res = await app.request('/');

// //         expect(res.status).toBe(200);
// //         const body = await res.json();
// //         expect(body.users.length).toBe(2);
// //     });

// //     it('POST / - 新規ユーザーを追加できること', async () => {
// //         const res = await app.request('/', {
// //             method: 'POST',
// //             headers: { 'Content-Type': 'application/json' },
// //             body: JSON.stringify({
// //                 name: '新規プラグインユーザー',
// //                 email: 'plugin_new@example.com',
// //                 role: 'user',
// //                 password: 'securePassword123', // ルート側が必要としている場合は追加
// //             }),
// //         });

// //         if (res.status === 500) {
// //             const errorText = await res.text();
// //             console.error('--- POST 500 ERROR DETAILS ---', errorText);
// //         }

// //         expect(res.status).toBe(201);
// //         const body = await res.json();
// //         expect(body.user.email).toBe('plugin_new@example.com');
// //     });

// //     it('PATCH /:id/role - ユーザーのロールを変更できること', async () => {
// //         // 固定の '2' ではなく、変数（userId）の動的なIDを使う
// //         const res = await app.request(`/ ${ userId } / role`, {
// //             method: 'PATCH',
// //             headers: { 'Content-Type': 'application/json' },
// //             body: JSON.stringify({ role: 'admin' }),
// //         });

// //         expect(res.status).toBe(200);
// //         const body = await res.json();
// //         expect(body.user.role).toBe('admin');
// //     });

// //     it('PATCH /:id/status - アカウント有効/無効を切り替えられること', async () => {
// //         // 固定の '2' ではなく、変数（userId）の動的なIDを使う
// //         const res = await app.request(`/ ${ userId } / status`, {
// //             method: 'PATCH',
// //             headers: { 'Content-Type': 'application/json' },
// //             body: JSON.stringify({ isActive: false }),
// //         });

// //         expect(res.status).toBe(200);
// //         const body = await res.json();
// //         expect(body.user.isActive).toBe(false);
// //     });

// //     it('DELETE /:id - ユーザーを削除できること', async () => {
// //         // 固定の '2' ではなく、変数（userId）の動的なIDを使う
// //         const res = await app.request(`/ ${ userId }`, {
// //             method: 'DELETE',
// //         });
// //         expect(res.status).toBe(200);
// //     });
// // });
