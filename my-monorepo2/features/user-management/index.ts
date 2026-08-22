import { PluginRegistry } from '@shared/functions';
import { userRoutes } from './src/routes';

export { UserManagementTable, registerUserManagementPlugin } from './src/ui';

PluginRegistry.register({
    id: 'user-management',
    name: 'ユーザー管理機能',
    description: 'ユーザー一覧の表示、ロール変更およびアカウント有効/無効の管理を行います',
    routes: userRoutes,
    requiredRole: 'admin', // 💡 プラグイン自体の認可仕様として admin 権限を宣言
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
