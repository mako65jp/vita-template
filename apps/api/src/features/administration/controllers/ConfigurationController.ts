import { AuthenticationPolicy } from '@packages/types/authentication/AuthenticationPolicy';
import { defaultAuthenticationPolicy } from '@packages/types/authentication/defaultAuthenticationPolicy';
import { Hono } from 'hono';

const configuration = {
    authenticationPolicy: defaultAuthenticationPolicy,
};

export const configurationRouter = new Hono();

configurationRouter.get('/configuration', (c) => {
    return c.json(configuration);
});

configurationRouter.put('/configuration', async (c) => {
    const body = await c.req.json();

    configuration.authenticationPolicy = body.authenticationPolicy as AuthenticationPolicy;

    return c.json(configuration);
});
