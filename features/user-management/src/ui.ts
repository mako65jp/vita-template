import { PluginRegistry } from '@shared/client';
import { UserManagementTable } from './components/UserManagementTable';

export { UserManagementTable };

export function registerUserManagementPlugin() {
    PluginRegistry.register({
        id: 'user-management',
        name: 'ユーザー管理機能',
        description: 'ユーザー一覧の表示、ロール変更およびアカウント有効/無効の管理を行います',
        navItems: [
            {
                id: 'users',
                label: 'ユーザー管理',
                path: '/admin/users',
                icon: 'users',
                roles: ['admin'],
            },
        ],
    });
}
