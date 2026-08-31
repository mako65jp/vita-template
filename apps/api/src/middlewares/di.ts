// src/middlewares/di.ts
import { MiddlewareHandler } from 'hono';
import { AppEnv } from '@shared/functions';
import { Database } from '@shared/db';

export const diMiddleware = (db: Database): MiddlewareHandler<AppEnv> => {
    return async (c, next) => {
        // コンテキストに db インスタンスをセット
        c.set('dbInstance', db)
        await next();
    };
};
