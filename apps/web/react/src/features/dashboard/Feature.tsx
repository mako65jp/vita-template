import { DashboardPage } from './pages/DashboardPage';

export default {
    id: 'dashboard',

    menu: {
        title: 'ダッシュボード',
        path: '/dashboard',
        order: 10,
    },

    routes: [
        {
            path: '/dashboard',
            element: <DashboardPage />,
        },
    ],
};
