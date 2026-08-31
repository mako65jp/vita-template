import { Hono } from 'hono';
import { AppEnv, AuthPluginRegistry } from '@shared/functions';
import { z } from 'zod';
import { UnauthorizedError } from '@shared/errors';
import { signJwt } from '@plugins/auth-local';
import { authMiddleware } from '../middlewares/auth-middleware';

const loginSchema = z.object({
    email: z.string().optional(),
    username: z.string().optional(),
    password: z.string().min(1),
}).refine((data) => data.email || data.username, {
    message: 'メールアドレスまたはユーザー名が必要です。',
});

/**
 * 認証関連の API ルーター
 * 💡 【解決策B】引数として、このアプリケーションインスタンス専用の authRegistry を受け取ります
 */
export function authRouter(jwtSecret: string, authRegistry: AuthPluginRegistry) {
    const app = new Hono<AppEnv>();

    // ----------------------------------------------------
    // 1. POST /login (ログイン & トークン発行)
    // ----------------------------------------------------
    app.post('/login', async (c) => {
        const db = c.get('dbInstance');
        const body = await c.req.json();
        const result = loginSchema.safeParse(body);

        if (!result.success) {
            throw new UnauthorizedError('Invalid credentials format.');
        }

        // 💡 【DI化】グローバルなシングルトンからではなく、注入されたインスタンスからプラグインを取得します。
        // これにより、テスト実行ごとに新造されたインメモリDB（LocalAuthPlugin）への参照が100%保証されます。
        const authPlugin = authRegistry.get('local');

        try {
            const authUser = await authPlugin.authenticate({
                db: db,
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
