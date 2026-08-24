import { describe, it, expect } from 'vitest';
import { db } from '@shared/server';
import { plugins } from './plugins';
import { eq } from 'drizzle-orm';

describe('Plugins DB Integration Tests', () => {

    it('プラグイン情報を正常に挿入および取得できること', async () => {
        const newPlugin = {
            id: 'test-feature',
            name: 'テスト機能',
            description: 'テスト用の説明文です',
            enabled: true,
        };

        const [inserted] = await db.insert(plugins).values(newPlugin).returning();

        expect(inserted.id).toBe(newPlugin.id);
        expect(inserted.name).toBe(newPlugin.name);
        expect(inserted.description).toBe(newPlugin.description);
        expect(inserted.enabled).toBe(true); // デフォルト値の検証
        expect(inserted.updatedAt).toBeInstanceOf(Date);

        // IDで検索して同一データが取得できるか検証
        const [found] = await db.select().from(plugins).where(eq(plugins.id, inserted.id));
        expect(found).toBeDefined();
        expect(found.name).toBe(newPlugin.name);
    });

    it('プラグインの有効/無効 (enabled) ステータスを更新できること', async () => {
        const targetPlugin = {
            id: 'user-management',
            name: 'ユーザー管理機能',
            enabled: true,
        };

        await db.insert(plugins).values(targetPlugin);

        // 有効状態を false (無効) に更新
        const [updated] = await db
            .update(plugins)
            .set({ enabled: false })
            .where(eq(plugins.id, targetPlugin.id))
            .returning();

        expect(updated.enabled).toBe(false);

        // DB上でも変更が反映されているか確認
        const [found] = await db.select().from(plugins).where(eq(plugins.id, targetPlugin.id));
        expect(found.enabled).toBe(false);
    });

    it('主キー (id) の重複時にエラーが発生すること', async () => {
        const pluginPayload = {
            id: 'duplicate-plugin',
            name: '重複テスト',
        };

        await db.insert(plugins).values(pluginPayload);

        // 同じ ID で再挿入を試みると例外が発生すること
        await expect(
            db.insert(plugins).values({
                ...pluginPayload,
                name: '重複テスト2',
            })
        ).rejects.toThrow();
    });
});
