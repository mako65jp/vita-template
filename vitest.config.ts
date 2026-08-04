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
  },
});
