import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        reporters: ['tree'],

        // パッケージのディレクトリパスを指定（設定ファイルのパスではなくディレクトリを指定するのが正しい仕様）
        projects: [
            'apps/api',
            'apps/web',
            'packages/core',
            'packages/ui',
            'packages/features/*',
        ],
        exclude: ['node_modules', 'dist', '.next', 'coverage'],
        coverage: {
            provider: 'v8',
            include: ['**/*.{ts,tsx}'],
            exclude: ['dev/**/*', 'test/**/*'],
        },
    },
});
