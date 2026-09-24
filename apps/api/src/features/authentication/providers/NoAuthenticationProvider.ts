import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class NoAuthenticationProvider implements AuthenticationProvider {
    async authenticate(request: Request): Promise<UserPrincipal | null> {
        throw new Error('NoAuthentication not implemented');

        // return {
        //     userName: 'System',
        //     roles: ['admin'],
        // };
    }
}
