import { Hono } from 'hono';
import { db, plugins as pluginsTable } from '@app/core/server';
import { PluginRegistry } from '@app/core';

export const systemRouter = new Hono();

/**
 * GET /api/system/plugins
 * 有効化（enabled: true）されているプラグインの一覧および
 * フロントエンド表示に必要なナビゲーション（navItems）を返却するAPI
 */
systemRouter.get('/plugins', async (c) => {
    // 1. DBからプラグインの有効/無効ステータスを取得
    let dbPluginsMap = new Map<string, boolean>();
    try {
        const dbPlugins = await db.select().from(pluginsTable);
        dbPlugins.forEach((p) => dbPluginsMap.set(p.id, p.enabled));
    } catch (error) {
        console.warn('[System API] Failed to fetch plugins table status.');
    }

    // 2. レジストリから全プラグイン情報を取得し、有効なもののみフィルタリング
    const activePlugins = PluginRegistry.getAll()
        .filter((plugin) => {
            // DBに存在する場合はその値、存在しない場合はデフォルトで有効(true)とする
            return dbPluginsMap.has(plugin.id) ? dbPluginsMap.get(plugin.id) : true;
        })
        .map((plugin) => ({
            id: plugin.id,
            name: plugin.name,
            description: plugin.description,
            navItems: plugin.navItems ?? [],
        }));

    return c.json({
        plugins: activePlugins,
    });
});
