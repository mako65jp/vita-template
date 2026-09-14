import { Database } from './Database';

export class PostgreSqlDatabase implements Database {
    constructor() {
        console.log('PostgreSQL selected');
    }

    async query<T>() {
        return [] as T[];
    }

    async execute() {
        return 0;
    }

    async beginTransaction() {}

    async commit() {}

    async rollback() {}
}
