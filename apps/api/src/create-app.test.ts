// src/index.test.ts

import { describe, it, expect, beforeEach, vi } from 'vitest';
import type { Database } from '@shared/db';
import { AuthPluginRegistry } from '@shared/functions';
import { AppServices } from './types';
import { PluginRegistry } from '@shared/plugin';

const registerMock = vi.fn();
const setActiveRegistryMock = vi.fn();
const loadFeatureModulesMock = vi.fn();

vi.mock('@shared/functions', () => {
    class MockRegistry {
        register = registerMock;
    }

    return {
        env: {
            CORS_ORIGIN: 'http://localhost:3000',
            JWT_SECRET: 'test-secret',
        },
        isTest: true,
        formatEnvForLog: vi.fn(),
        AuthPluginRegistry: MockRegistry,
    };
});

vi.mock('./services/auth-service', () => ({
    setActiveRegistry: setActiveRegistryMock,
}));

vi.mock('./auto-loader/hono-auto-loader', () => ({
    loadFeatureModules: loadFeatureModulesMock,
}));

vi.mock('@plugins/auth-local', () => {
    return {
        LocalAuthPlugin: class {
            public name = 'local';

            constructor(_db: unknown) { }
        },
    };
});

vi.mock('@plugins/auth-ad', () => {
    return {
        ActiveDirectoryAuthPlugin: class {
            public name = 'ad';
        },
    };
});

vi.mock('./middlewares/logger', () => ({
    loggerMiddleware: async (_c: any, next: any) => {
        await next();
    },
}));

vi.mock('./middlewares/di', () => ({
    diMiddleware:
        (_db: any) =>
            async (_c: any, next: any) => {
                await next();
            },
}));

vi.mock('./routes/health', async () => {
    const { Hono } = await import('hono');

    const router = new Hono();

    router.get('/healthz', (c) =>
        c.json({
            status: 'ok',
        })
    );

    return {
        healthRouter: router,
    };
});

vi.mock('./routes/plugin', async () => {
    const { Hono } = await import('hono');

    const router = new Hono();

    router.get('/status', (c) =>
        c.json({
            ok: true,
        })
    );

    return {
        systemRouter: router,
    };
});

vi.mock('./routes/auth', async () => {
    const { Hono } = await import('hono');

    return {
        authRouter: vi.fn(() => {
            const r = new Hono();

            r.get('/ping', (c) =>
                c.json({
                    success: true,
                })
            );

            return r;
        }),
    };
});


describe('createApp', () => {
    let db: Database;
    let services: AppServices;

    beforeEach(() => {
        vi.clearAllMocks();

        db = {} as Database;
        services = {
            pluginRegistry: new PluginRegistry(),
            authRegistry: new AuthPluginRegistry(),
            dbInstance: db,
        };
    });

    it('AuthPlugin を登録して active registry を設定する', async () => {
        const { createApp } = await import('./create-app');

        await createApp(services);

        expect(setActiveRegistryMock).toHaveBeenCalledWith(
            services.authRegistry
        );
    });

    it('loadFeatureModules を呼び出す', async () => {
        const { createApp } = await import('./create-app');

        await createApp(services);

        expect(loadFeatureModulesMock).toHaveBeenCalledTimes(1);

        expect(loadFeatureModulesMock).toHaveBeenCalledWith(
            expect.anything(),
            'features/*/index.ts',
            db
        );
    });

    it('health route が利用できる', async () => {
        const { createApp } = await import('./create-app');

        const app = await createApp(services);

        const res = await app.request('/healthz');

        expect(res.status).toBe(200);

        expect(await res.json()).toEqual({
            status: 'ok',
        });
    });

    it('auth route が利用できる', async () => {
        const { createApp } = await import('./create-app');

        const app = await createApp(services);

        const res = await app.request('/api/auth/ping');

        expect(res.status).toBe(200);

        expect(await res.json()).toEqual({
            success: true,
        });
    });

    it('404 を RFC9457形式で返す', async () => {
        const { createApp } = await import('./create-app');

        const app = await createApp(services);

        const res = await app.request('/not-found');

        expect(res.status).toBe(404);

        expect(await res.json()).toEqual({
            type: 'about:blank',
            title: 'Not Found',
            status: 404,
            detail: 'The requested resource was not found',
            instance: '/not-found',
        });
    });

    it('test/error は 500 を返す', async () => {
        const { createApp } = await import('./create-app');

        const app = await createApp(services);

        const res = await app.request('/test/error');

        expect(res.status).toBe(500);

        expect(await res.json()).toEqual({
            type: 'about:blank',
            title: 'Internal Server Error',
            status: 500,
            detail: 'An unexpected error occurred',
            instance: '/test/error',
        });
    });

    it('validation 成功時は success=true を返す', async () => {
        const { createApp } = await import('./create-app');

        const app = await createApp(services);

        const res = await app.request('/test/validation', {
            method: 'POST',
            headers: {
                'content-type': 'application/json',
            },
            body: JSON.stringify({
                name: 'Taro',
                email: 'taro@example.com',
            }),
        });

        expect(res.status).toBe(200);

        expect(await res.json()).toEqual({
            success: true,
        });
    });

    it('ValidationError を RFC9457形式で返す', async () => {
        const { createApp } = await import('./create-app');

        const app = await createApp(services);

        const res = await app.request('/test/validation', {
            method: 'POST',
            headers: {
                'content-type': 'application/json',
            },
            body: JSON.stringify({
                name: 'A',
                email: 'invalid',
            }),
        });

        expect(res.status).toBe(400);

        const body: any = await res.json();

        expect(body.title).toBe('Bad Request');
        expect(body.status).toBe(400);

        expect(body.invalidParams).toEqual([
            {
                name: 'name',
                reason: 'Name must be at least 2 characters',
            },
            {
                name: 'email',
                reason: 'Invalid email address',
            },
        ]);
    });
});



// import { describe, it, expect, beforeEach } from 'vitest';
// import { createTestEnv } from '../../../vitest-helpers'; // プロジェクトの共通環境作成関数
// import * as schema from '@shared/db/schema';

// describe('API Error Handling (RFC 9457)', () => {

//     beforeEach(async () => {
//     });

//     it('未定義のルートにアクセスした場合、404エラーがRFC9457形式で返ること', async () => {

//         // 1. クリーンなテスト環境を取得
//         const { app, db, pglite } = await createTestEnv();

//         const res = await app.request('/api/non-existent-route');
//         expect(res.status).toBe(404);

//         const body = (await res.json()) as any;
//         expect(body.status).toBe(404);

//         // 必ず、PGliteをクローズする
//         await pglite.close();
//     });
// });

// describe('User Management Integration (Step 9)', () => {
//     beforeEach(async () => {
//     });

//     it('前のテストケースでデータが追加されていても、このケースでは空のままであること', async () => {

//         // 1. クリーンなテスト環境を取得
//         const { app, db, pglite } = await createTestEnv();

//         // 💡 appごと完全に作り直されているため、他のテストケースの実行状況の影響は 100% 受けません
//         const result = await db.select().from(schema.users);
//         expect(result).toHaveLength(0); // 確実にPassed（成功）します！

//         // 必ず、PGliteをクローズする
//         await pglite.close();
//     });
// });
