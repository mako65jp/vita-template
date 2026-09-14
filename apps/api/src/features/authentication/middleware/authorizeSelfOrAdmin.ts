import { Context, Next } from 'hono';

export function authorizeSelfOrAdmin() {
    return async (c: Context, next: Next) => {
        const jwt = c.get('jwt');

        if (!jwt) {
            return c.json(
                {
                    message: 'Unauthorized',
                },
                401,
            );
        }

        if (jwt.role === 'admin') {
            await next();
            return;
        }

        const id = c.req.param('id');

        if (String(jwt.sub) !== id) {
            return c.json(
                {
                    message: 'Forbidden',
                },
                403,
            );
        }

        await next();
    };
}
