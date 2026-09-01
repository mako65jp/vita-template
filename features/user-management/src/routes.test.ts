// @vitest-environment node
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createTestEnv } from '../../../vitest-helpers'; // プロジェクトの共通環境作成関数
import * as schema from '@shared/db/schema';
import { signJwt } from '@plugins/auth-local';

describe('User Management Plugin API - インメモリ完全隔離・正攻法結合テスト', async () => {

    const BASE_PATH = '/api/user-management';
    const TEST_JWT_SECRET = 'your-super-secret-jwt-key-must-be-at-least-32-bytes-long';

    beforeEach(async () => {
        vi.restoreAllMocks();
        process.env.JWT_SECRET = TEST_JWT_SECRET;
    });

    // テストデータのセット
    const setTestData = async (db: any): Promise<void> => {

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
    }

    // 管理者のトークン
    let adminToken = await signJwt({ userId: '1', role: 'admin' }, TEST_JWT_SECRET);

    // ----------------------------------------------------
    // 1. GET (ユーザー一覧取得)
    // ----------------------------------------------------
    describe('GET /', () => {
        it('正しい管理者トークンを付与した場合、200 OK でユーザー一覧を取得できること', async () => {

            // 1. クリーンなテスト環境を取得
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
            const res = await app.request(`${BASE_PATH}`, {
                method: 'GET',
                headers: { 'Authorization': `Bearer ${adminToken}` },
            });
            expect(res.status).toBe(200);

            const body = await res.json();
            expect(body.users).toHaveLength(2);
            expect(body.users).toContainEqual(
                expect.objectContaining({ id: 1, name: 'Admin User', email: 'admin@example.com', role: 'admin' })
            );
            expect(body.users).toContainEqual(
                expect.objectContaining({ id: 2, name: 'General User', email: 'user@example.com', role: 'user' })
            );

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('トークンを付与せずにアクセスした場合、401(Unauthorized) で厳格に弾かれること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 💡 3. 検証実行
            const res = await app.request(`${BASE_PATH}`);
            expect(res.status).toBe(401);

            // 必ず、PGliteをクローズする
            await pglite.close();
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

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
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

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('既に存在するメールアドレスを指定した場合、400エラー(BadRequest)が返ること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
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

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('Zodによるバリデーションエラー（パスワードが短いなど）で、400が返ること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
            const res = await app.request(`${BASE_PATH}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ ...validUser, password: 'short' }),
            });

            expect(res.status).toBe(400);

            // 必ず、PGliteをクローズする
            await pglite.close();
        });
    });

    // ----------------------------------------------------
    // 3. PATCH (ロール変更)
    // ----------------------------------------------------
    describe('PATCH /:id/role', () => {
        it('管理者が自分以外のユーザーのロールを正常に変更できること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
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

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('自分自身(ログイン中の管理者自身)の権限を降格させようとすると 400 で却下されること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
            const res = await app.request(`${BASE_PATH}/1/role`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ role: 'user' }),
            });

            expect(res.status).toBe(400);

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('存在しないユーザーIDを指定した場合、404エラー(NotFound)が返ること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
            const res = await app.request(`${BASE_PATH}/999/role`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ role: 'admin' }),
            });

            expect(res.status).toBe(404);

            // 必ず、PGliteをクローズする
            await pglite.close();
        });
    });

    // ----------------------------------------------------
    // 4. PATCH (アカウント有効/無効化)
    // ----------------------------------------------------
    describe('PATCH /:id/status', () => {
        it('他のユーザーを正常に無効化できること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
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

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('自分自身のアカウントを無効化しようとすると 400 で却下されること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
            const res = await app.request(`${BASE_PATH}/1/status`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${adminToken}`
                },
                body: JSON.stringify({ isActive: false }),
            });

            expect(res.status).toBe(400);

            // 必ず、PGliteをクローズする
            await pglite.close();
        });
    });

    // ----------------------------------------------------
    // 5. DELETE (ユーザー削除)
    // ----------------------------------------------------
    describe('DELETE /:id', () => {
        it('他のユーザーを正常に削除できること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
            const res = await app.request(`${BASE_PATH}/2`, {
                method: 'DELETE',
                headers: { 'Authorization': `Bearer ${adminToken}` },
            });

            expect(res.status).toBe(200);
            const body = await res.json();
            expect(body.message).toBe('ユーザーを削除しました');

            const currentUsers = await db.select().from(schema.users);
            expect(currentUsers).toHaveLength(1);

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('自分自身を削除しようとした場合、400 で却下されること', async () => {

            // 1. クリーンなアプリとDBを取得 (すでに PGlite はまっさら)
            const { app, db, pglite } = await createTestEnv();

            // 2. serial型の自動採番に任せ、Drizzle標準のプロパティ名（passwordHash）のみで初期データをインサート
            await setTestData(db);

            // 💡 3. 検証実行
            const res = await app.request(`${BASE_PATH}/1`, {
                method: 'DELETE',
                headers: { 'Authorization': `Bearer ${adminToken}` },
            });

            expect(res.status).toBe(400);

            // 必ず、PGliteをクローズする
            await pglite.close();
        });
    });
});
