// features/user-management/manifest.test.ts

import { beforeEach, describe, expect, it } from 'vitest';

import '@features/user-management';

import type { Database } from '@shared/db';
import { AuthPluginRegistry } from '@shared/functions';
import { PluginRegistry } from '@shared/plugin';

import { createApp } from '@apps/api/create-app';
import type { AppServices } from '@apps/api/types';

import { userManagementManifest } from './manifest';

describe('Feature Availability', () => {
    let services: AppServices;

    beforeEach(() => {
        const db = {} as Database;

        services = {
            pluginRegistry: new PluginRegistry(),
            authRegistry: new AuthPluginRegistry(),
            dbInstance: db,
        };
    });

    it('user-management API route is available', async () => {
        const app = await createApp(services);

        const response = await app.request('/api/user-management');

        expect(response.status).not.toBe(404);
    });
});

describe('User Management Feature Contract', () => {
    it('exposes navigation metadata', () => {
        expect(userManagementManifest.navItems).toBeDefined();

        expect(userManagementManifest.navItems?.length).toBeGreaterThan(0);

        const navItem = userManagementManifest.navItems?.[0];

        expect(navItem).toBeDefined();

        expect(navItem?.id).toBe('users');

        expect(navItem?.label).toBe('ユーザー管理');

        expect(navItem?.path).toBe('/admin/users');

        expect(navItem?.roles).toContain('admin');
    });

    it('has a valid plugin identifier', () => {
        expect(userManagementManifest.id).toBe('user-management');
    });
});
