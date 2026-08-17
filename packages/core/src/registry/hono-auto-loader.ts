import { Hono } from 'hono';
import { glob } from 'glob';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { db } from '../db';
import { plugins as pluginsTable } from '../db/schema';
import { PluginRegistry } from '../plugins/registry';

//
// packages/features/*/src/index.ts から機能モジュールを自動読み込みし、
// DB 上で有効（enabled: true）なプラグインのみを Hono アプリへマウントする関数
//
export async function loadFeatureModules(app: Hono, pattern: string) {
    const files = await glob(pattern);

    // 1. 各機能モジュールを動的インポート
    // (各モジュールの内部で PluginRegistry.register() が実行される)
    for (const file of files) {
        const absolutePath = path.resolve(file);
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
        // DB に未登録の場合はデフォルトで有効 (true) と判定
        const isEnabled = dbPluginsMap.has(plugin.id)
            ? dbPluginsMap.get(plugin.id)
            : true;

        if (isEnabled) {
            // API パス: /api/{plugin-id} 配下にマウント
            app.route(`/api/${plugin.id}`, plugin.routes);
            console.log(`[Auto-Loader] ✅ Loaded & Mounted Plugin: ${plugin.id}`);
        } else {
            console.log(`[Auto-Loader] ⏸️ Skipped Disabled Plugin: ${plugin.id}`);
        }
    }
}
