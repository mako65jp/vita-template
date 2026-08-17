import { execSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// import.meta.url から安全にパスを抽出
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function setup() {
    console.log('\n🔄 テスト用データベースに最新のスキーマを反映中...');

    // packages/core のルートディレクトリパスを解決
    const corePackageDir = path.resolve(__dirname, '../../../../core');
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
