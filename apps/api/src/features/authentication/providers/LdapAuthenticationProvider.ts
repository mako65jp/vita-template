import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class LdapAuthenticationProvider implements AuthenticationProvider {
    async authenticate(username: string, password: string): Promise<UserPrincipal | null> {
        throw new Error('LDAP authentication not implemented.');
    }
}

// import { UserPrincipal } from '../domain/UserPrincipal';
// import { AuthenticationProvider } from './AuthenticationProvider';

// export class LdapAuthenticationProvider implements AuthenticationProvider {
//     async authenticate(
//         username: string,
//         password: string,
//     ): Promise<UserPrincipal | null> {
//         throw new Error('LDAP not implemented');
//     }
// }
