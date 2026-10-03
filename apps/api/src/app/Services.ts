import { AuthenticationService } from '../features/authentication/services/AuthenticationService';
import { JwtService } from '../features/authentication/services/JwtService';
import { UserService } from '../features/user/service';

export interface Services {
    userService: UserService;
    jwtService: JwtService;
    authenticationService: AuthenticationService;
}
