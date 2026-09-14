import jwt from 'jsonwebtoken';

export class JwtService {
    constructor(private readonly secret: string) {}

    createAccessToken(userId: number, email: string, role: string) {
        return jwt.sign(
            {
                sub: userId,
                email,
                role,
            },
            this.secret,
            {
                expiresIn: '1h',
            },
        );
    }

    verify(token: string) {
        return jwt.verify(token, this.secret);
    }
}
