import path from 'node:path';
import { fileURLToPath } from 'node:url';

/**
 * モノレポのプロジェクトルート（/workspace 等）を安全かつ環境依存なしで取得する
 */
export function getProjectRootDir(): string {
    // ESM 環境での自ファイル位置取得
    const filename = fileURLToPath(import.meta.url);
    const dirname = path.dirname(filename);

    // shared/core/src/utils から見たプロジェクトルートディレクトリを算出
    return path.resolve(dirname, '../../../');
}

/**
 * プロジェクトルートからの相対パスを受け取り、OS依存のない絶対パスを返す
 */
export function resolveFromProjectRoot(...paths: string[]): string {
    return path.resolve(getProjectRootDir(), ...paths);
}

