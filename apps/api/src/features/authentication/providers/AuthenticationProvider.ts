import { UserPrincipal } from '../domain/UserPrincipal';

export interface AuthenticationProvider {
    authenticate(request: Request): Promise<UserPrincipal | null>;
}
