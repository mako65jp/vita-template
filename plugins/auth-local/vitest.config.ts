import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        environment: 'node',
        // fileParallelism: false,                 // ファイル間の並列実行を無効化（DBを共有する統合テストで効果的）
        setupFiles: ['../../vitest-clear.ts'],  // 各テスト実行前にテーブルデータを全消去
    },
});
