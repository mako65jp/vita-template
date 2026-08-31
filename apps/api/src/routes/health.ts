import { Hono } from 'hono';
import { AppError } from '@shared/errors';
import { sql } from 'drizzle-orm';
import { AppEnv } from '@shared/functions';

export const healthRouter = new Hono<AppEnv>();

healthRouter.get('/healthz', async (c) => {
    try {
        // DB導通テスト (SELECT 1)
        const db = c.get('dbInstance')
        await db.execute(sql`SELECT 1`);

        return c.json({
            status: 'ok',
            db: 'connected',
        });
    } catch (error) {
        // DB不通時は 503 エラーをスロー (status, code, title, message)
        throw new AppError(
            503,
            'SERVICE_UNAVAILABLE',
            'Service Unavailable',
            'Database connection failed'
        );
    }
});
