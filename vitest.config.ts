import { defineConfig } from 'vitest/config';

export default defineConfig({
    resolve: {
        tsconfigPaths: true,
    },
    test: {
        globals: true,
        reporters: ['tree'],

        // ディレクトリではなく「vitest.config.ts を持つファイル」をワイルドカードで直接指定する
        projects: [
            'apps/*/vitest.config.ts',
            'features/*/vitest.config.ts',
            'shared/*/vitest.config.ts',
            'plugins/*/vitest.config.ts'
        ],

        exclude: ['node_modules', 'dist', '.next', 'coverage'],

        coverage: {
            provider: 'v8',
            include: ['**/*.{ts,tsx}'],
            exclude: ['test/**/*'],
        },
    },
});
