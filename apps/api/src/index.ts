import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { validateEnv, formatEnvForLog } from '@app/core/config/env.ts';
import { AppError, ProblemDetails } from '@app/core/errors/index.ts';
import { loadFeatureModules } from '@app/core/registry/hono-auto-loader.ts';
import { AuthRegistry } from '@app/core/auth/auth-registry.ts';
import { LocalAuthPlugin } from '@app/plugins/auth-local/src/index.ts';
import { ActiveDirectoryAuthPlugin } from '@app/plugins/auth-ad/src/index.ts';
import authRouter from './routes/auth.ts';

// 1. 起動時に環境変数を検証・取得
const env = validateEnv();

// 2. コンソールに読み込まれた環境変数を綺麗に出力 (テスト時以外) 🚀
if (process.env.NODE_ENV !== 'test') {
  console.log('⚙️ Loaded Environment Variables:\n' + formatEnvForLog(env));
}

// 3. プラグインの登録
AuthRegistry.register(new LocalAuthPlugin());
AuthRegistry.register(new ActiveDirectoryAuthPlugin());

const app = new Hono();

// -----------------------------------------------------------------------------
// テスト専用ルート (NODE_ENV === 'test' の場合のみ有効化)
// -----------------------------------------------------------------------------
if (process.env.NODE_ENV === 'test') {
  app.get('/test/error', () => {
    throw new Error('Test internal error');
  });
}

// -----------------------------------------------------------------------------
// ルーティング・モジュール読み込み
// -----------------------------------------------------------------------------
app.route('/api/auth', authRouter);
await loadFeatureModules(app, 'packages/features/*/src/index.ts');

// -----------------------------------------------------------------------------
// 404 Not Found ハンドラー (RFC 7807 形式)
// -----------------------------------------------------------------------------
app.notFound((c) => {
  const problem: ProblemDetails = {
    type: 'https://api.example.com/errors/not-found',
    title: 'Not Found',
    status: 404,
    detail: 'The requested resource was not found',
    instance: c.req.path,
  };
  return c.json(problem, 404);
});

// -----------------------------------------------------------------------------
// 共通エラーハンドラー (app.onError - RFC 7807 形式)
// -----------------------------------------------------------------------------
app.onError((err, c) => {
  // テスト時以外のエラーログ出力
  if (process.env.NODE_ENV !== 'test') {
    console.error(`[Error] ${c.req.method} ${c.req.path}:`, err);
  }

  let status = 500;
  let type = 'https://api.example.com/errors/internal-server-error';
  let title = 'Internal Server Error';
  let detail = 'An unexpected error occurred';

  // アプリケーション固有の例外（AppError）の場合
  if (err instanceof AppError) {
    status = err.status;
    type = `https://api.example.com/errors/${err.code}`;
    title = err.title;
    detail = err.message;
  }

  const problem: ProblemDetails = {
    type,
    title,
    status,
    detail,
    instance: c.req.path,
  };

  return c.json(problem, status as any);
});

// -----------------------------------------------------------------------------
// サーバーバインド & 起動処理
// -----------------------------------------------------------------------------
const port = env.PORT; // 型安全な数値ポート番号を使用

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
