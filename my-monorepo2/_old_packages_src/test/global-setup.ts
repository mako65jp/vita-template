import { execSync } from 'node:child_process';
import path from 'node:path';
import { getProjectRootDir, resolveFromProjectRoot } from '../utils/path';

export async function setup() {
    console.log('\n🔄 テスト用データベースに最新のスキーマを反映中...');

    // 💡 プロジェクトルートを環境に依存せず確実に取得
    const rootDir = getProjectRootDir();

    // shared のルートディレクトリパスを解決
    const corePackageDir = resolveFromProjectRoot('shared');
    const configPath = path.resolve(corePackageDir, 'drizzle-test.config.ts');
    try {
        execSync(`npx drizzle-kit push --config="${configPath}"`, {
            cwd: corePackageDir,
            stdio: 'inherit',
            env: {
                ...process.env, // 親プロセスの環境変数を引き継ぐ
            },
        });
        console.log('✅ テスト用データベースの準備完了!\n');
    } catch (error) {
        console.error('❌ テスト用データベースへのスキーマ反映に失敗しました:', error);
        throw error;
    }
}
