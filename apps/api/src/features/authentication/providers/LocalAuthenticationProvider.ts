import bcrypt from 'bcrypt';

import { UserService } from '../../user/services/UserService';
import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class LocalAuthenticationProvider implements AuthenticationProvider {
    constructor(private readonly userService: UserService) {}

    async authenticate(username: string, password: string): Promise<UserPrincipal | null> {
        const user = await this.userService.findByEmail(username);

        if (!user) {
            return null;
        }

        if (!user.isActive) {
            return null;
        }

        const matched = await bcrypt.compare(password, user.passwordHash);

        if (!matched) {
            return null;
        }

        return {
            userId: String(user.id),
            email: user.email,
            role: user.role,
        };
    }
}

// import bcrypt from 'bcrypt';

// import { UserService } from '../../user/services/UserService';
// import { UserPrincipal } from '../domain/UserPrincipal';
// import { AuthenticationProvider } from './AuthenticationProvider';

// export class LocalAuthenticationProvider
//     implements AuthenticationProvider {

//     constructor(
//         private readonly users: UserService,
//     ) { }

//     async authenticate(
//         username: string,
//         password: string,
//     ): Promise<UserPrincipal | null> {

//         const user =
//             await this.users.findByEmail(username);

//         if (!user) {
//             return null;
//         }

//         if (!user.isActive) {
//             return null;
//         }

//         const matched =
//             await bcrypt.compare(
//                 password,
//                 user.passwordHash,
//             );

//         if (!matched) {
//             return null;
//         }

//         return {
//             userId: String(user.id),
//             email: user.email,
//             role: user.role,
//         };
//     }
// }
