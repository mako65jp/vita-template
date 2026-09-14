import { Hono } from 'hono';
import { AuthenticationService } from '../services/AuthenticationService';

export function createAuthenticationController(service: AuthenticationService) {
    const router = new Hono();

    router.post('/login', async (c) => {
        const body = await c.req.json();

        const result = await service.login(body.email, body.password);

        if (!result) {
            return c.json(
                {
                    message: 'Invalid credentials',
                },
                401,
            );
        }

        return c.json(result);
    });

    return router;
}
