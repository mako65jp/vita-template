import { Hono } from 'hono';
import type { AppEnv, AppServices } from './types';
import { cors } from 'hono/cors';
import { z } from 'zod';
import { zValidator } from '@hono/zod-validator';
import { AppError, ProblemDetails, ValidationError } from '@shared/errors';
import { env, isTest, formatEnvForLog } from '@shared/functions';
import { loadFeatureModules } from './auto-loader/hono-auto-loader';
import { loggerMiddleware } from './middlewares/logger';
import { diMiddleware } from './middlewares/di';
import { authRouter } from './routes/auth';
import { healthRouter } from './routes/health';
import { systemRouter } from './routes/plugin';
import { setActiveRegistry } from './services/auth-service';

// コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
if (!isTest) {
    console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog());
}

/**
 * アプリケーションのインスタンスを非同期で生成・初期化する関数
 */
export async function createApp(services: AppServices) {
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
        }),
    );

    // プラグインの登録
    setActiveRegistry(services.authRegistry);

    // DBインスタンス（ミドルウェア）を注入(本番用のPoolクライアント等を生成して渡す)
    app.use(
        '*',
        diMiddleware({
            pluginRegistry: services.pluginRegistry,
            authRegistry: services.authRegistry,
            dbInstance: services.dbInstance,
        }),
    );

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

    // 認証関連ルート
    app.route('/api/auth', authRouter(env.JWT_SECRET, services.authRegistry));

    // システム状態管理ルート (/api/system/*)
    app.route('/api/system', systemRouter);

    // プラグイン/フィーチャーモジュールの動的読み込み（非同期処理の完了を待つ）
    await loadFeatureModules(app, 'features/*/index.ts', services.dbInstance);

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
            },
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
