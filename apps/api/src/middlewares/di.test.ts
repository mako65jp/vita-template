import { describe, it, expect, vi } from 'vitest';
import { Hono } from 'hono';
import { diMiddleware } from './di';
import { PgDatabase } from 'drizzle-orm/pg-core';
import type { Database } from '@shared/db';

describe('diMiddleware', () => {
    it('1. Hono のコンテキスト（c.set）に、渡された Database インスタンスが正しく注入されること', async () => {
        // 💡 厳密な型安全性を維持するため、緩い any ではなく
        // Drizzle の PgDatabase 基底クラスのシグネチャを満たす最小限のモックオブジェクトを作成します。
        const mockDb = {
            select: vi.fn(),
            insert: vi.fn(),
            update: vi.fn(),
            delete: vi.fn(),
        } as unknown as Database;

        // 検証用のプレーンな Hono インスタンスを作成
        const app = new Hono();

        // テスト対象のミドルウェアを適用
        app.use('*', diMiddleware(mockDb));

        // ミドルウェアを通過した後に、コンテキストから正しく 'dbInstance' が取り出せるかを検証するルート
        app.get('/test-di', (c) => {
            const injectedDb = c.get('dbInstance' as any);

            // 注入されたインスタンスの実体が、渡したものと完全に同一（参照一致）であることを確認
            expect(injectedDb).toBe(mockDb);

            return c.json({ success: true });
        });

        // ダミーのリクエストを発行（WASM や実際のポート開放を伴わないため、ミリ秒で安全に並行実行されます）
        const res = await app.request('/test-di');

        expect(res.status).toBe(200);
        const body = await res.json();
        expect(body).toEqual({ success: true });
    });

    it('2. ミドルウェアが処理を正しくフックし、次の処理（next）へ制御を移譲すること', async () => {
        const mockDb = {} as unknown as Database;
        const app = new Hono();

        let isNextCalled = false;

        // ミドルウェアの後に確実に処理が継続しているかを検証するフラグ制御
        app.use('*', diMiddleware(mockDb));
        app.use('*', async (c, next) => {
            isNextCalled = true;
            await next();
        });

        app.get('/test-next', (c) => c.text('ok'));

        const res = await app.request('/test-next');
        expect(res.status).toBe(200);
        // 💡 制御が数珠繋ぎで次のミドルウェア/ハンドラーへ渡っていることを厳密に検証
        expect(isNextCalled).toBe(true);
    });
});
