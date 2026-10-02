import bcrypt from 'bcrypt';

import { UserService } from '../../user/service';
import { UserPrincipal } from '../domain/UserPrincipal';
import { AuthenticationProvider } from './AuthenticationProvider';

export class LocalAuthenticationProvider implements AuthenticationProvider {
    constructor(private readonly userService: UserService) {}

    async authenticate(username: string, password: string): Promise<UserPrincipal | null> {
        const user = await this.userService.findByEmail(username);

        if (!user) {
            console.log(`LocalAuthenticationProvider.authenticate:`);
            console.log(`  userService:${this.userService.findByEmail !== null}`);
            console.log(`  username:${username}`);
            console.log(`  password:${password}`);
            return null;
        }

        if (!user.isActive) {
            return null;
        }

        const matched = await bcrypt.compare(password, user.passwordHash);

        if (!matched) {
            return null;
        }

        return {
            userId: String(user.id),
            email: user.email,
            role: user.role,
        };
    }
}
