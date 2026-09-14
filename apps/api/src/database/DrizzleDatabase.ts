import { Pool } from 'pg';

import { Database } from './Database';

export class DrizzleDatabase implements Database {
    private readonly pool: Pool;

    constructor(connectionString: string) {
        this.pool = new Pool({
            connectionString,
        });
    }

    async query<T>(sql: string, params: readonly unknown[] = []): Promise<T[]> {
        const result = await this.pool.query(sql, [...params]);

        return result.rows as T[];
    }

    async execute(sql: string, params: readonly unknown[] = []): Promise<number> {
        const result = await this.pool.query(sql, [...params]);

        return result.rowCount ?? 0;
    }

    async beginTransaction() {
        await this.pool.query('BEGIN');
    }

    async commit() {
        await this.pool.query('COMMIT');
    }

    async rollback() {
        await this.pool.query('ROLLBACK');
    }
}
