import { createAuthenticationProvider } from '../features/authentication/providers/createAuthenticationProvider';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';

import { UserService } from '../features/user/service';

import { DependencyContainer } from './DependencyContainer';

import { SystemConfig } from '../systemConfig/SystemConfig';

import { UserRepository } from '../repositories/user-repository';

import { MemoryUserRepository } from '../infrastructure/memory/user-repository';

import { createPostgresDb } from '../infrastructure/postgres/db';
import { PostgresUserRepository } from '../infrastructure/postgres/user-repository';

export async function createDependencyContainer(
    systemConfig: SystemConfig,
): Promise<DependencyContainer> {
    let userRepository: UserRepository;

    switch (systemConfig.database.type) {
        case 'postgres': {
            const db = createPostgresDb(systemConfig.database.connectionString!);
            userRepository = new PostgresUserRepository(db);
            break;
        }

        case 'memory': {
            userRepository = new MemoryUserRepository();
            break;
        }

        case 'sqlserver': {
            throw new Error('sqlserver not implemented');
        }

        default: {
            throw new Error(`Unsupported database type: ${systemConfig.database.type}`);
        }
    }

    const userService = new UserService(userRepository);

    const jwtService = new JwtService(systemConfig.authentication.secret!);
    const authenticationProvider = createAuthenticationProvider(systemConfig.authentication, {
        userService,
    });
    const authenticationService = new AuthenticationService(authenticationProvider, jwtService);

    // const configurationRepository = new ConfigurationRepositoryImpl();
    // const configurationService = new ConfigurationService(configurationRepository);

    console.log(`createDependencyContainer:`);
    console.log(`  database.type:${systemConfig.database.type}`);
    console.log(`  database.connectionString:${systemConfig.database.connectionString}`);
    console.log(`  authentication.type:${systemConfig.authentication.type}`);

    return new DependencyContainer(
        systemConfig,
        userRepository,
        userService,
        jwtService,
        authenticationService,
    );
}
