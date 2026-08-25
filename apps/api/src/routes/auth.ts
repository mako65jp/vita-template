import { Hono } from 'hono';
import { z } from 'zod';
import { UnauthorizedError } from '@shared/errors';
import { signJwt } from '@plugins/auth-local';
import { authMiddleware } from '../middlewares/auth-middleware';
import { getActiveAuthPlugin } from '../services/auth-service';

const loginSchema = z.object({
    email: z.string().optional(),
    username: z.string().optional(),
    password: z.string().min(1),
}).refine((data) => data.email || data.username, {
    message: 'メールアドレスまたはユーザー名が必要です。',
});

/**
 * 認証関連の API ルーター
 */
export function authRouter(jwtSecret: string) {
    const app = new Hono();

    // ----------------------------------------------------
    // 1. POST /login (ログイン & トークン発行)
    // ----------------------------------------------------
    app.post('/login', async (c) => {
        const body = await c.req.json();
        const result = loginSchema.safeParse(body);

        if (!result.success) {
            throw new UnauthorizedError('Invalid credentials format.');
        }

        const authPlugin = getActiveAuthPlugin();

        try {
            const authUser = await authPlugin.authenticate({
                email: result.data.email || result.data.username,
                username: result.data.username || result.data.email,
                password: result.data.password,
            });

            const token = await signJwt(
                {
                    userId: authUser.id,
                    email: authUser.email || '',
                    role: authUser.role || 'user',
                },
                jwtSecret
            );

            return c.json({
                token,
                user: {
                    id: authUser.id,
                    email: authUser.email || authUser.name,
                    role: authUser.role || 'user',
                },
            });
        } catch {
            throw new UnauthorizedError('Invalid credentials.');
        }
    });

    // ----------------------------------------------------
    // 2. GET /me (ログインユーザー情報取得)
    // ----------------------------------------------------
    app.get('/me', authMiddleware(jwtSecret), async (c) => {
        const currentUser = c.get('user');

        return c.json({
            user: {
                id: currentUser.userId,
                email: currentUser.email,
                role: currentUser.role,
            },
        });
    });

    return app;
}


// import { Hono } from 'hono';
// import { z } from 'zod';
// import { eq } from 'drizzle-orm';
// import { db, users } from '@shared/server';
// import { UnauthorizedError } from '@shared/errors';
// import { verifyPassword, signJwt } from '@plugins/auth-local';
// import { authMiddleware } from '../middlewares/auth-middleware';

// // ログインリクエストのバリデーションスキーマ
// const loginSchema = z.object({
//     email: z.string().email(),
//     password: z.string().min(1),
// });

// /**
//  * 認証関連の API ルーター
//  */
// export function authRouter(jwtSecret: string) {
//     const app = new Hono();

//     // ----------------------------------------------------
//     // 1. POST /login (ログイン & トークン発行)
//     // ----------------------------------------------------
//     app.post('/login', async (c) => {
//         const body = await c.req.json();
//         const result = loginSchema.safeParse(body);

//         if (!result.success) {
//             throw new UnauthorizedError('Invalid email or password format.');
//         }

//         const { email, password } = result.data;

//         // DB からユーザーを検索
//         const user = await db.query.users.findFirst({
//             where: eq(users.email, email),
//         });

//         if (!user) {
//             // セキュリティ上「ユーザーが存在しない」メッセージは出さず 401 を返す
//             throw new UnauthorizedError('Invalid credentials.');
//         }

//         // パスワードの照合
//         const isPasswordValid = await verifyPassword(password, user.passwordHash);
//         if (!isPasswordValid) {
//             throw new UnauthorizedError('Invalid credentials.');
//         }

//         // JWT アクセストークンの発行
//         const token = await signJwt(
//             {
//                 userId: user.id,
//                 email: user.email,
//                 role: user.role,
//             },
//             jwtSecret
//         );

//         return c.json({
//             token,
//             user: {
//                 id: user.id,
//                 email: user.email,
//                 role: user.role,
//             },
//         });
//     });

//     // ----------------------------------------------------
//     // 2. GET /me (ログインユーザー情報取得)
//     // ----------------------------------------------------
//     app.get('/me', authMiddleware(jwtSecret), async (c) => {
//         const currentUser = c.get('user');

//         return c.json({
//             user: {
//                 id: currentUser.userId,
//                 email: currentUser.email,
//                 role: currentUser.role,
//             },
//         });
//     });

//     return app;
// }
