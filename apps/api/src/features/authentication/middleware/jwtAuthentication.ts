import { Context, Next } from 'hono';
import jwt from 'jsonwebtoken';
import { UserRepository } from "../../user/repositories/UserRepository";

export function jwtAuthentication(secret: string, userRepository: UserRepository) {
    return async (c: Context, next: Next) => {
        const authorization = c.req.header('Authorization');

        if (!authorization || !authorization.startsWith('Bearer ')) {
            return c.json(
                {
                    message: 'Unauthorized',
                },
                401,
            );
        }

        const token = authorization.substring(7);

        try {
            const payload = jwt.verify(token, secret);

            const user = await userRepository.findById(String((payload as any).sub));

            if (!user || !user.isActive) {
                return c.json(
                    {
                        message: 'Account disabled',
                    },
                    403,
                );
            }

            c.set('jwt', payload);

            await next();
        } catch {
            return c.json(
                {
                    message: 'Unauthorized',
                },
                401,
            );
        }
    };
}
