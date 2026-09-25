import { Context, Next } from 'hono';
import { JwtService } from '../services/JwtService';

export function jwtAuthentication(jwtService: JwtService) {

    return async (c: Context, next: Next) => {

        const authorization = c.req.header('Authorization');

        if (!authorization || !authorization.startsWith('Bearer ')) {
            return c.json(
                { message: 'Unauthorized', },
                401,
            );
        }

        try {
            const token = authorization.substring(7);
            const principal = jwtService.verify(token);

            c.set('principal', principal);

            await next();

        } catch {
            return c.json(
                { message: 'Unauthorized', },
                401,
            );
        }
    };
}

