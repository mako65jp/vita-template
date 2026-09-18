import { RouterProvider } from 'react-router-dom';

import { router } from './router';

import { AuthProvider } from './providers/AuthProvider';

export function App() {
    return (
        <AuthProvider>
            <RouterProvider router={router} />
        </AuthProvider>
    );
}
