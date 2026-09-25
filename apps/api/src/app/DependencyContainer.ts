import { Config } from '../config/Config';
import { Database } from '../database/Database';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserRepository } from '../features/user/repositories/UserRepository';
import { UserService } from '../features/user/services/UserService';

export class DependencyContainer {
    constructor(
        public readonly config: Config,
        public readonly database: Database,
        public readonly userRepository: UserRepository,
        public readonly userService: UserService,
        public readonly jwtService: JwtService,
        public readonly authenticationService: AuthenticationService,
    ) {}
}
