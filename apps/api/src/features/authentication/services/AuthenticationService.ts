import { AuthenticationProvider } from '../providers/AuthenticationProvider';
import { JwtService } from './JwtService';

export class AuthenticationService {
    constructor(
        private readonly provider: AuthenticationProvider,
        private readonly jwtService: JwtService,
    ) {}

    async login(username: string, password: string) {
        const principal = await this.provider.authenticate(username, password);

        if (!principal) {
            console.log(`AuthenticationService:`);
            console.log(`  username:${username}`);
            console.log(`  password:${password}`);
            console.log(`  provider:${this.provider !== null}`);
            return undefined;
        }

        const accessToken = this.jwtService.createAccessToken(principal);
        const expiresIn = this.jwtService.expiresInSeconds;
        return {
            accessToken: accessToken,
            expiresIn: expiresIn,
        };
    }
}
