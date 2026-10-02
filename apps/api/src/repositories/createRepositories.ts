import { MemoryUserRepository } from '../infrastructure/memory/user-repository';
import { createPostgresDb } from '../infrastructure/postgres/db';
import { PostgresUserRepository } from '../infrastructure/postgres/user-repository';
import { createSqlServerDb } from '../infrastructure/sqlserver/db';
import { SqlServerUserRepository } from '../infrastructure/sqlserver/user-repository';
import type { DatabaseConfig } from '../systemConfig/SystemConfig';
import type { Repositories } from './Repositories';

export async function createRepositories(config: DatabaseConfig): Promise<Repositories> {
    switch (config.type) {
        case 'memory': {
            return {
                userRepository: new MemoryUserRepository(),
            };
        }

        case 'postgres': {
            const db = createPostgresDb(config.connectionString!);

            return {
                userRepository: new PostgresUserRepository(db),
            };
        }

        case 'sqlserver': {
            const db = await createSqlServerDb(config.connectionString!);

            return {
                userRepository: new SqlServerUserRepository(db),
            };
        }

        default: {
            throw new Error(`Unsupported database type: ${config.type}`);
        }
    }
}
