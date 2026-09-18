import { DatabaseConfig } from '../config/Config';
import { Database } from './Database';
import { DrizzleDatabase } from './DrizzleDatabase';
import { InMemoryDatabase } from './InMemoryDatabase';

export async function createDatabase(config: DatabaseConfig): Promise<Database> {
    switch (config.type) {
        case 'memory':
            return new InMemoryDatabase();

        case 'postgres':
            return new DrizzleDatabase(config.connectionString ?? '');

        case 'sqlserver':
            throw new Error('SQL Server not implemented');

        default:
            throw new Error(`Unknown database type: ${config.type}`);
    }
}
