import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Hono } from 'hono';
import type { AppEnv } from '@shared/functions';
import { sign } from 'hono/jwt';

import { loadFeatureModules } from './hono-auto-loader';
import { env, PluginRegistry } from '@shared/functions';
import { createTestEnv } from '../../../../vitest-clear'; // 💡 作り直し関数をインポート

describe('hono-auto-loader', () => {
    let app: any;
    let db: any; // 検証用にdbも受け取れるように定義

    beforeEach(async () => {
        // 💡 完璧なアプローチ：テストごとに、DBごと app を丸ごと新しく作り直す！
        const testEnv = await createTestEnv();
        app = testEnv.app;
        db = testEnv.db;
    });

    // 💡 ヘルパー: JWT 生成
    const createToken = async (role: string = 'user') => {
        return await sign({ sub: 'user-123', role }, env.JWT_SECRET);
    };


    describe('DB ステータス制御とロード処理', () => {
        it('1. DBで有効(enabled: true)のプラグインは正常にマウントされアクセスできること', async () => {
            const pluginId = 'test-plugin-enabled';
            const dummyApp = new Hono<AppEnv>();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            // ⭕ getActivePlugins(db) の内部で実行される db.select().from(plugins) の挙動を安全に偽装
            vi.spyOn(db, 'select').mockImplementation(() => {
                return {
                    from: () => [
                        { id: pluginId, name: '標準プラグイン', enabled: true }
                    ]
                } as any;
            });

            await loadFeatureModules(app, 'features/*/src/index.ts', db);

            const token = await createToken('user');
            const res = await app.request(`/api/${pluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            expect(res.status).toBe(200);
        });

        it('2. DBで無効(enabled: false)のプラグインはスキップされ 404 になること', async () => {
            const pluginId = 'test-plugin-disabled';
            const dummyApp = new Hono<AppEnv>();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            // ⭕ ステータスが無効(enabled: false)のプラグインを返すように偽装
            vi.spyOn(db, 'select').mockImplementation(() => {
                return {
                    from: () => [
                        { id: pluginId, name: '標準プラグイン', enabled: false }
                    ]
                } as any;
            });

            await loadFeatureModules(app, 'features/*/src/index.ts', db);

            const token = await createToken('user');
            const res = await app.request(`/api/${pluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            expect(res.status).toBe(404);
        });

        it('3. DB未登録の場合はデフォルト有効として処理されること', async () => {
            const pluginId = 'test-plugin-unregistered';
            const dummyApp = new Hono<AppEnv>();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            // ⭕ DBから何も見つからない（未登録: 空配列）状態を模倣
            vi.spyOn(db, 'select').mockImplementation(() => {
                return {
                    from: () => []
                } as any;
            });

            await loadFeatureModules(app, 'features/*/src/index.ts', db);

            const token = await createToken('user');
            const res = await app.request(`/api/${pluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            expect(res.status).toBe(200);
        });

        it('4. DBクエリ例外時でもクラッシュせずフォールバック動作すること', async () => {
            const pluginId = 'test-plugin-fallback';
            const dummyApp = new Hono<AppEnv>();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            // ⭕ データベースの切断や例外を安全にシミュレート
            const selectSpy = vi.spyOn(db, 'select').mockImplementation(() => {
                throw new Error('DB Connection Error');
            });

            // const app = createTestApp();
            await loadFeatureModules(app, 'features/*/src/index.ts', db);

            const token = await createToken('user');
            const res = await app.request(`/api/${pluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });

            expect(res.status).toBe(200); // 例外時でも未登録(デフォルト有効)としてフォールバックすることの検証
            selectSpy.mockRestore();
        });

        it('5. routes 未定義のプラグインはエラーなくスキップされること', async () => {
            const pluginId = 'test-ui-only-plugin';
            PluginRegistry.register({ id: pluginId, name: 'UI専用プラグイン' });

            vi.spyOn(db, 'select').mockImplementation(() => {
                return { from: () => [] } as any;
            });

            await expect(loadFeatureModules(app, 'features/*/src/index.ts', db)).resolves.not.toThrow();
        });
    });

    describe('認証・認可ミドルウェアの適用', () => {
        it('6. トークンなしの場合 401 Unauthorized になること', async () => {
            const pluginId = 'test-plugin-auth';
            const dummyApp = new Hono<AppEnv>();
            dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
            PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

            vi.spyOn(db, 'select').mockImplementation(() => {
                return { from: () => [] } as any;
            });

            await loadFeatureModules(app, 'features/*/src/index.ts', db);

            const res = await app.request(`/api/${pluginId}/hello`);
            expect(res.status).toBe(401);
        });

        it('7. requiredRole の認可が正しく機能すること (一般ユーザー: 403, 管理者: 200)', async () => {
            const pluginId = 'test-rbac-plugin';
            const rbacApp = new Hono<AppEnv>();
            rbacApp.get('/admin-only', (c) => c.json({ message: 'admin content' }));
            PluginRegistry.register({
                id: pluginId,
                name: '権限テスト用プラグイン',
                routes: rbacApp,
                requiredRole: 'admin',
            });

            vi.spyOn(db, 'select').mockImplementation(() => {
                return { from: () => [] } as any;
            });

            await loadFeatureModules(app, 'features/*/src/index.ts', db);

            // 一般ユーザー -> 403
            const userToken = await createToken('user');
            const resUser = await app.request(`/api/${pluginId}/admin-only`, {
                headers: { Authorization: `Bearer ${userToken}` },
            });
            expect(resUser.status).toBe(403);

            // 管理者 -> 200
            const adminToken = await createToken('admin');
            const resAdmin = await app.request(`/api/${pluginId}/admin-only`, {
                headers: { Authorization: `Bearer ${adminToken}` },
            });
            expect(resAdmin.status).toBe(200);
        });
    });
});



// import { describe, it, expect, beforeEach, vi } from 'vitest';
// import { Hono } from 'hono';
// import type { AppEnv } from '@shared/functions';
// import { sign } from 'hono/jwt';

// import { plugins } from '@shared/db';
// import { loadFeatureModules } from './hono-auto-loader';
// import { env, PluginRegistry } from '@shared/functions';
// import { AppError } from '@shared/errors';
// import { createDb } from '@shared/db';


// describe('hono-auto-loader', () => {
//     const createTestApp = () => {
//         const app = new Hono<AppEnv>();
//         app.onError((err, c) => {
//             if (err instanceof AppError) {
//                 return c.json({ error: err.message }, err.status as any);
//             }
//             return c.json({ error: 'Internal Server Error' }, 500);
//         });
//         return app;
//     };

//     // 💡 ヘルパー: JWT 生成
//     const createToken = async (role: string = 'user') => {
//         return await sign({ sub: 'user-123', role }, env.JWT_SECRET);
//     };

//     const db = createDb("pgmem");
//     beforeEach(async () => {
//         PluginRegistry.clear();
//         try {
//             await db.delete(plugins);
//         } catch (e) {
//             // 無視
//         }
//     });

//     describe('DB ステータス制御とロード処理', () => {
//         it('1. DBで有効(enabled: true)のプラグインは正常にマウントされアクセスできること', async () => {
//             const pluginId = 'test-plugin-enabled';
//             const dummyApp = new Hono<AppEnv>();
//             dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

//             await db.insert(plugins).values({
//                 id: pluginId,
//                 name: '標準プラグイン',
//                 enabled: true,
//             });

//             const app = createTestApp();
//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const token = await createToken('user');
//             const res = await app.request(`/api/${pluginId}/hello`, {
//                 headers: { Authorization: `Bearer ${token}` },
//             });
//             expect(res.status).toBe(200);
//         });

//         it('2. DBで無効(enabled: false)のプラグインはスキップされ 404 になること', async () => {
//             const pluginId = 'test-plugin-disabled';
//             const dummyApp = new Hono<AppEnv>();
//             dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

//             await db.insert(plugins).values({
//                 id: pluginId,
//                 name: '標準プラグイン',
//                 enabled: false,
//             });

//             const app = createTestApp();
//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const token = await createToken('user');
//             const res = await app.request(`/api/${pluginId}/hello`, {
//                 headers: { Authorization: `Bearer ${token}` },
//             });
//             expect(res.status).toBe(404);
//         });

//         it('3. DB未登録の場合はデフォルト有効として処理されること', async () => {
//             const pluginId = 'test-plugin-unregistered';
//             const dummyApp = new Hono<AppEnv>();
//             dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

//             const app = createTestApp();
//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const token = await createToken('user');
//             const res = await app.request(`/api/${pluginId}/hello`, {
//                 headers: { Authorization: `Bearer ${token}` },
//             });
//             expect(res.status).toBe(200);
//         });

//         it('4. DBクエリ例外時でもクラッシュせずフォールバック動作すること', async () => {
//             const pluginId = 'test-plugin-fallback';
//             const dummyApp = new Hono<AppEnv>();
//             dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

//             const selectSpy = vi.spyOn(db, 'select').mockImplementationOnce(() => {
//                 throw new Error('DB Connection Error');
//             });

//             const app = createTestApp();
//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const token = await createToken('user');
//             const res = await app.request(`/api/${pluginId}/hello`, {
//                 headers: { Authorization: `Bearer ${token}` },
//             });

//             expect(res.status).toBe(200);
//             selectSpy.mockRestore();
//         });

//         it('5. routes 未定義のプラグインはエラーなくスキップされること', async () => {
//             const pluginId = 'test-ui-only-plugin';
//             PluginRegistry.register({ id: pluginId, name: 'UI専用プラグイン' });

//             const app = createTestApp();
//             await expect(loadFeatureModules(app, 'features/*/src/index.ts', db)).resolves.not.toThrow();
//         });
//     });

//     describe('認証・認可ミドルウェアの適用', () => {
//         it('6. トークンなしの場合 401 Unauthorized になること', async () => {
//             const pluginId = 'test-plugin-auth';
//             const dummyApp = new Hono<AppEnv>();
//             dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
//             PluginRegistry.register({ id: pluginId, name: '標準プラグイン', routes: dummyApp });

//             const app = createTestApp();
//             await loadFeatureModules(app, 'features/*/src/index.ts', db);

//             const res = await app.request(`/api/${pluginId}/hello`);
//             expect(res.status).toBe(401);
//         });

//         it('7. requiredRole の認可が正しく機能すること (一般ユーザー: 403, 管理者: 200)', async () => {
//             const pluginId = 'test-rbac-plugin';
//             const rbacApp = new Hono<AppEnv>();
//             rbacApp.get('/admin-only', (c) => c.json({ message: 'admin content' }));
//             PluginRegistry.register({
//                 id: pluginId,
//                 name: '権限テスト用プラグイン',
//                 routes: rbacApp,
//                 requiredRole: 'admin',
//             });

//             const app = createTestApp();
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
//         });
//     });
// });
