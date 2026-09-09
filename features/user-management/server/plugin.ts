// features/user-management/server/plugin.ts

import { userManagementManifest } from '../manifest';
import { userRoutes } from './routes';

export const userManagementServerPlugin = {
    ...userManagementManifest,
    routes: userRoutes,
    requiredRole: 'admin',
};
