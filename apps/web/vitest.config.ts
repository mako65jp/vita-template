import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    resolve: {
        tsconfigPaths: true,
        alias: {
            // エイリアスを直接指定
            '@app/ui': path.resolve(import.meta.dirname, '../../packages/ui/src'),
            '@app/features/user-management': path.resolve(import.meta.dirname, '../../packages/features/user-management/src'),
        },
    },
    test: {
        globals: true,
        environment: 'jsdom',
        setupFiles: ['./src/test/setup.ts'],
    },
});
