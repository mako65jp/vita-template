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
                '@app/core': path.resolve(import.meta.dirname, '../../packages/core/src/index.ts'),
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
                '/sample': {
                    target: apiTarget,
                    changeOrigin: true,
                },
            },
        },
    };
});

// import { defineConfig } from 'vitest/config';
// import react from '@vitejs/plugin-react';
// import tailwindcss from '@tailwindcss/vite';
// import path from 'path';

// export default defineConfig(async () => {

//     // 👇 関数の内部で @app/core を動的インポート（これで Vite のエイリアスが適用されます）
//     const { clientEnv } = await import('@app/core');

//     // Vite が .env ファイルを探すディレクトリを指定
//     const envDir = path.resolve(import.meta.dirname, '../../');

//     // ポート番号やプロキシ先を環境変数から取得（フォールバック付き）
//     const webPort = clientEnv.VITE_PORT;
//     const apiTarget = clientEnv.VITE_API_TARGET_URL;

//     return {
//         envDir,

//         plugins: [react(), tailwindcss()],
//         resolve: {
//             tsconfigPaths: true,
//             alias: {
//                 '@app/core': path.resolve(import.meta.dirname, '../../packages/core/src/index.ts'),
//             },
//         },
//         server: {
//             deps: {
//                 inline: ['@app/core'],
//             },
//             port: webPort,
//             host: true,
//             proxy: {
//                 '/api': {
//                     target: apiTarget,
//                     changeOrigin: true,
//                 },
//                 '/sample': {
//                     target: apiTarget,
//                     changeOrigin: true,
//                 },
//             },
//         },
//     };
// });

// // import { defineConfig } from 'vitest/config';
// // import { loadEnv } from 'vite';
// // import react from '@vitejs/plugin-react';
// // import tailwindcss from '@tailwindcss/vite';
// // import path from 'path';

// // export default defineConfig(({ mode }) => {
// //     // モノレポのルート直下（../../）にある .env ファイルをロード
// //     const envDir = path.resolve(import.meta.dirname, '../../');
// //     const env = loadEnv(mode, envDir, '');

// //     // ポート番号やプロキシ先を環境変数から取得（フォールバック付き）
// //     const webPort = parseInt(env.VITE_PORT || '3000', 10);
// //     const apiTarget = env.VITE_API_TARGET_URL || 'http://127.0.0.1:3001';

// //     return {
// //         // Vite が .env ファイルを探すディレクトリを指定
// //         envDir,

// //         plugins: [react(), tailwindcss()],
// //         resolve: {
// //             tsconfigPaths: true
// //         },

// //         server: {
// //             host: true,
// //             port: webPort,
// //             proxy: {
// //                 '/api': apiTarget,
// //                 '/sample': apiTarget,
// //             },
// //         },
// //     };
// // });
