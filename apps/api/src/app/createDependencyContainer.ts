import { createAuthenticationProvider } from '../features/authentication/providers/createAuthenticationProvider';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserService } from '../features/user/service';
import { createRepositories } from '../repositories/createRepositories';
import { SystemConfig } from '../systemConfig/SystemConfig';
import { DependencyContainer } from './DependencyContainer';

export async function createDependencyContainer(
    systemConfig: SystemConfig,
): Promise<DependencyContainer> {
    const repositories = await createRepositories(systemConfig.database);
    const userService = new UserService(repositories.userRepository);
    const jwtService = new JwtService(systemConfig.authentication.secret!);
    const authenticationProvider = createAuthenticationProvider(systemConfig.authentication, {
        userService,
    });

    const authenticationService = new AuthenticationService(authenticationProvider, jwtService);

    return new DependencyContainer(
        systemConfig,
        repositories,
        userService,
        jwtService,
        authenticationService,
    );
}
