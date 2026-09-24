import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class OidcAuthenticationProvider implements AuthenticationProvider {
    async authenticate(request: Request): Promise<UserPrincipal | null> {
        throw new Error('OIDC not implemented');
    }
}
