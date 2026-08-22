import { describe, it, expect, afterAll, beforeEach } from 'vitest';
import { db, activeQueryClient } from '../../server';
import { users } from './users';
import { eq } from 'drizzle-orm';

describe('Users DB Integration Tests', () => {
    afterAll(async () => {
        // テスト終了後に PostgreSQL 接続をシャットダウン
        await activeQueryClient.end();
    });

    beforeEach(async () => {
        // テストごとに users テーブルをクリーンアップ
        await db.delete(users);
    });

    it('ユーザーを正常に挿入および取得できること', async () => {
        const newUser = {
            name: 'テストユーザー',
            email: 'test@example.com',
            passwordHash: '$2a$10$hashedpasswordexample',
        };

        const [inserted] = await db.insert(users).values(newUser).returning();

        expect(inserted.id).toBeDefined();
        expect(inserted.name).toBe(newUser.name);
        expect(inserted.email).toBe(newUser.email);
        expect(inserted.role).toBe('user'); // デフォルト値の検証
        expect(inserted.isActive).toBe(true); // デフォルト値(isActive: true)の検証（追加）
        expect(inserted.createdAt).toBeInstanceOf(Date);

        // IDで検索して同一データが取得できるか
        const [found] = await db.select().from(users).where(eq(users.id, inserted.id));
        expect(found).toBeDefined();
        expect(found.email).toBe(newUser.email);
    });

    it('ユーザーの有効/無効 (isActive) ステータスを更新できること', async () => {
        const newUser = {
            name: 'ステータステストユーザー',
            email: 'status@example.com',
            passwordHash: 'hash',
        };

        const [inserted] = await db.insert(users).values(newUser).returning();
        expect(inserted.isActive).toBe(true);

        // アカウントを無効化 (false)
        const [disabled] = await db
            .update(users)
            .set({ isActive: false })
            .where(eq(users.id, inserted.id))
            .returning();

        expect(disabled.isActive).toBe(false);

        // DB上でも変更が反映されているか確認
        const [found] = await db.select().from(users).where(eq(users.id, inserted.id));
        expect(found.isActive).toBe(false);
    });

    it('同じ email のユーザーを挿入した場合、エラーが発生すること（Unique制約）', async () => {
        const userPayload = {
            name: 'ユーザー1',
            email: 'duplicate@example.com',
            passwordHash: 'hash123',
        };

        await db.insert(users).values(userPayload);

        // 同じ email で挿入を試みると例外が発生すること
        await expect(
            db.insert(users).values({
                ...userPayload,
                name: 'ユーザー2',
            })
        ).rejects.toThrow();
    });
});
