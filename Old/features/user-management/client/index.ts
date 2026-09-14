// features/user-management/client/index.ts

export * from './plugin';
export * from './UserManagementTable';
export * from './CreateUserModal';

import { pluginRegistry } from '@shared/plugin';
import { userManagementManifest } from '../manifest';
pluginRegistry.register(userManagementManifest);
