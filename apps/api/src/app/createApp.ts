import { Hono } from 'hono';

import { DependencyContainer } from './DependencyContainer';

import { createUserController } from '../features/user/controllers/UserController';

import { createAuthenticationController } from '../features/authentication/controllers/AuthenticationController';

import { jwtAuthentication } from '../features/authentication/middleware/jwtAuthentication';

export function createApp(container: DependencyContainer) {
    const app = new Hono();

    app.get('/', (c) => c.text('Hello World'));

    app.route('/auth', createAuthenticationController(container.authenticationService));

    app.use('/users/*', jwtAuthentication('change-this-secret'));

    app.route('/users', createUserController(container.userService));

    return app;
}
