import { Hono } from 'hono';

import { createAuthenticationController } from '../features/authentication/routes';
import { createUserController } from '../features/user/controller';
import { DependencyContainer } from './DependencyContainer';

import cors from '../common/cors';
import csrf from '../common/csrf';
import error from '../common/error';
import logger from '../common/logger';
import notFound from '../common/notFound';
import { jwtAuthentication } from '../features/authentication/middleware/jwtAuthentication';

export function createApp(container: DependencyContainer) {
    const apiRoot = container.systemConfig.backend.applicationRoot;

    const app = new Hono()
        //
        // Route registration policy
        //
        // Hono は Middleware を登録順に適用する。
        //
        // このセクションはアプリケーション全体の
        // 認証境界および Route 構成を定義する。

        //
        // Global middleware
        //
        // 必ず実行する Middleware（システム共通処理）
        //
        .onError(error)
        .notFound(notFound)
        .use(logger)
        .use('*', cors(container.systemConfig))
        .use('*', csrf(container.systemConfig))

        //
        // Health check
        //
        .get('/', (c) => c.text('Backend running.'))

        //
        // Routes Not Requiring Authentication
        //
        // 認証不要な Route を登録する
        //

        .route(
            `${apiRoot}`,
            createAuthenticationController(container.services.authenticationService),
        )

        //
        // Authentication boundary
        //
        // この Middleware が
        // 認証不要な Route
        // と
        // 認証が必要な Route
        // の境界となる。
        //
        .use(`${apiRoot}/*`, jwtAuthentication(container.services.jwtService))

        //
        // Routes Requiring Authentication
        //
        // 認証が必要な Route を登録する
        //
        .route(`${apiRoot}/users/*`, createUserController(container.services.userService));
    return app;
}
