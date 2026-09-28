import { DrizzleDatabase } from './DrizzleDatabase';

export class PostgreSqlDatabase extends DrizzleDatabase {
    constructor(type: string, connectionString: string) {
        super(type, connectionString ?? '');
        console.log(`PostgreSQL selected.`);
    }
}
