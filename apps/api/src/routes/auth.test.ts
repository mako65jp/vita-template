import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createTestEnv } from '../../../../vitest-helpers'; // プロジェクトの共通環境作成関数
import { hashPassword } from '@plugins/auth-local';
import * as schema from '@shared/db/schema';

describe('Auth Routes (Step 4.3) - インメモリ完全隔離テスト', () => {

    beforeEach(async () => {
    });

    // ----------------------------------------------------
    // 1. POST /api/auth/login のテスト
    // ----------------------------------------------------
    describe('POST /api/auth/login', () => {
        it('正しい資格情報でログインし、JWT トークンとユーザー情報が返ること', async () => {

            // 1. クリーンなテスト環境を取得
            const { app, db, pglite } = await createTestEnv();

            // テストユーザーを挿入
            const hashedPassword = await hashPassword('password123');
            await db.insert(schema.users).values({
                name: 'Test User',
                email: 'test@example.com',
                passwordHash: hashedPassword,
                role: 'user',
                isActive: true,
            });

            const res = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'test@example.com',
                    password: 'password123',
                }),
            });

            // rowMode ハックとプラグインモックの連動により、401にならず 200 OK となります
            expect(res.status).toBe(200);

            const body = await res.json() as { token: string; user: any };
            expect(body).toHaveProperty('token');
            expect(body.user).toEqual({
                id: 1,
                email: 'test@example.com',
                role: 'user',
            });
            expect(typeof body.token).toBe('string');

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('フォーマット違反（email も username も欠落）の場合、401 UnauthorizedError 形式が返ること', async () => {

            // 1. クリーンなテスト環境を取得
            const { app, db, pglite } = await createTestEnv();

            // テストユーザーを挿入
            const hashedPassword = await hashPassword('password123');
            await db.insert(schema.users).values({
                name: 'Test User',
                email: 'test@example.com',
                passwordHash: hashedPassword,
                role: 'user',
                isActive: true,
            });

            const res = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    password: 'password123',
                }),
            });

            expect(res.status).toBe(401);

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('パスワード不一致など認証プラグイン側で拒絶された場合、401エラーが返ること', async () => {

            // 1. クリーンなテスト環境を取得
            const { app, db, pglite } = await createTestEnv();

            // テストユーザーを挿入
            const hashedPassword = await hashPassword('password123');
            await db.insert(schema.users).values({
                name: 'Test User',
                email: 'test@example.com',
                passwordHash: hashedPassword,
                role: 'user',
                isActive: true,
            });

            const res = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'wrong@example.com',
                    password: 'wrongpassword',
                }),
            });

            expect(res.status).toBe(401);

            // 必ず、PGliteをクローズする
            await pglite.close();
        });
    });

    // ----------------------------------------------------
    // 2. GET /api/auth/me のテスト
    // ----------------------------------------------------
    describe('GET /api/auth/me', () => {
        it('有効な JWT トークンを Bearer ヘッダーに付与した場合、200 OK でプロファイルが引けること', async () => {

            // 1. クリーンなテスト環境を取得
            const { app, db, pglite } = await createTestEnv();

            // テストユーザーを挿入
            const hashedPassword = await hashPassword('password123');
            await db.insert(schema.users).values({
                name: 'Test User',
                email: 'test@example.com',
                passwordHash: hashedPassword,
                role: 'user',
                isActive: true,
            });

            // 1. 正規のルートでログインエンドポイントからフレッシュなJWTトークンを取得
            const loginRes = await app.request('/api/auth/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    email: 'test@example.com',
                    password: 'password123'
                }),
            });
            const { token } = await loginRes.json() as { token: string };

            // 2. 取得したトークンを Authorization ヘッダーに付与して /me へアクセス
            const res = await app.request('/api/auth/me', {
                method: 'GET',
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });

            // 401で弾かれず、正しく認証されて 200 が返ります
            expect(res.status).toBe(200);

            const body = await res.json() as { user: any };
            expect(body.user).toEqual({
                id: 1,
                email: 'test@example.com',
                role: 'user',
            });

            // 必ず、PGliteをクローズする
            await pglite.close();
        });

        it('トークンを付与せずにアクセスした場合、401 Unauthorized で弾かれること', async () => {

            // 1. クリーンなテスト環境を取得
            const { app, db, pglite } = await createTestEnv();

            const res = await app.request('/api/auth/me', {
                method: 'GET',
            });

            expect(res.status).toBe(401);

            // 必ず、PGliteをクローズする
            await pglite.close();
        });
    });

    // ----------------------------------------------------
    // 3. データクリーン（隔離）の検証
    // ----------------------------------------------------
    it('前のテストケースでデータ操作があっても、このケースでは完全に空のままであること', async () => {

        // 1. クリーンなテスト環境を取得
        const { app, db, pglite } = await createTestEnv();

        // 前提の createTestEnv() のハックが有効なため、この直接の select もエラーにならず 0 件を返します
        const result = await db.select().from(schema.users);
        expect(result).toHaveLength(0);

        // 必ず、PGliteをクローズする
        await pglite.close();
    });
});
