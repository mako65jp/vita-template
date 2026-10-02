import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserService } from '../features/user/service';
import type { Repositories } from '../repositories/Repositories';
import type { SystemConfig } from '../systemConfig/SystemConfig';

export class DependencyContainer {
    constructor(
        public readonly systemConfig: SystemConfig,
        public readonly repositories: Repositories,
        public readonly userService: UserService,
        public readonly jwtService: JwtService,
        public readonly authenticationService: AuthenticationService,
    ) {}
}
