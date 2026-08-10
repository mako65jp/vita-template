import { defineConfig } from 'vitest/config';

export default defineConfig({
  resolve: {
    tsconfigPaths: true
  },
  test: {
    globals: true,
    reporters: ['tree'],

    projects: [
      'packages/*',
      'apps/api',
      'apps/web/vitest.config.ts',
    ],

    // 除外するファイル/フォルダ
    exclude: ['node_modules', 'dist', '.next', 'coverage'],

    coverage: {
      provider: 'v8', // or 'istanbul'
      include: ['**/*.{ts,tsx}']
    },

  },
});
