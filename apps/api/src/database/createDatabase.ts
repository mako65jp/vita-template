import { DatabaseConfig } from '../systemConfig/SystemConfig';
import { Database } from './Database';
import { InMemoryDatabase } from './InMemoryDatabase';
import { PostgreSqlDatabase } from './PostgreSqlDatabase';
import { SqlServerDatabase } from './SqlServerDatabase';

export async function createDatabase(databaseConfig: DatabaseConfig): Promise<Database> {
    switch (databaseConfig.type) {
        case 'memory':
            return new InMemoryDatabase(databaseConfig.type);

        case 'postgres':
            return new PostgreSqlDatabase(
                databaseConfig.type,
                databaseConfig.connectionString ?? '',
            );
        // return new DrizzleDatabase(config.connectionString ?? '');

        case 'sqlserver':
            return new SqlServerDatabase(
                databaseConfig.type,
                databaseConfig.connectionString ?? '',
            );
        // throw new Error('SQL Server not implemented');

        default:
            throw new Error(`Unknown database type: ${databaseConfig.type}`);
    }
}
