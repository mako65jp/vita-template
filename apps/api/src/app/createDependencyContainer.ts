import { Config } from '../config/Config';
import { createDatabase } from '../database/createDatabase';
import { createAuthenticationProvider } from '../features/authentication/providers/createAuthenticationProvider';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserRepositoryImpl } from '../features/user/repositories/UserRepositoryImpl';
import { UserService } from '../features/user/services/UserService';
import { DependencyContainer } from './DependencyContainer';

export async function createDependencyContainer(config: Config): Promise<DependencyContainer> {
    const database = await createDatabase(config.database);
    const userRepository = new UserRepositoryImpl(database);
    const userService = new UserService(userRepository);
    const jwtService = new JwtService(config.authentication.secret!);
    const authenticationProvider = createAuthenticationProvider(config.authentication, {
        userService,
    });
    const authenticationService = new AuthenticationService(authenticationProvider, jwtService);

    console.log(`createDependencyContainer:`);
    console.log(`  database.type:${database.type}`);
    console.log(`  database.connectionString:${config.database.connectionString}`);
    console.log(`  authentication.type:${config.authentication.type}`);

    return new DependencyContainer(
        config,
        database,
        userRepository,
        userService,
        jwtService,
        authenticationService,
    );
}
