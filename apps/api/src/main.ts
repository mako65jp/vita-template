import { serve } from '@hono/node-server';
import { createPool, createProductionDb } from '@shared/db';
import { AuthPluginRegistry, env, isTest } from '@shared/functions';
import type { AppServices } from './types';
import { pluginRegistry } from '@shared/plugin';
import { createApp } from './create-app';
import { ActiveDirectoryAuthPlugin } from '@plugins/auth-ad';
import { LocalAuthPlugin } from '@plugins/auth-local';

export async function bootstrap() {
    try {
        // DBインスタンス（ミドルウェア）を注入(本番用のPoolクライアント等を生成して渡す)
        const port = env.PORT || 3001;

        console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);

        // apps/api/src/main.ts の serve 周辺
        console.log(`[API] Server running inside DevContainer on http://0.0.0:${port}`);

        // 💡 呼び出し回数をカウント
        console.count("[DEBUG-COUNT] serveに到達した回数");

        // 💡 2回目に到達した場合だけ、犯人の特定のためにルート履歴（スタックトレース）を出力する
        if ((console as any)._counters && (console as any)._counters["[DEBUG-COUNT] serveに到達した回数"] > 1) {
            console.log("🚨 [CRITICAL] 2回目の起動を検知しました！犯人の経路は以下です：", new Error().stack);
        }

        const pool = createPool(env.DATABASE_URL);
        const dbInstance = createProductionDb(pool);

        // const pluginRegistry = new PluginRegistry();
        // pluginRegistry.register(userPlugin);
        // pluginRegistry.register(customerPlugin);

        // プラグインの登録
        const authRegistry = new AuthPluginRegistry();
        authRegistry.register(new LocalAuthPlugin(dbInstance));
        authRegistry.register(new ActiveDirectoryAuthPlugin());

        const services: AppServices = {
            pluginRegistry,
            authRegistry,
            dbInstance,
        };
        const app = await createApp(services);

        // サーバー起動
        serve({
            fetch: app.fetch,
            port,
            hostname: '0.0.0.0',
        });
    } catch (error) {
        console.error('❌ Failed to bootstrap API server:', error);
    }
}

// テスト環境以外の場合のみサーバーを物理的に起動する
if (!isTest) {
    bootstrap();
}
