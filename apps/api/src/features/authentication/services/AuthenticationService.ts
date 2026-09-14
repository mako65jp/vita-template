import bcrypt from 'bcrypt';
import { UserService } from '../../user/services/UserService';
import { JwtService } from './JwtService';

export class AuthenticationService {
    constructor(
        private readonly users: UserService,
        private readonly jwt: JwtService,
    ) {}

    async login(email: string, password: string) {
        const user = await this.users.findByEmail(email);

        if (!user) {
            return undefined;
        }

        const matched = await bcrypt.compare(password, user.passwordHash);

        if (!matched) {
            return undefined;
        }

        return {
            accessToken: this.jwt.createAccessToken(user.id, user.email, user.role),
            expiresIn: 3600,
        };
    }
}
