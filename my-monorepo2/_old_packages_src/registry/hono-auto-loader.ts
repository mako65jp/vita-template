// shared/core/src/registry/hono-auto-loader.ts
import { Hono } from 'hono';
import { glob } from 'glob';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { db } from '../db';
import { plugins as pluginsTable } from '../db/schema';
import { PluginRegistry } from '../plugins/registry';
import { authMiddleware } from '@app/api/src/middlewares/auth-middleware';
import { rbacMiddleware } from '@app/api/src/middlewares/rbac-middleware';
import { env } from '../config/env';
import { getProjectRootDir } from '../utils/path';

export async function loadFeatureModules(app: Hono, pattern: string) {
    // 💡 プロジェクトルートを環境に依存せず確実に取得
    const rootDir = getProjectRootDir();

    // rootDir を起点に Glob 検索を実行
    const files = await glob(pattern, { cwd: rootDir });

    // 1. 各機能モジュールを動的インポート
    for (const file of files) {
        const absolutePath = path.resolve(rootDir, file);
        const moduleUrl = pathToFileURL(absolutePath).href;
        await import(moduleUrl);
    }

    // 2. DB から登録済みプラグインの有効/無効ステータスを取得
    let dbPluginsMap = new Map<string, boolean>();
    try {
        const dbPlugins = await db.select().from(pluginsTable);
        dbPlugins.forEach((p) => dbPluginsMap.set(p.id, p.enabled));
    } catch (error) {
        console.warn('[Auto-Loader] DB query failed or table not found. Defaulting all plugins to enabled.');
    }

    // 3. レジストリに登録されたプラグインをチェックし、有効なもののみマウント
    for (const plugin of PluginRegistry.getAll()) {
        const isEnabled = dbPluginsMap.has(plugin.id)
            ? dbPluginsMap.get(plugin.id)
            : true;

        if (isEnabled) {
            if (plugin.routes !== undefined) {
                const basePath = `/api/${plugin.id}`;

                // 認証ミドルウェアの適用
                app.use(`${basePath}/*`, authMiddleware(env.JWT_SECRET));

                // 要求ロール（requiredRole）が指定されている場合は RBAC ガードを適用
                if (plugin.requiredRole) {
                    app.use(`${basePath}/*`, rbacMiddleware([plugin.requiredRole]));
                }

                // API パス: /api/{plugin-id} 配下にマウント
                app.route(basePath, plugin.routes);
                console.log(`[Auto-Loader] ✅ Loaded & Mounted Plugin: ${plugin.id}`);
            }
        } else {
            console.log(`[Auto-Loader] ⏸️ Skipped Disabled Plugin: ${plugin.id}`);
        }
    }
}


// import { Hono } from 'hono';
// import { glob } from 'glob';
// import path from 'node:path';
// import { pathToFileURL } from 'node:url';
// import { db } from '../db';
// import { plugins as pluginsTable } from '../db/schema';
// import { PluginRegistry } from '../plugins/registry';

// //
// // features/*/src/index.ts から機能モジュールを自動読み込みし、
// // DB 上で有効（enabled: true）なプラグインのみを Hono アプリへマウントする関数
// //
// export async function loadFeatureModules(app: Hono, pattern: string) {
//     const files = await glob(pattern);

//     // 1. 各機能モジュールを動的インポート
//     // (各モジュールの内部で PluginRegistry.register() が実行される)
//     for (const file of files) {
//         const absolutePath = path.resolve(file);
//         const moduleUrl = pathToFileURL(absolutePath).href;
//         await import(moduleUrl);
//     }

//     // 2. DB から登録済みプラグインの有効/無効ステータスを取得
//     let dbPluginsMap = new Map<string, boolean>();
//     try {
//         const dbPlugins = await db.select().from(pluginsTable);
//         dbPlugins.forEach((p) => dbPluginsMap.set(p.id, p.enabled));
//     } catch (error) {
//         console.warn('[Auto-Loader] DB query failed or table not found. Defaulting all plugins to enabled.');
//     }

//     // 3. レジストリに登録されたプラグインをチェックし、有効なもののみマウント
//     for (const plugin of PluginRegistry.getAll()) {
//         // DB に未登録の場合はデフォルトで有効 (true) と判定
//         const isEnabled = dbPluginsMap.has(plugin.id)
//             ? dbPluginsMap.get(plugin.id)
//             : true;

//         if (isEnabled) {
//             if (plugin.routes !== undefined) {
//                 // API パス: /api/{plugin-id} 配下にマウント
//                 app.route(`/api/${plugin.id}`, plugin.routes);
//                 console.log(`[Auto-Loader] ✅ Loaded & Mounted Plugin: ${plugin.id}`);
//             }
//         } else {
//             console.log(`[Auto-Loader] ⏸️ Skipped Disabled Plugin: ${plugin.id}`);
//         }
//     }
// }
