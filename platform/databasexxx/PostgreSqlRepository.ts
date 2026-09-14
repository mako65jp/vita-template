import type { Repository } from './Repository';

export class PostgreSqlRepository implements Repository {
    constructor(
        private readonly connectionString: string,
    ) { }

    findById<TEntity>(id: string): TEntity | null {
        throw new Error('Not implemented');
    }

    findAll<TEntity>(): TEntity[] {
        throw new Error('Not implemented');
    }

    save<TEntity>(entity: TEntity): void {
        throw new Error('Not implemented');
    }

    update<TEntity>(entity: TEntity): void {
        throw new Error('Not implemented');
    }

    remove<TEntity>(id: string): void {
        throw new Error('Not implemented');
    }
}
