import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class LdapAuthenticationProvider implements AuthenticationProvider {
    async authenticate(request: Request): Promise<UserPrincipal | null> {
        throw new Error('LDAP not implemented');
    }
}
