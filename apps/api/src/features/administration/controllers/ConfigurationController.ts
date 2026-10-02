import { AuthenticationPolicy } from '@packages/types/administration/AuthenticationPolicy';
import { defaultAuthenticationPolicy } from '@packages/types/administration/defaultAuthenticationPolicy';
import { Hono } from 'hono';
import { ConfigurationService } from '../services/ConfigurationService';

const configuration = {
    authenticationPolicy: defaultAuthenticationPolicy,
};

export function createConfigurationController(service: ConfigurationService) {
    const router = new Hono();

    router.get('/configuration', (c) => {
        return c.json(configuration);
    });

    router.put('/configuration', async (c) => {
        const body = await c.req.json();

        configuration.authenticationPolicy = body.authenticationPolicy as AuthenticationPolicy;

        return c.json(configuration);
    });

    return router;
}
