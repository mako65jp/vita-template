import { Context, Next } from 'hono';

export function authorize(...roles: string[]) {
    return async (c: Context, next: Next) => {

        const principal = c.get('principal');

        if (!principal) {
            return c.json(
                { message: 'Unauthorized' },
                401,
            );
        }

        if (!roles.includes(principal.role)) {
            return c.json(
                { message: 'Forbidden' },
                403,
            );
        }

        await next();
    };
}
