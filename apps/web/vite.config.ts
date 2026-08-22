import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import path from 'path';

export default defineConfig(({ mode }) => {
    // 環境変数が置かれているルートディレクトリのパス
    const envDir = path.resolve(import.meta.dirname, '../../');

    // Vite 組み込みの loadEnv で .env ファイルをロード
    // 第3引数を '' に指定すると VITE_ 以外の環境変数も取得可能
    const env = loadEnv(mode, envDir, '');

    const webPort = Number(env.VITE_PORT);
    const apiTarget = env.VITE_API_TARGET_URL;

    return {
        envDir,
        plugins: [react(), tailwindcss()],
        resolve: {
            tsconfigPaths: true,
            alias: {
                '@shared/client': path.resolve(import.meta.dirname, '../../shared/client'),
                '@features-user-management': path.resolve(import.meta.dirname, '../../features/user-management/src'),
            },
        },
        server: {
            port: webPort,
            host: true,
            proxy: {
                '/api': {
                    target: apiTarget,
                    changeOrigin: true,
                },
            },
        },
    };
});
