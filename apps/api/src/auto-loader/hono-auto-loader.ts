import { Hono } from 'hono';
import { glob } from 'glob';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { env } from '@shared/functions';
import { getProjectRootDir } from '@shared/server';
import { getActivePlugins } from '../utils/auto-loader-helper';
import { authMiddleware } from '../middlewares/auth-middleware';
import { rbacMiddleware } from '../middlewares/rbac-middleware';

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
    const pluginStatuses = await getActivePlugins();

    // 3. レジストリに登録されたプラグインをチェックし、有効なもののみマウント
    for (const { plugin, isEnabled } of pluginStatuses) {
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
