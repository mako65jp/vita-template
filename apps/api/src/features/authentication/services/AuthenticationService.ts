import { AuthenticationProvider } from '../providers/AuthenticationProvider';
import { JwtService } from './JwtService';

export class AuthenticationService {
    constructor(
        private readonly provider: AuthenticationProvider,
        private readonly jwtService: JwtService,
    ) {}

    async login(username: string, password: string) {
        const principal = await this.provider.authenticate(username, password);

        if (!principal) {
            return undefined;
        }

        return {
            accessToken: this.jwtService.createAccessToken(principal),
            expiresIn: this.jwtService.expiresInSeconds,
        };
    }
}

// import bcrypt from 'bcrypt';
// import { UserService } from '../../user/services/UserService';
// import { JwtService } from './JwtService';

// export class AuthenticationService {
//     constructor(
//         private readonly users: UserService,
//         private readonly jwtService: JwtService,
//     ) { }

//     async login(email: string, password: string) {
//         const user = await this.users.findByEmail(email);

//         if (!user) {
//             return undefined;
//         }

//         if (!user.isActive) {
//             return undefined;
//         }

//         const matched = await bcrypt.compare(password, user.passwordHash);

//         if (!matched) {
//             return undefined;
//         }

//         return {
//             accessToken: this.jwtService.createAccessToken(user.id, user.email, user.role),
//             expiresIn: 3600,
//         };
//     }
// }
