import { Hono } from 'hono';
import { AppEnv } from '@shared/functions';
import { cors } from 'hono/cors';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { AppError, ProblemDetails, ValidationError } from '@shared/errors';
import { env, isTest, formatEnvForLog } from '@shared/functions';
import { AuthPluginRegistry } from '@shared/functions';
import { loadFeatureModules } from './auto-loader/hono-auto-loader';
import { LocalAuthPlugin } from '@plugins/auth-local';
import { ActiveDirectoryAuthPlugin } from '@plugins/auth-ad';
import { loggerMiddleware } from './middlewares/logger';
import { diMiddleware } from './middlewares/di';
import { authRouter } from './routes/auth';
import { healthRouter } from './routes/health';
import { systemRouter } from './routes/plugin';
import type { Database } from '@shared/db';
import { setActiveRegistry } from './services/auth-service';

// コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
if (!isTest) {
    console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog());
}

/**
 * アプリケーションのインスタンスを非同期で生成・初期化する関数
 */
export async function createApp(db: Database) {
    // プラグインの登録
    const authRegistry = new AuthPluginRegistry();
    authRegistry.register(new LocalAuthPlugin(db));
    authRegistry.register(new ActiveDirectoryAuthPlugin());
    setActiveRegistry(authRegistry);

    const app = new Hono<AppEnv>();

    // -----------------------------------------------------------------------------
    // グローバルミドルウェア (全リクエストで最初に実行する処理)
    // -----------------------------------------------------------------------------
    app.use('*', loggerMiddleware);

    // CORS ミドルウェアの適用
    app.use(
        '*',
        cors({
            origin: env.CORS_ORIGIN,
            allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
            allowHeaders: ['Content-Type', 'Authorization'],
            credentials: true,
        })
    );

    // DBインスタンス（ミドルウェア）を注入(本番用のPoolクライアント等を生成して渡す)
    app.use('*', diMiddleware(db));

    // -----------------------------------------------------------------------------
    // テスト専用ルート (テストの場合のみ有効化)
    // -----------------------------------------------------------------------------
    if (isTest) {
        app.get('/test/error', () => {
            throw new Error('Test internal error');
        });
    }

    // -----------------------------------------------------------------------------
    // ルーティング・モジュール読み込み
    // -----------------------------------------------------------------------------

    // ヘルスチェックルート (/healthz)
    app.route('/', healthRouter);

    // 認証関連ルート (/api/auth/*)
    app.route('/api/auth', authRouter(env.JWT_SECRET, authRegistry));

    // システム状態管理ルート (/api/system/*)
    app.route('/api/system', systemRouter);

    // プラグイン/フィーチャーモジュールの動的読み込み（非同期処理の完了を待つ）
    await loadFeatureModules(app, 'features/*/index.ts', db);

    // -----------------------------------------------------------------------------
    // テスト専用バリデーションルート (テストの場合のみ)
    // -----------------------------------------------------------------------------
    if (isTest) {
        const sampleSchema = z.object({
            name: z.string().min(2, 'Name must be at least 2 characters'),
            email: z.string().email('Invalid email address'),
        });

        app.post(
            '/test/validation',
            zValidator('json', sampleSchema, (result, c) => {
                if (!result.success) {
                    const invalidParams = result.error.issues.map((issue) => ({
                        name: issue.path.join('.'),
                        reason: issue.message,
                    }));
                    throw new ValidationError(invalidParams);
                }
            }),
            (c) => {
                return c.json({ success: true });
            }
        );
    }

    // -----------------------------------------------------------------------------
    // 404 Not Found ハンドラー (RFC 9457 形式)
    // -----------------------------------------------------------------------------
    app.notFound((c) => {
        const problem: ProblemDetails = {
            type: 'about:blank',
            title: 'Not Found',
            status: 404,
            detail: 'The requested resource was not found',
            instance: c.req.path,
        };
        return c.json(problem, 404);
    });

    // -----------------------------------------------------------------------------
    // 共通エラーハンドラー (app.onError - RFC 9457 形式)
    // -----------------------------------------------------------------------------
    app.onError((err, c) => {
        let status = 500;
        let title = 'Internal Server Error';
        let detail = 'An unexpected error occurred';
        let invalidParams: any = undefined;

        if (err instanceof AppError) {
            status = err.status;
            title = err.title;
            detail = err.message;

            if (err instanceof ValidationError) {
                invalidParams = err.invalidParams;
            }
        }

        const problem: ProblemDetails = {
            type: 'about:blank',
            title,
            status,
            detail,
            instance: c.req.path,
            ...(invalidParams && { invalidParams }),
        };

        return c.json(problem, status as any);
    });

    return app;
}

// 💡 【修正点】最下部にあった `if (!isTest) { serve(...) }` の起動処理を丸ごと完全削除

export type AppType = typeof createApp;


// import { Hono } from 'hono';
// import { AppEnv } from '@shared/functions';
// import { cors } from 'hono/cors';
// import { serve } from '@hono/node-server';
// import { z } from 'zod';
// import { zValidator } from '@hono/zod-validator';
// import { AppError, ProblemDetails, ValidationError } from '@shared/errors';
// import { env, isTest, formatEnvForLog } from '@shared/functions';
// import { AuthPluginRegistry } from '@shared/functions';
// import { loadFeatureModules } from './auto-loader/hono-auto-loader';
// import { LocalAuthPlugin } from '@plugins/auth-local';
// import { ActiveDirectoryAuthPlugin } from '@plugins/auth-ad';
// import { loggerMiddleware } from './middlewares/logger';
// import { diMiddleware } from './middlewares/di';
// import { authRouter } from './routes/auth';
// import { healthRouter } from './routes/health';
// import { systemRouter } from './routes/plugin';
// import { createDb } from '@shared/db';
// import type { Database } from '@shared/db';

// // apps/api/src/index.ts の最上部に追記
// console.log(`[DEBUG] src/index.ts が読み込まれました。スタックトレース:`, new Error().stack);

// // コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
// if (!isTest) {
//     console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog());
// }
// // DBインスタンス（ミドルウェア）を注入(本番用のPoolクライアント等を生成して渡す)
// const db = createDb('pg');

// // 3. プラグインの登録
// AuthPluginRegistry.register(new LocalAuthPlugin(db));
// AuthPluginRegistry.register(new ActiveDirectoryAuthPlugin());

// /**
//  * アプリケーションのインスタンスを非同期で生成・初期化する関数
//  */
// export async function createApp(db: Database) {
//     const app = new Hono<AppEnv>();

//     // -----------------------------------------------------------------------------
//     // グローバルミドルウェア (全リクエストで最初に実行する処理)
//     // -----------------------------------------------------------------------------
//     app.use('*', loggerMiddleware);

//     // CORS ミドルウェアの適用
//     app.use(
//         '*',
//         cors({
//             origin: env.CORS_ORIGIN,
//             allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
//             allowHeaders: ['Content-Type', 'Authorization'],
//             credentials: true,
//         })
//     );

//     // DBインスタンス（ミドルウェア）を注入(本番用のPoolクライアント等を生成して渡す)
//     app.use('*', diMiddleware(db));

//     // -----------------------------------------------------------------------------
//     // テスト専用ルート (テストの場合のみ有効化)
//     // -----------------------------------------------------------------------------
//     if (isTest) {
//         app.get('/test/error', () => {
//             throw new Error('Test internal error');
//         });
//     }

//     // -----------------------------------------------------------------------------
//     // ルーティング・モジュール読み込み
//     // -----------------------------------------------------------------------------
//     // ヘルスチェックルート (/healthz)
//     app.route('/', healthRouter);

//     // 認証関連ルート (/api/auth/*)
//     app.route('/api/auth', authRouter(env.JWT_SECRET));

//     // システム状態管理ルート (/api/system/*)
//     app.route('/api/system', systemRouter);

//     // プラグイン/フィーチャーモジュールの動的読み込み（非同期処理の完了を待つ）
//     await loadFeatureModules(app, 'features/*/index.ts', db);

//     // -----------------------------------------------------------------------------
//     // テスト専用バリデーションルート (テストの場合のみ)
//     // -----------------------------------------------------------------------------
//     if (isTest) {
//         const sampleSchema = z.object({
//             name: z.string().min(2, 'Name must be at least 2 characters'),
//             email: z.string().email('Invalid email address'),
//         });

//         app.post(
//             '/test/validation',
//             zValidator('json', sampleSchema, (result, c) => {
//                 if (!result.success) {
//                     const invalidParams = result.error.issues.map((issue) => ({
//                         name: issue.path.join('.'),
//                         reason: issue.message,
//                     }));
//                     throw new ValidationError(invalidParams);
//                 }
//             }),
//             (c) => {
//                 return c.json({ success: true });
//             }
//         );
//     }

//     // -----------------------------------------------------------------------------
//     // 404 Not Found ハンドラー (RFC 9457 形式)
//     // -----------------------------------------------------------------------------
//     app.notFound((c) => {
//         const problem: ProblemDetails = {
//             type: 'about:blank',
//             title: 'Not Found',
//             status: 404,
//             detail: 'The requested resource was not found',
//             instance: c.req.path,
//         };
//         return c.json(problem, 404);
//     });

//     // -----------------------------------------------------------------------------
//     // 共通エラーハンドラー (app.onError - RFC 9457 形式)
//     // -----------------------------------------------------------------------------
//     app.onError((err, c) => {
//         let status = 500;
//         let title = 'Internal Server Error';
//         let detail = 'An unexpected error occurred';
//         let invalidParams: any = undefined;

//         if (err instanceof AppError) {
//             status = err.status;
//             title = err.title;
//             detail = err.message;

//             if (err instanceof ValidationError) {
//                 invalidParams = err.invalidParams;
//             }
//         }

//         const problem: ProblemDetails = {
//             type: 'about:blank',
//             title,
//             status,
//             detail,
//             instance: c.req.path,
//             ...(invalidParams && { invalidParams }),
//         };

//         return c.json(problem, status as any);
//     });

//     return app;
// }

// // -----------------------------------------------------------------------------
// // サーバーバインド & 起動処理 (本番用)
// // -----------------------------------------------------------------------------
// if (!isTest) {
//     // DBインスタンス（ミドルウェア）を注入(本番用のPoolクライアント等を生成して渡す)
//     createApp(db).then((app) => {
//         const port = env.PORT;
//         console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);
//         serve({
//             fetch: app.fetch,
//             port,
//             hostname: '0.0.0.0',
//         });
//     });
// }

// export type AppType = typeof createApp;
