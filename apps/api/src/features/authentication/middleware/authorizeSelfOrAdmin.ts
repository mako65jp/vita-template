import { Context, Next } from 'hono';

export function authorizeSelfOrAdmin() {
    return async (c: Context, next: Next) => {
        const principal = c.get('principal');

        if (!principal) {
            return c.json({ message: 'Unauthorized' }, 401);
        }

        if (principal.role === 'admin') {
            await next();
            return;
        }

        const id = c.req.param('id');
        if (principal.userId !== id) {
            return c.json({ message: 'Forbidden' }, 403);
        }

        await next();
    };
}
