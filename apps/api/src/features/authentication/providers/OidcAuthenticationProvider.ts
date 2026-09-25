import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class OidcAuthenticationProvider
    implements AuthenticationProvider {

    async authenticate(
        username: string,
        password: string,
    ): Promise<UserPrincipal | null> {

        throw new Error(
            'OIDC authentication not implemented.',
        );
    }
}

// import { UserPrincipal } from '../domain/UserPrincipal';
// import { AuthenticationProvider } from './AuthenticationProvider';

// export class OidcAuthenticationProvider implements AuthenticationProvider {
//     async authenticate(
//         username: string,
//         password: string,
//     ): Promise<UserPrincipal | null> {
//         throw new Error('OIDC not implemented');
//     }
// }
