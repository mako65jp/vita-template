import { Hono } from 'hono';
import { db, AppError } from '@app/core';
import { sql } from 'drizzle-orm';

export const healthRouter = new Hono();

healthRouter.get('/healthz', async (c) => {
    try {
        // DB導通テスト (SELECT 1)
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

// import { Hono } from 'hono';
// import { db } from '@app/core/db';
// import { sql } from 'drizzle-orm';
// import { AppError } from '@app/core/errors';

// export const healthRouter = new Hono();

// healthRouter.get('/healthz', async (c) => {
//     try {
//         // DB導通テスト (SELECT 1)
//         await db.execute(sql`SELECT 1`);

//         return c.json({
//             status: 'ok',
//             db: 'connected',
//         });
//     } catch (error) {
//         // DB不通時は 503 エラーをスロー (共通エラーハンドラーで RFC 7807 化)
//         throw new AppError('Service Unavailable', 503, 'Database connection failed');
//     }
// });
