import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
        alias: {
            '@shared/schemas': path.resolve(import.meta.dirname, '../../shared/schemas'),
        },
    },
    test: {
        globals: true,
        environment: 'jsdom',
        setupFiles: ['../../vitest/setup.ts'],               // ② 各テスト実行前にテーブルデータを全消去
    },
});
