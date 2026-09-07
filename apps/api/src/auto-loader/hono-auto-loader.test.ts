import { beforeEach, describe, expect, it, vi } from 'vitest';

import { loadFeatureModules } from './hono-auto-loader';
import { Hono } from 'hono';
import type { AppEnv, PluginManifest, } from '@shared/functions';
import { glob } from 'glob';
import { getActivePlugins } from '../utils/auto-loader-helper';
import { authMiddleware } from '../middlewares/auth-middleware';
import { rbacMiddleware } from '../middlewares/rbac-middleware';

vi.mock('glob');
vi.mock('../utils/auto-loader-helper');
vi.mock('../middlewares/auth-middleware', () => ({
    authMiddleware: vi.fn(() => 'auth-middleware'),
}));

vi.mock('../middlewares/rbac-middleware', () => ({
    rbacMiddleware: vi.fn(() => 'rbac-middleware'),
}));

vi.mock('@shared/functions', () => ({
    env: {
        JWT_SECRET: 'test-secret',
    },
    isTest: false,
}));

vi.mock('@shared/server-utils', () => ({
    getProjectRootDir: vi.fn(() => '/project'),
    resolveFromProjectRoot: vi.fn((...paths: string[]) =>
        `/project/${paths.join('/')}`
    ),
}));

function createPlugin(
    overrides: Partial<PluginManifest> = {}
): PluginManifest {
    return {
        id: 'users',
        name: 'User Management',
        routes: new Hono<AppEnv>(),
        ...overrides,
    };
}

describe('loadFeatureModules', () => {
    let app: any;
    let db: any;

    beforeEach(() => {
        vi.clearAllMocks();

        app = {
            use: vi.fn(),
            route: vi.fn(),
        };

        db = {};
    });

    describe('plugin mount', () => {
        it('有効なプラグインをマウントできる', async () => {
            const plugin = createPlugin();

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: plugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(app.use).toHaveBeenCalledWith(
                '/api/users/*',
                expect.anything()
            );

            expect(app.route).toHaveBeenCalledWith(
                '/api/users',
                plugin.routes
            );
        });

        it('requiredRole がある場合は RBAC を適用する', async () => {
            const adminPlugin = createPlugin({
                id: 'admin',
                name: 'Admin',
                requiredRole: 'admin',
            });

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: adminPlugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(rbacMiddleware).toHaveBeenCalledWith([
                'admin',
            ]);

            expect(app.use).toHaveBeenCalledTimes(2);
        });

        it('requiredRole が無い場合は RBAC を適用しない', async () => {
            const plugin = createPlugin();

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: plugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(rbacMiddleware).not.toHaveBeenCalled();
        });

        it('routes が undefined の場合はマウントしない', async () => {
            const noRoutePlugin = createPlugin({
                routes: undefined,
            });
            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: noRoutePlugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(app.route).not.toHaveBeenCalled();
        });

        it('無効なプラグインはスキップする', async () => {
            const plugin = createPlugin();

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: plugin,
                    isEnabled: false,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(app.route).not.toHaveBeenCalled();
            expect(app.use).not.toHaveBeenCalled();
        });
    });

    describe('middleware', () => {
        it('authMiddleware に JWT_SECRET を渡す', async () => {
            const plugin = createPlugin();

            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([
                {
                    plugin: plugin,
                    isEnabled: true,
                },
            ]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(authMiddleware).toHaveBeenCalledWith(
                'test-secret'
            );
        });
    });

    describe('plugin status', () => {
        it('getActivePlugins に DB を渡す', async () => {
            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([]);

            await loadFeatureModules(app, '**/*.module.ts', db);

            expect(getActivePlugins).toHaveBeenCalledWith(
                db
            );
        });
    });

    describe('module loading', () => {
        it('glob に pattern と rootDir を渡す', async () => {
            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([]);

            await loadFeatureModules(
                app,
                'plugins/**/*.ts',
                db
            );

            expect(glob).toHaveBeenCalledWith(
                'plugins/**/*.ts',
                {
                    cwd: '/project',
                }
            );
        });

        it('プラグインファイルが存在しなくても例外にならない', async () => {
            vi.mocked(glob).mockResolvedValue([]);

            vi.mocked(getActivePlugins).mockResolvedValue([]);

            await expect(
                loadFeatureModules(
                    app,
                    '**/*.module.ts',
                    db
                )
            ).resolves.not.toThrow();
        });
    });
});


// import { describe, it, expect, beforeEach, vi } from 'vitest';
// import { createTestEnv } from '../../../../vitest-helpers'; // プロジェクトの共通環境作成関数
// import { sign } from 'hono/jwt';
// import { AppEnv, env, PluginRegistry } from '@shared/functions';
// import { loadFeatureModules } from './hono-auto-loader';
// import { Hono } from 'hono';

// describe('hono-auto-loader', () => {

//     beforeEach(async () => {
//     });

//     // 💡 ヘルパー: JWT 生成
//     const createToken = async (role: string = 'user') => {
//         return await sign({ sub: 'user-123', role }, env.JWT_SECRET);
//     };

//     describe('DB ステータス制御とロード処理', () => {
//         it('1. DBで有効(enabled: true)のプラグインは正常にマウントされアクセスできること', async () => {

//             // 1. クリーンなテスト環境を取得
//             const { app, db, pglite } = await createTestEnv();

//             const pluginId = 'test-plugin-enabled';
//             const pluginApp = new Hono<AppEnv>();
//             pluginApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: pluginApp });

//             // ⭕ getActivePlugins(db) の内部で実行される db.select().from(plugins) の挙動を安全に偽装
//             vi.spyOn(db, 'select').mockImplementation(() => {
//                 return {
//                     from: () => [
//                         { id: pluginId, name: '標準プラグイン', enabled: true }
//                     ]
//                 } as any;
//             });

//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const token = await createToken('user');
//             const res = await app.request(`/api/${pluginId}/hello`, {
//                 headers: { Authorization: `Bearer ${token}` },
//             });
//             expect(res.status).toBe(200);

//             // 必ず、PGliteをクローズする
//             await pglite.close();
//         });

//         it('2. DBで無効(enabled: false)のプラグインはスキップされ 404 になること', async () => {

//             // 1. クリーンなテスト環境を取得
//             const { app, db, pglite } = await createTestEnv();

//             const pluginId = 'test-plugin-disabled';
//             const pluginApp = new Hono<AppEnv>();
//             pluginApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: pluginApp });

//             // ⭕ ステータスが無効(enabled: false)のプラグインを返すように偽装
//             vi.spyOn(db, 'select').mockImplementation(() => {
//                 return {
//                     from: () => [
//                         { id: pluginId, name: '標準プラグイン', enabled: false }
//                     ]
//                 } as any;
//             });

//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const token = await createToken('user');
//             const res = await app.request(`/api/${pluginId}/hello`, {
//                 headers: { Authorization: `Bearer ${token}` },
//             });
//             expect(res.status).toBe(404);

//             // 必ず、PGliteをクローズする
//             await pglite.close();
//         });

//         it('3. DB未登録の場合はデフォルト有効として処理されること', async () => {

//             // 1. クリーンなテスト環境を取得
//             const { app, db, pglite } = await createTestEnv();

//             const pluginId = 'test-plugin-unregistered';
//             const pluginApp = new Hono<AppEnv>();
//             pluginApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: pluginApp });

//             // ⭕ DBから何も見つからない（未登録: 空配列）状態を模倣
//             vi.spyOn(db, 'select').mockImplementation(() => {
//                 return {
//                     from: () => []
//                 } as any;
//             });

//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const token = await createToken('user');
//             const res = await app.request(`/api/${pluginId}/hello`, {
//                 headers: { Authorization: `Bearer ${token}` },
//             });
//             expect(res.status).toBe(200);

//             // 必ず、PGliteをクローズする
//             await pglite.close();
//         });

//         it('4. DBクエリ例外時でもクラッシュせずフォールバック動作すること', async () => {

//             // 1. クリーンなテスト環境を取得
//             const { app, db, pglite } = await createTestEnv();

//             const pluginId = 'test-plugin-fallback';
//             const pluginApp = new Hono<AppEnv>();
//             pluginApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: pluginApp });

//             // ⭕ データベースの切断や例外を安全にシミュレート
//             const selectSpy = vi.spyOn(db, 'select').mockImplementation(() => {
//                 throw new Error('DB Connection Error');
//             });

//             // const app = createTestApp();
//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const token = await createToken('user');
//             const res = await app.request(`/api/${pluginId}/hello`, {
//                 headers: { Authorization: `Bearer ${token}` },
//             });

//             expect(res.status).toBe(200); // 例外時でも未登録(デフォルト有効)としてフォールバックすることの検証
//             selectSpy.mockRestore();

//             // 必ず、PGliteをクローズする
//             await pglite.close();
//         });

//         it('5. routes 未定義のプラグインはエラーなくスキップされること', async () => {

//             // 1. クリーンなテスト環境を取得
//             const { app, db, pglite } = await createTestEnv();

//             const pluginId = 'test-ui-only-plugin';
//             PluginRegistry.register({ id: pluginId, name: 'UI専用プラグイン' });

//             vi.spyOn(db, 'select').mockImplementation(() => {
//                 return { from: () => [] } as any;
//             });

//             await expect(loadFeatureModules(app, 'features/*/src/index.ts', db)).resolves.not.toThrow();

//             // 必ず、PGliteをクローズする
//             await pglite.close();
//         });
//     });

//     describe('認証・認可ミドルウェアの適用', () => {
//         it('6. トークンなしの場合 401 Unauthorized になること', async () => {

//             // 1. クリーンなテスト環境を取得
//             const { app, db, pglite } = await createTestEnv();

//             const pluginId = 'test-plugin-auth';
//             const pluginApp = new Hono<AppEnv>();
//             pluginApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: pluginApp });

//             vi.spyOn(db, 'select').mockImplementation(() => {
//                 return { from: () => [] } as any;
//             });

//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const res = await app.request(`/api/${pluginId}/hello`);
//             expect(res.status).toBe(401);

//             // 必ず、PGliteをクローズする
//             await pglite.close();
//         });

//         it('7. requiredRole の認可が正しく機能すること (一般ユーザー: 403, 管理者: 200)', async () => {

//             // 1. クリーンなテスト環境を取得
//             const { app, db, pglite } = await createTestEnv();

//             const pluginId = 'test-rbac-plugin';
//             const pluginApp = new Hono<AppEnv>();
//             pluginApp.get('/admin-only', (c) => c.json({ message: 'admin content' }));
//             PluginRegistry.register({
//                 id: pluginId,
//                 name: '権限テスト用プラグイン',
//                 routes: pluginApp,
//                 requiredRole: 'admin',
//             });

//             vi.spyOn(db, 'select').mockImplementation(() => {
//                 return { from: () => [] } as any;
//             });

//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             // 一般ユーザー -> 403
//             const userToken = await createToken('user');
//             const resUser = await app.request(`/api/${pluginId}/admin-only`, {
//                 headers: { Authorization: `Bearer ${userToken}` },
//             });
//             expect(resUser.status).toBe(403);

//             // 管理者 -> 200
//             const adminToken = await createToken('admin');
//             const resAdmin = await app.request(`/api/${pluginId}/admin-only`, {
//                 headers: { Authorization: `Bearer ${adminToken}` },
//             });
//             expect(resAdmin.status).toBe(200);

//             // 必ず、PGliteをクローズする
//             await pglite.close();
//         });
//     });
// });
