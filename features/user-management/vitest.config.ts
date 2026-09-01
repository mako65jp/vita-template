import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true
    },
    build: {
        // ソースマップを有効化
        sourcemap: true,
    },
    test: {
        globals: true,
        environment: 'jsdom',
        // testTimeout: 10000,
        maxWorkers: '60%',
        // fileParallelism: false,                 // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['./vitest-setup.ts'],
    },
});
