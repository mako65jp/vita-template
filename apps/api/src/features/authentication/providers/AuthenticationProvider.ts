import { UserPrincipal } from '../domain/UserPrincipal';

export interface AuthenticationProvider {
    authenticate(username: string, password: string): Promise<UserPrincipal | null>;
}
