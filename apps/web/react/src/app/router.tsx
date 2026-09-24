import { createBrowserRouter } from 'react-router-dom';
import { routes as authenticationRoutes } from '../features/authentication/routes';

export const router = createBrowserRouter([...authenticationRoutes]);
