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
