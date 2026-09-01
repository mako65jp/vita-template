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
        // testTimeout: 10000,
        maxWorkers: '60%',
    },
});
