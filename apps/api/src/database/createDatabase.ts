import { DatabaseConfig } from '../config/Config';
import { Database } from './Database';
import { InMemoryDatabase } from './InMemoryDatabase';
import { PostgreSqlDatabase } from './PostgreSqlDatabase';
import { SqlServerDatabase } from './SqlServerDatabase';

export async function createDatabase(config: DatabaseConfig): Promise<Database> {
    switch (config.type) {
        case 'memory':
            return new InMemoryDatabase(config.type);

        case 'postgres':
            return new PostgreSqlDatabase(config.type, config.connectionString ?? '');
        // return new DrizzleDatabase(config.connectionString ?? '');

        case 'sqlserver':
            return new SqlServerDatabase(config.type, config.connectionString ?? '');
        // throw new Error('SQL Server not implemented');

        default:
            throw new Error(`Unknown database type: ${config.type}`);
    }
}
