// features/user-management/manifest.test.ts

import { describe, expect, it, beforeEach } from 'vitest';

import '@features/user-management';

import type { Database } from '@shared/db';
import { AuthPluginRegistry } from '@shared/functions';
import { PluginRegistry } from '@shared/plugin';

import type { AppServices } from '@apps/api/types';
import { createApp } from '@apps/api/create-app';

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

        const response = await app.request(
            '/api/user-management'
        );

        expect(response.status).not.toBe(404);
    });
});

describe('User Management Feature Contract', () => {

    it('exposes navigation metadata', () => {
        expect(
            userManagementManifest.navItems
        ).toBeDefined();

        expect(
            userManagementManifest.navItems?.length
        ).toBeGreaterThan(0);

        const navItem =
            userManagementManifest.navItems?.[0];

        expect(navItem).toBeDefined();

        expect(navItem?.id)
            .toBe('users');

        expect(navItem?.label)
            .toBe('ユーザー管理');

        expect(navItem?.path)
            .toBe('/admin/users');

        expect(navItem?.roles)
            .toContain('admin');
    });

    it('has a valid plugin identifier', () => {
        expect(
            userManagementManifest.id
        ).toBe('user-management');
    });

});


// // features/user-management/manifest.test.ts

// import { beforeEach, describe, expect, it, vi } from 'vitest';
// import '@features/user-management';

// import type { Database } from '@shared/db';
// import { AuthPluginRegistry } from '@shared/functions';
// import { PluginRegistry } from '@shared/plugin';

// import type { AppServices } from '@apps/api/types';
// import { createApp } from '@apps/api/create-app';
// import { userManagementManifest } from './manifest';


// describe('Feature Availability', () => {
//     let db: Database;
//     let services: AppServices;

//     beforeEach(() => {
//         db = {} as Database;
//         services = {
//             pluginRegistry: new PluginRegistry(),
//             authRegistry: new AuthPluginRegistry(),
//             dbInstance: db,
//         };
//     });

//     it('user-management feature is exposed', async () => {

//         const app = await createApp(services);

//         const response =
//             await app.request(
//                 '/api/user-management'
//             );

//         expect(response.status)
//             .not.toBe(404);
//     });

// });

// describe('User Management Feature Contract', () => {

//     it('exposes navigation metadata', () => {
//         const navItem =
//             userManagementManifest.navItems?.[0];

//         expect(navItem).toBeDefined();

//         expect(navItem?.id)
//             .toBe('users');

//         expect(navItem?.path)
//             .toBe('/admin/users');
//     });

// });


// // describe('User Management Feature Contract', () => {

// //     it(
// //         'client entry registers navigation metadata',
// //         async () => {

// //             pluginRegistry.clear();

// //             await import('./client');

// //             const plugin =
// //                 pluginRegistry.get('user-management');

// //             expect(plugin).toBeDefined();

// //             expect(plugin?.navItems)
// //                 .toHaveLength(1);
// //         }
// //     );

// //     it(
// //         'server entry registers route metadata',
// //         async () => {

// //             pluginRegistry.clear();

// //             await import('./server');

// //             const plugin =
// //                 pluginRegistry.get('user-management');

// //             expect(plugin).toBeDefined();

// //             expect(
// //                 (plugin as any).routes
// //             ).toBeDefined();
// //         }
// //     );
// // });
