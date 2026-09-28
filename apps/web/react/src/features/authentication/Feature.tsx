import { LoginPage } from './pages/LoginPage';

export default {
    id: 'auth',

    // menu: {
    //     title: 'ログイン',
    //     path: '/login',
    //     order: 10,
    // },

    routes: [
        {
            path: '/login',
            element: <LoginPage />,
        },
    ],
};
