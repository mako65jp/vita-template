import { defineConfig } from 'vitest/config';
import { loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig(({ mode }) => {
    // モノレポのルート直下（../../）にある .env ファイルをロード
    const envDir = path.resolve(import.meta.dirname, '../../');
    const env = loadEnv(mode, envDir, '');

    // ポート番号やプロキシ先を環境変数から取得（フォールバック付き）
    const webPort = parseInt(env.VITE_PORT || '3000', 10);
    const apiTarget = env.VITE_API_TARGET_URL || 'http://127.0.0.1:3001';

    return {
        // Vite が .env ファイルを探すディレクトリを指定
        envDir,

        plugins: [react()],
        resolve: {
            tsconfigPaths: true
        },

        server: {
            host: '0.0.0.0',
            port: webPort,
            proxy: {
                '/api': apiTarget,
                '/sample': apiTarget,
            },
        },

        test: {
            environment: 'jsdom', // 👈 ここを追加（すべてのテストで jsdom / DOM API を有効化）
            globals: true,        // describe, it, expect などをグローバル化する場合
            setupFiles: ['./src/test/setup.ts'],
        },
    };
});
