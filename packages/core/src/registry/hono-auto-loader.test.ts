import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Hono } from 'hono';
import { sign } from 'hono/jwt';
import { db, plugins as pluginsTable, loadFeatureModules } from '../server';
import { PluginRegistry } from '../index';
import { env } from '../config/env';
import { AppError } from '../errors';

describe('hono-auto-loader', () => {
    const dummyPluginId = 'test-dummy-plugin';
    const rbacPluginId = 'test-rbac-plugin';
    const uiOnlyPluginId = 'test-ui-only-plugin';
    const noRbacPluginId = 'test-no-rbac-plugin';

    // 💡 ヘルパー: エラーハンドラ付き Hono アプリの作成
    const createTestApp = () => {
        const app = new Hono();
        app.onError((err, c) => {
            if (err instanceof AppError) {
                return c.json({ error: err.message }, err.status as any);
            }
            return c.json({ error: 'Internal Server Error' }, 500);
        });
        return app;
    };

    // 💡 ヘルパー: JWT 生成
    const createToken = async (role: string = 'user') => {
        return await sign({ sub: 'user-123', role }, env.JWT_SECRET);
    };

    beforeEach(() => {
        PluginRegistry.clear();

        // 1. 標準プラグイン
        const dummyApp = new Hono();
        dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));
        PluginRegistry.register({
            id: dummyPluginId,
            name: 'テスト用プラグイン',
            routes: dummyApp,
        });

        // 2. RBAC(管理者限定) プラグイン
        const rbacApp = new Hono();
        rbacApp.get('/admin-only', (c) => c.json({ message: 'admin content' }));
        PluginRegistry.register({
            id: rbacPluginId,
            name: '権限テスト用プラグイン',
            routes: rbacApp,
            requiredRole: 'admin',
        });

        // 3. UI専用プラグイン (routes なし)
        PluginRegistry.register({
            id: uiOnlyPluginId,
            name: 'UI専用プラグイン',
        });

        // 4. ロール指定なし (認証のみ) プラグイン
        const noRbacApp = new Hono();
        noRbacApp.get('/public-info', (c) => c.json({ message: 'public' }));
        PluginRegistry.register({
            id: noRbacPluginId,
            name: 'ロール無指定プラグイン',
            routes: noRbacApp,
        });
    });

    describe('DB ステータス制御とロード処理', () => {
        it('1. DBで有効(enabled: true)のプラグインは正常にマウントされアクセスできること', async () => {
            await db.insert(pluginsTable).values({
                id: dummyPluginId,
                name: 'テスト用プラグイン',
                enabled: true,
            }).onConflictDoUpdate({
                target: pluginsTable.id,
                set: { enabled: true },
            });

            const app = createTestApp();
            await loadFeatureModules(app, 'packages/features/*/src/index.ts');

            const token = await createToken('user');
            const res = await app.request(`/api/${dummyPluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            expect(res.status).toBe(200);
        });

        it('2. DBで無効(enabled: false)のプラグインはスキップされ 404 になること', async () => {
            await db.insert(pluginsTable).values({
                id: dummyPluginId,
                name: 'テスト用プラグイン',
                enabled: false,
            }).onConflictDoUpdate({
                target: pluginsTable.id,
                set: { enabled: false },
            });

            const app = createTestApp();
            await loadFeatureModules(app, 'packages/features/*/src/index.ts');

            const token = await createToken('user');
            const res = await app.request(`/api/${dummyPluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            expect(res.status).toBe(404);
        });

        it('3. DB未登録の場合はデフォルト有効として処理されること', async () => {
            const app = createTestApp();
            await loadFeatureModules(app, 'packages/features/*/src/index.ts');

            const token = await createToken('user');
            const res = await app.request(`/api/${dummyPluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            expect(res.status).toBe(200);
        });

        it('4. DBクエリ例外時でもクラッシュせずフォールバック動作すること', async () => {
            const selectSpy = vi.spyOn(db, 'select').mockImplementationOnce(() => {
                throw new Error('DB Connection Error');
            });

            const app = createTestApp();
            await loadFeatureModules(app, 'packages/features/*/src/index.ts');

            const token = await createToken('user');
            const res = await app.request(`/api/${dummyPluginId}/hello`, {
                headers: { Authorization: `Bearer ${token}` },
            });

            expect(res.status).toBe(200);
            selectSpy.mockRestore();
        });

        it('5. routes 未定義のプラグインはエラーなくスキップされること', async () => {
            const app = createTestApp();
            await expect(loadFeatureModules(app, 'packages/features/*/src/index.ts')).resolves.not.toThrow();
        });
    });

    describe('認証・認可ミドルウェアの適用', () => {
        it('6. トークンなしの場合 401 Unauthorized になること', async () => {
            const app = createTestApp();
            await loadFeatureModules(app, 'packages/features/*/src/index.ts');

            const res = await app.request(`/api/${dummyPluginId}/hello`);
            expect(res.status).toBe(401);
        });

        it('7. requiredRole の認可が正しく機能すること (一般ユーザー: 403, 管理者: 200)', async () => {
            const app = createTestApp();
            await loadFeatureModules(app, 'packages/features/*/src/index.ts');

            // 一般ユーザー -> 403
            const userToken = await createToken('user');
            const resUser = await app.request(`/api/${rbacPluginId}/admin-only`, {
                headers: { Authorization: `Bearer ${userToken}` },
            });
            expect(resUser.status).toBe(403);

            // 管理者 -> 200
            const adminToken = await createToken('admin');
            const resAdmin = await app.request(`/api/${rbacPluginId}/admin-only`, {
                headers: { Authorization: `Bearer ${adminToken}` },
            });
            expect(resAdmin.status).toBe(200);
        });
    });
});

// import { describe, it, expect, beforeEach } from 'vitest';
// import { Hono } from 'hono';
// import { db, plugins as pluginsTable, loadFeatureModules } from '../server';
// import { PluginRegistry } from '../index';

// describe('hono-auto-loader', () => {
//     const dummyPluginId = 'test-dummy-plugin';

//     beforeEach(() => {
//         const dummyApp = new Hono();
//         dummyApp.get('/hello', (c) => c.json({ message: 'hello from plugin' }));

//         PluginRegistry.register({
//             id: dummyPluginId,
//             name: 'テスト用プラグイン',
//             routes: dummyApp,
//             navItems: [{ label: 'テスト', path: '/test' }],
//         });
//     });

//     it('DBで有効(enabled: true)のプラグインのみ API ルートがマウントされること', async () => {
//         await db.insert(pluginsTable).values({
//             id: dummyPluginId,
//             name: 'テスト用プラグイン',
//             enabled: true,
//         }).onConflictDoUpdate({
//             target: pluginsTable.id,
//             set: { enabled: true },
//         });

//         const app = new Hono();
//         await loadFeatureModules(app, 'packages/features/*/src/server.ts');

//         const res = await app.request(`/api/${dummyPluginId}/hello`);
//         expect(res.status).toBe(200);
//     });

//     it('DBで無効(enabled: false)のプラグインはマウントされず 404 になること', async () => {
//         await db.insert(pluginsTable).values({
//             id: dummyPluginId,
//             name: 'テスト用プラグイン',
//             enabled: false,
//         }).onConflictDoUpdate({
//             target: pluginsTable.id,
//             set: { enabled: false },
//         });

//         const app = new Hono();
//         await loadFeatureModules(app, 'packages/features/*/src/index.ts');

//         const res = await app.request(`/api/${dummyPluginId}/hello`);
//         expect(res.status).toBe(404);
//     });
// });
