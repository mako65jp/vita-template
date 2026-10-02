import { Hono } from 'hono';

import { createAuthenticationController } from '../features/authentication/routes';
import { createUserController } from '../features/user/controller';
import { DependencyContainer } from './DependencyContainer';

import cors from '../common/cors.js';
import csrf from '../common/csrf.js';
import error from '../common/error.js';
import logger from '../common/logger.js';
import { jwtAuthentication } from '../features/authentication/middleware/jwtAuthentication';
// import notFound from "./handlers/not-found.js";

export function createApp(container: DependencyContainer) {
    const apiRoot = container.systemConfig.backend.applicationRoot;

    const app = new Hono()
        .onError(error)
        // .notFound(notFound)
        .use(logger)
        .use('*', cors(container.systemConfig))
        .use('*', csrf(container.systemConfig))
        .get('/', (c) => c.text('Backend running.'))

        .route(`${apiRoot}`, createAuthenticationController(container.authenticationService))

        .use(`${apiRoot}/users/*`, jwtAuthentication(container.jwtService))
        .route(`${apiRoot}/users/*`, createUserController(container.userService));

    return app;
}
