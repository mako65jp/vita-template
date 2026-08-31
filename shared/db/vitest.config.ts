import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        setupFiles: ['../../vitest-clear.ts'],               // ② 各テスト実行前にテーブルデータを全消去
    },
});
