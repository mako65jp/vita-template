import { serve } from '@hono/node-server';

import { loadConfig } from './config/loadConfig';

import { createContainer } from './app/createContainer';

import { createApp } from './app/createApp';

const config = await loadConfig();

const container = await createContainer(config);

const app = createApp(container);

serve({
    fetch: app.fetch,
    port: 3000,
});

console.log('Listening on :3000');
