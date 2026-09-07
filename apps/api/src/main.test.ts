import { beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('@hono/node-server', () => ({
    serve: vi.fn(),
}));

vi.mock('@shared/db', () => ({
    createPool: vi.fn(),
    createProductionDb: vi.fn(),
}));

vi.mock('./create-app', () => ({
    createApp: vi.fn(),
}));

vi.mock('@shared/functions', () => ({
    env: {
        DATABASE_URL:
            'postgresql://postgres:postgres@localhost:5432/app_db',
        PORT: 3001,
    },
    isTest: true,
}));

import { serve } from '@hono/node-server';
import {
    createPool,
    createProductionDb,
} from '@shared/db';
import { createApp } from './create-app';

import { bootstrap } from './main';

describe('API Bootstrap', () => {
    beforeEach(() => {
        vi.clearAllMocks();

        vi.spyOn(console, 'log')
            .mockImplementation(() => { });

        vi.spyOn(console, 'count')
            .mockImplementation(() => { });

        vi.spyOn(console, 'error')
            .mockImplementation(() => { });
    });

    it('Pool・DB・Appを生成してserveする', async () => {
        const mockPool = {};
        const mockDb = {};

        const mockApp = {
            fetch: vi.fn(),
        };

        vi.mocked(createPool)
            .mockReturnValue(mockPool as any);

        vi.mocked(createProductionDb)
            .mockReturnValue(mockDb as any);

        vi.mocked(createApp)
            .mockResolvedValue(mockApp as any);

        await bootstrap();

        expect(createPool).toHaveBeenCalledWith(
            'postgresql://postgres:postgres@localhost:5432/app_db',
        );

        expect(createProductionDb)
            .toHaveBeenCalledWith(mockPool);

        expect(createApp)
            .toHaveBeenCalledWith(mockDb);

        expect(serve).toHaveBeenCalledTimes(1);

        expect(serve).toHaveBeenCalledWith({
            fetch: mockApp.fetch,
            port: 3001,
            hostname: '0.0.0.0',
        });
    });

    it('PORT が falsy の場合は 3001 を使用する', async () => {
        const mockPool = {};
        const mockDb = {};

        const mockApp = {
            fetch: vi.fn(),
        };

        vi.mocked(createPool)
            .mockReturnValue(mockPool as any);

        vi.mocked(createProductionDb)
            .mockReturnValue(mockDb as any);

        vi.mocked(createApp)
            .mockResolvedValue(mockApp as any);

        const functionsModule =
            await import('@shared/functions');

        (functionsModule.env as any).PORT = 0;

        await bootstrap();

        expect(serve).toHaveBeenCalledWith({
            fetch: mockApp.fetch,
            port: 3001,
            hostname: '0.0.0.0',
        });
    });

    it('createPool が失敗した場合はエラーログを出力する', async () => {
        const error = new Error(
            'createPool failed',
        );

        vi.mocked(createPool)
            .mockImplementation(() => {
                throw error;
            });

        await bootstrap();

        expect(console.error)
            .toHaveBeenCalledWith(
                '❌ Failed to bootstrap API server:',
                error,
            );

        expect(serve).not.toHaveBeenCalled();
    });

    it('createProductionDb が失敗した場合はエラーログを出力する', async () => {
        const error = new Error(
            'createProductionDb failed',
        );

        vi.mocked(createPool)
            .mockReturnValue({} as any);

        vi.mocked(createProductionDb)
            .mockImplementation(() => {
                throw error;
            });

        await bootstrap();

        expect(console.error)
            .toHaveBeenCalledWith(
                '❌ Failed to bootstrap API server:',
                error,
            );

        expect(serve).not.toHaveBeenCalled();
    });

    it('createApp が失敗した場合はエラーログを出力する', async () => {
        const error = new Error(
            'createApp failed',
        );

        vi.mocked(createPool)
            .mockReturnValue({} as any);

        vi.mocked(createProductionDb)
            .mockReturnValue({} as any);

        vi.mocked(createApp)
            .mockRejectedValue(error);

        await bootstrap();

        expect(console.error)
            .toHaveBeenCalledWith(
                '❌ Failed to bootstrap API server:',
                error,
            );

        expect(serve).not.toHaveBeenCalled();
    });

    it('serve 到達ログを出力する', async () => {
        const logSpy = vi.spyOn(console, 'log');

        vi.mocked(createPool)
            .mockReturnValue({} as any);

        vi.mocked(createProductionDb)
            .mockReturnValue({} as any);

        vi.mocked(createApp)
            .mockResolvedValue({
                fetch: vi.fn(),
            } as any);

        await bootstrap();

        expect(logSpy).toHaveBeenCalled();
    });

    it('serve 到達回数をカウントする', async () => {
        const countSpy =
            vi.spyOn(console, 'count');

        vi.mocked(createPool)
            .mockReturnValue({} as any);

        vi.mocked(createProductionDb)
            .mockReturnValue({} as any);

        vi.mocked(createApp)
            .mockResolvedValue({
                fetch: vi.fn(),
            } as any);

        await bootstrap();

        expect(countSpy)
            .toHaveBeenCalledWith(
                '[DEBUG-COUNT] serveに到達した回数',
            );
    });
});

