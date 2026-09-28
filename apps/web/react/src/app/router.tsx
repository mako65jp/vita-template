import { Navigate, createBrowserRouter } from 'react-router-dom';

import { Layout } from '../components/Layout';
import { defaultPath, features } from './features';
import { useAuth } from './providers/AuthProvider';

import { LoginPage } from '../features/authentication/pages/LoginPage';

function LoginRoute() {
    const auth = useAuth();

    if (auth.isAuthenticated) {
        return <Navigate to={defaultPath} replace />;
    }

    return <LoginPage />;
}

function ProtectedLayout() {
    const auth = useAuth();

    if (!auth.isAuthenticated) {
        return <Navigate to="/login" replace />;
    }

    return <Layout />;
}

function RootRoute() {
    const auth = useAuth();

    return <Navigate to={auth.isAuthenticated ? defaultPath : '/login'} replace />;
}

function NotFoundRoute() {
    const auth = useAuth();

    return <Navigate to={auth.isAuthenticated ? defaultPath : '/login'} replace />;
}

const featureRoutes = features
    .flatMap((feature) => feature.routes ?? [])
    .filter((route) => route.path !== '/login')
    .map((route) => ({
        ...route,
        path: route.path?.replace(/^\//, ''),
    }));

export const router = createBrowserRouter([
    {
        path: '/login',
        element: <LoginRoute />,
    },
    {
        path: '/',
        element: <ProtectedLayout />,
        children: [
            {
                index: true,
                element: <Navigate to={defaultPath} replace />,
            },
            ...featureRoutes,
        ],
    },
    {
        path: '*',
        element: <NotFoundRoute />,
    },
]);
