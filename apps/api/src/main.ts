import { serve } from '@hono/node-server';

import { createApp } from './app/createApp';
import { createDependencyContainer } from './app/createDependencyContainer';
import { loadSystemConfig } from './systemConfig/loadSystemConfig';
import { resolveConfigPath } from './systemConfig/resolveConfigPath';

/**
 * アプリケーションを起動する。
 *
 * 起動手順:
 *   1. 設定ファイルを読み込む
 *   2. DI Container を構築する
 *   3. Hono Application を生成する
 *   4. HTTP Server を起動する
 */
async function bootstrap(): Promise<void> {
    // 実行環境に応じた設定ファイルを読み込む。
    const config = await loadSystemConfig(resolveConfigPath());

    // Repository / Service などの依存オブジェクトを構築する。
    const dependencyContainer = await createDependencyContainer(config);

    // Hono Application を生成する。
    const app = createApp(dependencyContainer);

    // HTTP Server を起動する。
    const port = Number(config.backend.port);
    serve({
        fetch: app.fetch,
        port,
    });

    console.log(`Listening on :${port}`);
}

// アプリケーションを起動する。
await bootstrap();
