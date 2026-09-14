// features/user-management/index.ts

import { pluginRegistry } from '@shared/plugin';
import { userManagementServerPlugin } from './plugin';

console.log('[user-management] registered');

pluginRegistry.register(userManagementServerPlugin);
