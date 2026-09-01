import { Hono } from 'hono';
import { AppEnv } from '@shared/functions';
import { Database } from '@shared/db';
import { glob } from 'glob';
import { pathToFileURL } from 'node:url';
import { env, isTest } from '@shared/functions'; // 💡 isTest を追加
import { getProjectRootDir, resolveFromProjectRoot } from '@shared/server-utils';
import { getActivePlugins } from '../utils/auto-loader-helper';
import { authMiddleware } from '../middlewares/auth-middleware';
import { rbacMiddleware } from '../middlewares/rbac-middleware';

// モジュールロードのキャッシュ化
let isModulesLoaded = false;

export async function loadFeatureModules(app: Hono<AppEnv>, pattern: string, db: Database) {

    // 💡 テスト環境（isTest）かつ、すでに最初の1回目でファイルロードが完了している場合は、
    // 重いディスクI/Oと import() の排他ロックを完全にスキップします。
    if (!(isTest && isModulesLoaded)) {
        const rootDir = getProjectRootDir();
        const files = await glob(pattern, { cwd: rootDir });

        // 1. 各機能モジュールを動的インポート（本当の最初の1回だけ実行）
        for (const file of files) {
            const paths = file.split('/')
            const absolutePath = resolveFromProjectRoot(...paths);
            const moduleUrl = pathToFileURL(absolutePath).href;
            await import(moduleUrl);
        }

        if (isTest) {
            isModulesLoaded = true; // テスト環境時はロード完了フラグを立てる
        }
    }

    // =========================================================================
    // 🟢 ここから下の「DBに応じた動的なプラグインマウント処理」は、
    // 既存の隔離ロジックを壊さないよう、ケースごとに毎回【100%実直に毎回実行】させます。
    // =========================================================================

    // 2. DB から登録済みプラグインの有効/無効ステータスを取得（毎回新しく渡された隔離DBを参照する）
    const pluginStatuses = await getActivePlugins(db);

    // 3. レジストリに登録されたプラグインをチェックし、有効なもののみマウント
    for (const { plugin, isEnabled } of pluginStatuses) {
        if (isEnabled) {
            if (plugin.routes !== undefined) {
                const basePath = `/api/${plugin.id}`;

                // 認証ミドルウェアの適用
                app.use(`${basePath}/*`, authMiddleware(env.JWT_SECRET));

                if (plugin.requiredRole) {
                    app.use(`${basePath}/*`, rbacMiddleware([plugin.requiredRole]));
                }

                app.route(basePath, plugin.routes);
                console.log(`[Auto-Loader] ✅ Loaded & Mounted Plugin: ${plugin.id}`);
            }
        } else {
            console.log(`[Auto-Loader] ⏸️ Skipped Disabled Plugin: ${plugin.id}`);
        }
    }
}
