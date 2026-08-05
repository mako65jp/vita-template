import { defineConfig, mergeConfig } from 'vitest/config';
import viteConfig from './vite.config';

export default defineConfig(async (configEnv) => {
    // vite.config が関数の場合でも正しく評価してオブジェクトを取得
    const baseConfig = typeof viteConfig === 'function' ? viteConfig(configEnv) : viteConfig;

    return mergeConfig(
        baseConfig,
        defineConfig({
            test: {
                environment: 'jsdom', // 👈 ここを追加（すべてのテストで jsdom / DOM API を有効化）
                globals: true,        // describe, it, expect などをグローバル化する場合
                setupFiles: ['./src/test/setup.ts'],
            },
        })
    );
});
