import { UserRepository } from '../../user/repositories/UserRepository';
import { UserPrincipal } from '../domain/UserPrincipal';
import { JwtService } from '../services/JwtService';
import { AuthenticationProvider } from './AuthenticationProvider';

export class JwtAuthenticationProvider implements AuthenticationProvider {
    constructor(
        private readonly jwtService: JwtService,
        private readonly userRepository: UserRepository,
    ) {}

    async authenticate(request: Request): Promise<UserPrincipal | null> {
        throw new Error('JWT not implemented');

        // Authorization解析

        // JWT検証

        // User取得

        // UserPrincipal返却
    }
}
