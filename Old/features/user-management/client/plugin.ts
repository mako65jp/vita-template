// features/user-management/client/plugin.ts

import { userManagementManifest } from '../manifest';

import { UserManagementTable } from './UserManagementTable';

export const userManagementClientPlugin = {
    manifest: userManagementManifest,

    screens: {
        users: UserManagementTable,
    },
};
