import { defineConfig } from 'vitest/config';

export default defineConfig({
    test: {
        globalSetup: ['./src/test/global-setup.ts'], // ① テスト前に自動で db:push:test
        setupFiles: ['./src/test/setup.ts'],         // ② 各テスト実行前にテーブルデータを全消去
    },
});
