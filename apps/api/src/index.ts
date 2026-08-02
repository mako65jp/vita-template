import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { loadFeatureModules } from '@app/core/registry/hono-auto-loader.ts';
import { AuthRegistry } from '@app/core/auth/auth-registry.ts';
import { LocalAuthPlugin } from '@app/plugins/auth-local/src/index.ts';
import { ActiveDirectoryAuthPlugin } from '@app/plugins/auth-ad/src/index.ts';
import authRouter from './routes/auth.ts';

AuthRegistry.register(new LocalAuthPlugin());
AuthRegistry.register(new ActiveDirectoryAuthPlugin());

const app = new Hono();

app.route('/api/auth', authRouter);
await loadFeatureModules(app, 'packages/features/*/src/index.ts');

const port = 3001;
console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);

serve({
  fetch: app.fetch,
  port,
  hostname: '0.0.0.0'
});

export default app;
