import { serve } from '@hono/node-server';
import { createApp } from './app/createApp';
import { createContainer } from './app/createContainer';
import { loadConfig } from './config/loadConfig';

const config = await loadConfig();

const container = await createContainer(config);

const app = createApp(container);

serve({
    fetch: app.fetch,
    port: Number(config.backend.port),
});

console.log(`Listening on :${config.backend.port}`);
