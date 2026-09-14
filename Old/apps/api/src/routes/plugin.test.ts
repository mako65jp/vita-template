import { describe, it, expect, beforeEach } from 'vitest';
import { Hono } from 'hono';
import type { ServerPluginManifest } from '@shared/plugin';
import type { AppEnv } from '../types';
import { systemRouter } from './plugin';
import { pluginRegistry } from '@shared/plugin';

describe('GET /api/system/plugins', () => {
    beforeEach(() => {
        pluginRegistry.register({
            id: 'sample-plugin',
            name: 'sample',
            navItems: [
                {
                    id: 'sample',
                    label: 'sample',
                    path: '/sample',
                },
            ],
        });
    });
    it('有効なプラグイン一覧と navItems を返却すること', async () => {
        const app = new Hono<AppEnv>();
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
