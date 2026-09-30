import { createDatabase } from '../database/createDatabase';
import { ConfigurationRepositoryImpl } from '../features/administration/repositories/ConfigurationRepositoryImpl';
import { ConfigurationService } from '../features/administration/services/ConfigurationService';
import { createAuthenticationProvider } from '../features/authentication/providers/createAuthenticationProvider';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserRepositoryImpl } from '../features/user/repositories/UserRepositoryImpl';
import { UserService } from '../features/user/services/UserService';
import { SystemConfig } from '../systemConfig/SystemConfig';
import { DependencyContainer } from './DependencyContainer';

export async function createDependencyContainer(
    systemConfig: SystemConfig,
): Promise<DependencyContainer> {
    const database = await createDatabase(systemConfig.database);
    const userRepository = new UserRepositoryImpl(database);
    const userService = new UserService(userRepository);
    const jwtService = new JwtService(systemConfig.authentication.secret!);
    const authenticationProvider = createAuthenticationProvider(systemConfig.authentication, {
        userService,
    });
    const authenticationService = new AuthenticationService(authenticationProvider, jwtService);
    const configurationRepository = new ConfigurationRepositoryImpl(database);
    const configurationService = new ConfigurationService(configurationRepository);

    console.log(`createDependencyContainer:`);
    console.log(`  database.type:${database.type}`);
    console.log(`  database.connectionString:${systemConfig.database.connectionString}`);
    console.log(`  authentication.type:${systemConfig.authentication.type}`);

    return new DependencyContainer(
        systemConfig,
        database,
        userRepository,
        userService,
        jwtService,
        authenticationService,
        configurationService,
    );
}
