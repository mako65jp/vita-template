import { Hono } from 'hono';
import { AppEnv } from '@shared/functions';
import { getActivePlugins } from '../utils/auto-loader-helper';

export const systemRouter = new Hono<AppEnv>();

/**
 * GET /api/system/plugins
 * 有効化（enabled: true）されているプラグインの一覧および
 * フロントエンド表示に必要なナビゲーション（navItems）を返却するAPI
 */
systemRouter.get('/plugins', async (c) => {
    const db = c.get('dbInstance');
    const pluginStatuses = await getActivePlugins(db);

    const activePlugins = pluginStatuses
        .filter(({ isEnabled }) => isEnabled)
        .map(({ plugin }) => ({
            id: plugin.id,
            name: plugin.name,
            description: plugin.description,
            navItems: plugin.navItems ?? [],
        }));

    return c.json({
        plugins: activePlugins,
    });
});
