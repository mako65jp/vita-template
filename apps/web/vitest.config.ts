import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
        alias: {
            // エイリアスを直接指定
            '@app/core': path.resolve(import.meta.dirname, '../../packages/core/src/index.ts'),
        },
    },
    test: {
        environment: 'jsdom',
        globals: true,
        setupFiles: ['./src/test/setup.ts'],
        server: {
            deps: {
                // パッケージをインライン処理に指定
                inline: ['@app/core'],
            },
        },
    },
});

// import { defineConfig, mergeConfig } from 'vitest/config';
// import path from 'path';

// export default defineConfig(async (configEnv) => {

//     // 拡張子 .ts を明示し、関数の内部で動的インポート
//     const viteConfigModule = await import('./vite.config.ts');
//     const viteConfig = viteConfigModule.default;

//     // vite.config が関数の場合でも正しく評価してオブジェクトを取得
//     const baseConfig = typeof viteConfig === 'function' ? viteConfig(configEnv) : viteConfig;

//     return mergeConfig(
//         baseConfig,
//         defineConfig({
//             resolve: {
//                 tsconfigPaths: true,
//                 alias: {
//                     '@app/core': path.resolve(import.meta.dirname, '../../packages/core/src/index.ts'),
//                 },
//             },
//             test: {
//                 environment: 'jsdom', // 👈 ここを追加（すべてのテストで jsdom / DOM API を有効化）
//                 globals: true,        // describe, it, expect などをグローバル化する場合
//                 setupFiles: ['./src/test/setup.ts'],
//                 server: {
//                     deps: {
//                         inline: ['@app/core'],
//                     },
//                 },
//             },
//         })
//     );
// });
