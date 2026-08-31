import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'jsdom',
        // fileParallelism: false,                 // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['./vitest-setup.ts'],      // 各テスト実行前にテーブルデータを全消去
    },
});
