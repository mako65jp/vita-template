import type { Context } from 'hono';

export default function notFound(c: Context) {
    return c.json(
        {
            success: false,
            error: {
                code: 'NOT_FOUND',
                message: 'The requested endpoint was not found.',
            },
        },
        404,
    );
}
