import { serve } from '@hono/node-server';
import { createProductionDb } from '@shared/db';
import { env, isTest } from '@shared/functions';
import { createApp } from './index'; // 💡 index.ts から関数をインポート

async function bootstrap() {
    try {
        // DBインスタンス（ミドルウェア）を注入(本番用のPoolクライアント等を生成して渡す)
        const db = createProductionDb(env.DATABASE_URL);    //createDb('pg');
        const app = await createApp(db);
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
