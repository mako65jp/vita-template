import { createAuthenticationProvider } from '../features/authentication/providers/createAuthenticationProvider';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserService } from '../features/user/service';
import { SystemConfig } from '../systemConfig/SystemConfig';
import { Repositories } from './Repositories';
import { Services } from './Services';

export function createServices(dependencies: {
    repositories: Repositories;
    systemConfig: SystemConfig;
}): Services {
    const userService = new UserService(dependencies.repositories.userRepository);

    const jwtService = new JwtService(dependencies.systemConfig.authentication.secret!);

    const authenticationProvider = createAuthenticationProvider(
        dependencies.systemConfig.authentication,
        { userService },
    );

    const authenticationService = new AuthenticationService(authenticationProvider, jwtService);

    return {
        userService,
        jwtService,
        authenticationService,
    };
}
