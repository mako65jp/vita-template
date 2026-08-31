import { describe, it, expect, beforeEach, vi } from 'vitest';

// 💡 前提条件として定義された setupFiles からのファクトリ関数をインポート
import { createTestEnv } from '../../../../vitest-clear'; // パスは環境に合わせて調整してください
import { hashPassword } from '@plugins/auth-local';
import * as schema from '@shared/db/schema';

describe('Auth Routes (Step 4.3) - インメモリ完全隔離テスト', () => {
    let app: any;
    let db: any;

    beforeEach(async () => {
        // vi.clearAllMocks();

        // 💡 100% 確実なアプローチ：前提のファクトリ関数を使い、DBごと毎回環境を完全新造する
        const testEnv = await createTestEnv();
        app = testEnv.app;
        db = testEnv.db;

    });

    // ----------------------------------------------------
    // 1. POST /api/auth/login のテスト
    // ----------------------------------------------------
    describe('POST /api/auth/login', () => {
        it('正しい資格情報でログインし、JWT トークンとユーザー情報が返ること', async () => {
            // // 認証成功時に返却される想定のモックデータを設定
            // // 💡 修正: 実際にインサートした「test@example.com」のデータが返るようにモックを設定
            // // 💡 修正: serial型(自動連番)に合わせて id は数値の 1 にします
            // mockAuthPlugin.authenticate.mockResolvedValue({
            //     id: 1,
            //     email: 'test@example.com',
            //     role: 'user',
            //     name: 'Test User',
            // });

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

            const body = await res.json();
            expect(body).toHaveProperty('token');
            expect(body.user).toEqual({
                id: 1,
                email: 'test@example.com',
                role: 'user',
            });
            expect(typeof body.token).toBe('string');
        });

        it('フォーマット違反（email も username も欠落）の場合、401 UnauthorizedError 形式が返ること', async () => {
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
        });

        it('パスワード不一致など認証プラグイン側で拒絶された場合、401エラーが返ること', async () => {
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
        });
    });

    // ----------------------------------------------------
    // 2. GET /api/auth/me のテスト
    // ----------------------------------------------------
    describe('GET /api/auth/me', () => {
        it('有効な JWT トークンを Bearer ヘッダーに付与した場合、200 OK でプロファイルが引けること', async () => {
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
            const { token } = await loginRes.json();

            // 2. 取得したトークンを Authorization ヘッダーに付与して /me へアクセス
            const res = await app.request('/api/auth/me', {
                method: 'GET',
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            });

            // 401で弾かれず、正しく認証されて 200 が返ります
            expect(res.status).toBe(200);

            const body = await res.json();
            expect(body.user).toEqual({
                id: 1,
                email: 'test@example.com',
                role: 'user',
            });
        });

        it('トークンを付与せずにアクセスした場合、401 Unauthorized で弾かれること', async () => {
            const res = await app.request('/api/auth/me', {
                method: 'GET',
            });

            expect(res.status).toBe(401);
        });
    });

    // ----------------------------------------------------
    // 3. データクリーン（隔離）の検証
    // ----------------------------------------------------
    it('前のテストケースでデータ操作があっても、このケースでは完全に空のままであること', async () => {
        // 前提の createTestEnv() のハックが有効なため、この直接の select もエラーにならず 0 件を返します
        const result = await db.select().from(schema.users);
        expect(result).toHaveLength(0);
    });
});
