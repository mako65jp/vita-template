import { SettingsPage } from './pages/SettingsPage';

export default {
    id: 'settings',

    menu: {
        title: '設定',
        path: '/settings',
        order: 100,
    },

    routes: [
        {
            path: '/settings',
            element: <SettingsPage />,
        },
    ],
};
