import { Navigate } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';

export const routes = [
    {
        path: '/',
        element: <Navigate to="/login" replace />,
    },
    {
        path: '/login',
        element: <LoginPage />,
    },
];

// import { LoginPage } from './LoginPage';

// export const routes = [
//     {
//         path: '/login',
//         element: <LoginPage />,
//     },
// ];
