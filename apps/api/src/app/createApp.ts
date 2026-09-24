import { Hono } from 'hono';

import { createAuthenticationController } from '../features/authentication/controllers/AuthenticationController';
import { createUserController } from '../features/user/controllers/UserController';
import { DependencyContainer } from './DependencyContainer';

import cors from "../common/cors.js";
import csrf from "../common/csrf.js";
import error from "../common/error.js";
import logger from "../common/logger.js";
// import notFound from "./handlers/not-found.js";
// import authApp from "./routes/auth/app.js";
// import notesApp from "./routes/notes/app.js";

export function createApp(container: DependencyContainer) {
    const apiRoot = container.config.backend.applicationRoot;

    const app = new Hono()
        .onError(error)
        // .notFound(notFound)
        .use(logger)
        .use('*', cors(container.config))
        .use('*', csrf(container.config))
        .get('/', (c) => c.text('Backend running.'))

        .route(`${apiRoot}`, createAuthenticationController(container.authenticationService))
        .route(`${apiRoot}/users`, createUserController(container.userService));

    // app.get('/', (c) => c.text('Hello World'));
    // app.route('/auth', createAuthenticationController(container.authenticationService));
    // app.use('/users/*', jwtAuthentication('change-this-secret', container.userRepository));
    // app.route('/users', createUserController(container.userService));

    return app;
}
