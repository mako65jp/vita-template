// import path, { dirname, join } from 'path';
// import { fileURLToPath } from 'url';

// export function resolveConfigPath(): string {
//     const filename = fileURLToPath(import.meta.url);
//     const currentDirectory = dirname(filename);
//     const applicationRoot = path.resolve(currentDirectory, '../../../');
//     return join(applicationRoot, 'config/development.json');
// }

import path, { dirname, join } from 'path';
import { fileURLToPath } from 'url';

/**
 * 設定ファイルの絶対パスを取得する。
 *
 * config/
 * development.json
 * test.json
 * staging.json
 * production.json
 *
 * の配置を前提とする。
 */
export function resolveConfigPath(): string {
    const environment = resolveEnvironment();
    const filename = fileURLToPath(import.meta.url);
    const currentDirectory = dirname(filename);

    // src 配下からアプリケーションルートへ移動する。
    const applicationRoot = path.resolve(currentDirectory, '../../../../');

    return join(applicationRoot, 'config', `${environment}.json`);
}

/**
 * 実行環境名を取得する。
 *
 * 未指定時は development を使用する。
 */
function resolveEnvironment(): string {
    return process.env.NODE_ENV ?? 'development';
}
