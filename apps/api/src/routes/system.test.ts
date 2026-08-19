import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import { PluginRegistry } from '@app/core';
import { systemRouter } from './system';

describe('GET /api/system/plugins', () => {
    beforeEach(() => {
        PluginRegistry.register({
            id: 'sample-plugin',
            name: 'サンプル',
            routes: new Hono(),
            navItems: [{ id: 'sample-plugin', label: 'サンプル画面', path: '/sample' }],
        });
    });

    it('有効なプラグイン一覧と navItems を返却すること', async () => {
        const app = new Hono();
        app.route('/api/system', systemRouter);

        const res = await app.request('/api/system/plugins');
        expect(res.status).toBe(200);
        const body = (await res.json()) as any;
        expect(body.plugins).toBeDefined();

        const target = body.plugins.find((p: any) => p.id === 'sample-plugin');
        expect(target).toBeDefined();
        expect(target.navItems).toHaveLength(1);

    });
});
