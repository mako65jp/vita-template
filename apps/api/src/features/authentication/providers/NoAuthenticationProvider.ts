import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class NoAuthenticationProvider implements AuthenticationProvider {
    async authenticate(username: string, password: string): Promise<UserPrincipal | null> {
        return {
            userId: 'system',
            email: 'system@localhost',
            role: 'admin',
        };
    }
}

// import { UserPrincipal } from '../domain/UserPrincipal';
// import { AuthenticationProvider } from './AuthenticationProvider';

// export class NoAuthenticationProvider
//     implements AuthenticationProvider {

//     async authenticate(
//         username: string,
//         password: string,
//     ): Promise<UserPrincipal | null> {

//         return {
//             userId: 'system',
//             email: 'system',
//             role: 'admin',
//         };
//     }
// }

// // import { UserPrincipal } from '../domain/UserPrincipal';
// // import { AuthenticationProvider } from './AuthenticationProvider';

// // export class NoAuthenticationProvider implements AuthenticationProvider {
// //     async authenticate(request: Request): Promise<UserPrincipal | null> {
// //         throw new Error('NoAuthentication not implemented');

// //         // return {
// //         //     userName: 'System',
// //         //     roles: ['admin'],
// //         // };
// //     }
// // }
