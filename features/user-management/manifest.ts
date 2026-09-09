// features/user-management/shared/manifest.ts

import type { PluginManifest } from '@shared/plugin';

export const userManagementManifest: PluginManifest = {
    id: 'user-management',
    name: 'ユーザー管理機能',
    description: 'ユーザー管理',

    navItems: [
        {
            id: 'users',
            label: 'ユーザー管理',
            path: '/admin/users',
            icon: 'users',
            roles: ['admin'],
        },
    ],
};
