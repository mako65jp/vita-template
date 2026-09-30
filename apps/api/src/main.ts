import { serve } from '@hono/node-server';
import { createApp } from './app/createApp';
import { createDependencyContainer } from './app/createDependencyContainer';
import { loadSystemConfig } from './systemConfig/loadSystemConfig';

import path, { dirname, join } from 'path';
import { fileURLToPath } from 'url';

// 現在のファイルのパスを取得
const __filename: string = fileURLToPath(import.meta.url);
// 現在のファイルが存在するディレクトリのパスを取得
const __dirname: string = dirname(__filename);
// このアプリケーションのRoot
const __root: string = path.resolve(__dirname, '../../../');

// ディレクトリ内にある設定ファイルを読み込む例
const configPath: string = join(__root, 'config/development.json');

const config = await loadSystemConfig(configPath);

const dependencyContainer = await createDependencyContainer(config);
const app = createApp(dependencyContainer);
const port = Number(config.backend.port);

serve({
    fetch: app.fetch,
    port: port,
});

console.log(`Listening on :${port}`);
