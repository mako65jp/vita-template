import { Database } from '../database/Database';
import { UserRepository } from '../features/user/repositories/UserRepository';
import { UserService } from '../features/user/services/UserService';
import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';

export class DependencyContainer {
    constructor(
        public readonly database: Database,
        public readonly userRepository: UserRepository,
        public readonly userService: UserService,
        public readonly jwtService: JwtService,
        public readonly authenticationService: AuthenticationService,
    ) {}
}
