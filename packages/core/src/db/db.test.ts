import { describe, it, expect } from 'vitest';
import { db } from './index';
import { users } from './schema';
import { eq } from 'drizzle-orm';

describe('DB Integration Test (Step 3)', () => {
    it('ユーザーテーブルにデータを挿入し、取得できること', async () => {
        const testEmail = `test-${Date.now()}@example.com`;

        // 1. レコード挿入 (Create)
        const [insertedUser] = await db
            .insert(users)
            .values({
                name: 'Test User',
                email: testEmail,
            })
            .returning();

        expect(insertedUser).toBeDefined();
        expect(insertedUser.name).toBe('Test User');
        expect(insertedUser.email).toBe(testEmail);

        // 2. レコード取得 (Read)
        const [fetchedUser] = await db
            .select()
            .from(users)
            .where(eq(users.id, insertedUser.id));

        expect(fetchedUser).toBeDefined();
        expect(fetchedUser.email).toBe(testEmail);
    });
});
