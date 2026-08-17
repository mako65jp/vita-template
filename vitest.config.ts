import { defineConfig, defineProject } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
        alias: [
            // @app/core/config/env を packages/core/src/config/env.ts にマッピング
            {
                find: '@app/core/config/env',
                replacement: path.resolve(import.meta.dirname, 'packages/core/src/config/env.ts'),
            },
            // @app/core/db を packages/core/src/db/index.ts に正確にマッピング
            {
                find: '@app/core/db',
                replacement: path.resolve(import.meta.dirname, 'packages/core/src/db/index.ts'),
            },
            // @app/core 単体を packages/core/src/index.ts にマッピング
            {
                find: '@app/core',
                replacement: path.resolve(import.meta.dirname, 'packages/core/src/index.ts'),
            },
        ],
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
            provider: 'v8', // or 'istanbul'
            include: ['**/*.{ts,tsx}'],
            exclude: [
                'dev/**/*',
                'test/**/*',
            ],
        },

    },
});
