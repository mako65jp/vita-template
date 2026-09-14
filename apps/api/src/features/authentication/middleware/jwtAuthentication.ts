import { Context, Next } from 'hono';
import jwt from 'jsonwebtoken';

export function jwtAuthentication(secret: string) {
    return async (c: Context, next: Next) => {
        const authorization = c.req.header('Authorization');

        if (!authorization || !authorization.startsWith('Bearer ')) {
            return c.json(
                {
                    message: 'Unauthorized',
                },
                401,
            );
        }

        const token = authorization.substring(7);

        try {
            const payload = jwt.verify(token, secret);

            c.set('jwt', payload);

            await next();
        } catch {
            return c.json(
                {
                    message: 'Unauthorized',
                },
                401,
            );
        }
    };
}
