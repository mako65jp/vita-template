import { Database } from '../database/Database';
import { ConfigurationService } from '../features/administration/services/ConfigurationService';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserRepository } from '../features/user/repositories/UserRepository';
import { UserService } from '../features/user/services/UserService';
import { SystemConfig } from '../systemConfig/SystemConfig';

export class DependencyContainer {
    constructor(
        public readonly systemConfig: SystemConfig,
        public readonly database: Database,
        public readonly userRepository: UserRepository,
        public readonly userService: UserService,
        public readonly jwtService: JwtService,
        public readonly authenticationService: AuthenticationService,
        public readonly configurationService: ConfigurationService,
    ) {}
}
