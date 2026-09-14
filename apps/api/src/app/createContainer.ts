import { Config } from '../config/Config';
import { createDatabase } from '../database/createDatabase';
import { DependencyContainer } from './DependencyContainer';
import { UserRepositoryImpl } from '../features/user/repositories/UserRepositoryImpl';
import { UserService } from '../features/user/services/UserService';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';

export async function createContainer(config: Config): Promise<DependencyContainer> {
    const database = await createDatabase(config.database);

    const userRepository = new UserRepositoryImpl(database);

    const userService = new UserService(userRepository);

    const jwtService = new JwtService(config.authentication.secret ?? 'change-this-secret');

    const authenticationService = new AuthenticationService(userService, jwtService);

    return new DependencyContainer(
        database,
        userRepository,
        userService,
        jwtService,
        authenticationService,
    );
}
