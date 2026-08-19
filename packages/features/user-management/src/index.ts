import { PluginRegistry } from '@app/core';
import { userRoutes } from './routes';

export { UserManagementTable, registerUserManagementPlugin } from './ui';

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


// import { PluginRegistry } from '@app/core';
// import { userRoutes } from './routes';

// export { UserManagementTable, registerUserManagementPlugin } from './ui';

// PluginRegistry.register({
//     id: 'user-management',
//     name: 'ユーザー管理機能',
//     description: 'ユーザー一覧の表示、ロール変更およびアカウント有効/無効の管理を行います',
//     routes: userRoutes,
//     navItems: [
//         {
//             id: 'users',
//             label: 'ユーザー管理',
//             path: '/admin/users',
//             icon: 'users',
//             roles: ['admin'],
//         },
//     ],
// });



// // import { PluginRegistry } from '@app/core';
// // import { userRoutes } from './routes';

// // export { UserManagementTable } from './components/UserManagementTable';

// // PluginRegistry.register({
// //     id: 'user-management',
// //     name: 'ユーザー管理機能',
// //     description: 'ユーザー一覧の表示、ロール変更およびアカウント有効/無効の管理を行います',
// //     routes: userRoutes,
// //     navItems: [
// //         {
// //             label: 'ユーザー管理',
// //             path: '/admin/users',
// //             icon: 'users',
// //         },
// //     ],
// // });
