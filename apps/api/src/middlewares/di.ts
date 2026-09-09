// src/middlewares/di.ts
import { Context, Next } from 'hono';
import type { AppServices } from '../types';

export function diMiddleware(
    services: AppServices
) {
    return async (c: Context, next: Next) => {

        c.set('pluginRegistry', services.pluginRegistry);
        c.set('authRegistry', services.authRegistry);
        c.set('dbInstance', services.dbInstance);

        await next();
    };
};
