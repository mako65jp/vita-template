import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { db, plugins as pluginsTable, loadFeatureModules } from '../server';
import { PluginRegistry } from '../index';

describe('hono-auto-loader', () => {
    const dummyPluginId = 'test-dummy-plugin';

    beforeEach(() => {
        const dummyApp = new Hono();
        dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));

        PluginRegistry.register({
            id: dummyPluginId,
            name: 'テスト用プラグイン',
            routes: dummyApp,
            navItems: [{ label: 'テスト', path: '/test' }],
        });
    });

    it('DBで有効(enabled: true)のプラグインのみ API ルートがマウントされること', async () => {
        await db.insert(pluginsTable).values({
            id: dummyPluginId,
            name: 'テスト用プラグイン',
            enabled: true,
        }).onConflictDoUpdate({
            target: pluginsTable.id,
            set: { enabled: true },
        });

        const app = new Hono();
        await loadFeatureModules(app, 'packages/features/*/src/server.ts');

        const res = await app.request(`/api/${dummyPluginId}/hello`);
        expect(res.status).toBe(200);
    });

    it('DBで無効(enabled: false)のプラグインはマウントされず 404 になること', async () => {
        await db.insert(pluginsTable).values({
            id: dummyPluginId,
            name: 'テスト用プラグイン',
            enabled: false,
        }).onConflictDoUpdate({
            target: pluginsTable.id,
            set: { enabled: false },
        });

        const app = new Hono();
        await loadFeatureModules(app, 'packages/features/*/src/index.ts');

        const res = await app.request(`/api/${dummyPluginId}/hello`);
        expect(res.status).toBe(404);
    });
});
