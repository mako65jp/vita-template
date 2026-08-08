import { defineConfig } from 'vitest/config';
import path from 'path';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
        alias: {
            '@app/core': path.resolve(import.meta.dirname, '../../packages/core/src/index.ts'),
        },
    },
    test: {
        globals: true,
        environment: 'node',
    },
});
