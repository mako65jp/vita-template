import { Hono } from 'hono';

import { createAuthenticationController } from '../features/authentication/controllers/AuthenticationController';
import { createUserController } from '../features/user/controllers/UserController';
import { DependencyContainer } from './DependencyContainer';

import cors from "../common/cors.js";
// import csrf from "./handlers/csrf.js";
import error from "../common/error.js";
import logger from "../common/logger.js";
// import notFound from "./handlers/not-found.js";
// import authApp from "./routes/auth/app.js";
// import notesApp from "./routes/notes/app.js";

export function createApp(container: DependencyContainer) {
    const app = new Hono()
        .onError(error)
        // .notFound(notFound)
        .use(logger)
        .use('*', cors(container.config))
        // .use(csrf)
        // .route("/auth", authApp)
        // .route("/notes", notesApp);
        .get('/', (c) => c.text('Hello World'))
        .route('/api', createAuthenticationController(container.authenticationService))
        // .use('/users/*', jwtAuthentication('change-this-secret', container.userRepository))
        .route('/api/users', createUserController(container.userService));

    // app.get('/', (c) => c.text('Hello World'));

    // app.route('/auth', createAuthenticationController(container.authenticationService));

    // app.use('/users/*', jwtAuthentication('change-this-secret', container.userRepository));

    // app.route('/users', createUserController(container.userService));

    return app;
}
