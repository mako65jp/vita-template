import { Database } from './Database';

import { User } from '../features/user/domain/User';

export class InMemoryDatabase implements Database {
    private readonly users = new Map<number, User>();

    constructor() {
        this.users.set(
            1,
            new User(
                1,
                '管理者ユーザー',
                'admin@example.com',
                '$2b$10$ua0BmFk7UYjnOn4E4nUGnOMfg5EnEpZElCZVh7AvbmbFimC2pmbs2',
                'admin',
                true,
                new Date('2026-08-25T08:35:15.972'),
            ),
        );

        this.users.set(
            7,
            new User(
                7,
                '一般ユーザー',
                'user1@example.com',
                '$2b$10$IAwpKAPfwW0mEBU6.g.dmO5aP9SfAeUIeKENok6Wk2AGua4f0pOZO',
                'user',
                true,
                new Date('2026-08-27T04:36:46.357'),
            ),
        );
    }

    async query<T>(sql: string, params: readonly unknown[] = []): Promise<T[]> {
        switch (sql) {
            case 'users': {
                const id = Number(params[0]);

                const user = this.users.get(id);

                return user ? [user as T] : [];
            }

            default:
                return [];
        }
    }

    async execute(_sql: string, _params: readonly unknown[] = []): Promise<number> {
        return 0;
    }

    async beginTransaction() {}

    async commit() {}

    async rollback() {}
}
