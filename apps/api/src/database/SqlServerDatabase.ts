import { DrizzleDatabase } from './DrizzleDatabase';

export class SqlServerDatabase extends DrizzleDatabase {
    constructor(type: string, connectionString: string) {
        super(type, connectionString ?? '');
        console.log('SQL Server selected');
    }
}
