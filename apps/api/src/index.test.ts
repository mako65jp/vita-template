import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

describe('API Server Integration Tests', () => {
    const originalEnv = process.env;

    beforeEach(() => {
        // モジュールキャッシュをリセットして、再インポート時にトップレベルのコード（validateEnv）が再実行されるようにする
        vi.resetModules();
        process.env = { ...originalEnv };
    });

    afterEach(() => {
        process.env = originalEnv;
    });

    it('正しい環境変数がセットされている場合、アプリが正常にルーティング応答すること', async () => {
        process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/app_db';
        process.env.PORT = '3001';

        const { default: app } = await import('./index.ts');

        const res = await app.request('/sample');
        expect(res.status).toBe(200);

        const body = await res.json();
        expect(body).toEqual({ message: 'Hello from Auto-Loaded Sample Feature in DevContainer!' });
    });

    it('DATABASE_URL が存在しない場合、エントリポイント実行時に例外をスローすること', async () => {
        delete process.env.DATABASE_URL;

        await expect(async () => {
            await import('./index.ts');
        }).rejects.toThrow('環境変数の検証に失敗しました');
    });
});
