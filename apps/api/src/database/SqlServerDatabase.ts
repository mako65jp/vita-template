import { Database } from './Database';

export class SqlServerDatabase implements Database {
    constructor() {
        console.log('SQL Server selected');
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
