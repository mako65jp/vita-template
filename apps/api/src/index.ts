import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { loadFeatureModules } from '@app/core/registry/hono-auto-loader.ts';
import { AuthRegistry } from '@app/core/auth/auth-registry.ts';
import { LocalAuthPlugin } from '@app/plugins/auth-local/src/index.ts';
import { ActiveDirectoryAuthPlugin } from '@app/plugins/auth-ad/src/index.ts';
import { validateEnv, formatEnvForLog } from '@app/core/config/env.ts';
import authRouter from './routes/auth.ts';

// 1. 起動時に環境変数を検証・取得
const env = validateEnv();

// 2. コンソールに読み込まれた環境変数を綺麗に出力 🚀
console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog(env));

AuthRegistry.register(new LocalAuthPlugin());
AuthRegistry.register(new ActiveDirectoryAuthPlugin());

const app = new Hono();

app.route('/api/auth', authRouter);
await loadFeatureModules(app, 'packages/features/*/src/index.ts');

const port = env.PORT; // 型安全な数値ポ—ト番号を使用
console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);

// 💡 テスト環境（NODE_ENV === 'test'）以外の場合のみ、実際の HTTP サーバーを起動する
if (process.env.NODE_ENV !== 'test') {
  console.log(`[API] Server running inside DevContainer on http://0.0.0.0:${port}`);
  serve({
    fetch: app.fetch,
    port,
    hostname: '0.0.0.0',
  });
}

export default app;
