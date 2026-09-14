import { beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('drizzle-orm/node-postgres', () => ({
    drizzle: vi.fn(),
}));

vi.mock('pg', () => ({
    Pool: vi.fn(),
}));

import { drizzle as drizzleNodePg } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';

import { createPool, createProductionDb } from './database';

import * as schema from './schema';

describe('database', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('createPool', () => {
        it('Pool を生成する', () => {
            createPool('postgres://test');

            expect(Pool).toHaveBeenCalledWith({
                connectionString: 'postgres://test',
                max: 20,
            });
        });

        it('空文字もそのまま渡す', () => {
            createPool('');

            expect(Pool).toHaveBeenCalledWith({
                connectionString: '',
                max: 20,
            });
        });
    });

    describe('createProductionDb', () => {
        it('PoolからDrizzle DBを生成する', () => {
            const fakePool = {};

            const fakeDb = {
                transaction: vi.fn(),
            };

            vi.mocked(drizzleNodePg).mockReturnValue(fakeDb as any);

            const result = createProductionDb(fakePool as any);

            expect(drizzleNodePg).toHaveBeenCalledWith(fakePool, {
                schema,
            });

            expect(result).toBe(fakeDb);
        });

        it('drizzle例外を伝播する', () => {
            vi.mocked(drizzleNodePg).mockImplementation(() => {
                throw new Error('drizzle failed');
            });

            expect(() => createProductionDb({} as any)).toThrowError('drizzle failed');
        });
    });
});
