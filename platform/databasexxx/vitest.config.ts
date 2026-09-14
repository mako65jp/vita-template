import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true
    },
    test: {
        globals: true,
        environment: 'node',
        // testTimeout: 10000,
        maxWorkers: '80%',
    },
});
