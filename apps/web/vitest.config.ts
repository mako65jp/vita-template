import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
        alias: {
            // エイリアスを直接指定
            '@app/core': path.resolve(import.meta.dirname, '../../packages/core/src'),
            '@app/ui': path.resolve(import.meta.dirname, '../../packages/ui/src'),
        },
    },
    test: {
        environment: 'jsdom',
        globals: true,
        setupFiles: ['./src/test/setup.ts'],
    },
});
