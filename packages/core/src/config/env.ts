import { z } from 'zod';

// アプリケーション全体で統一して使用するポートのデフォルト定数
export const DEFAULT_BACKEND_PORT = 3001;
export const DEFAULT_FRONTEND_PORT = 3000;

// ==========================================
// 1. スキーマの分離定義
// ==========================================

/** フロントエンド用スキーマ (Vite / Browser) */
export const clientEnvSchema = z
    .object({
        // バックエンドポート番号（VITE_API_TARGET_URL の補完計算用）
        PORT: z.coerce.number().int().positive().default(DEFAULT_BACKEND_PORT),
        // フロントエンド開発サーバー用ポート
        VITE_PORT: z.coerce.number().int().positive({ message: 'VITE_PORT は正の整数である必要があります' })
            .default(DEFAULT_FRONTEND_PORT),
        VITE_API_TARGET_URL: z.string().url({ message: 'VITE_API_TARGET_URL は有効なURL形式である必要があります' })
            .optional(),
        VITE_APP_TITLE: z.string()
            .default('My App'),
    })
    .transform((data) => ({
        VITE_PORT: data.VITE_PORT,
        // PORT の指定を反映して VITE_API_TARGET_URL を動的に補完生成
        VITE_API_TARGET_URL: data.VITE_API_TARGET_URL ?? `http://127.0.0.1:${data.PORT}`,
        VITE_APP_TITLE: data.VITE_APP_TITLE,
    }));

/** バックエンド用スキーマ (Node.js Server) */
export const serverEnvSchema = z
    .object({
        NODE_ENV: z.enum(['development', 'test', 'production'])
            .default('development'),
        PORT: z.coerce.number().int().positive({ message: 'PORT は正の整数である必要があります' })
            .default(DEFAULT_BACKEND_PORT),
        API_BASE_URL: z.string().url().optional(),
        DATABASE_URL: z.string().url({ message: 'DATABASE_URL は有効なURL形式である必要があります' })
            .optional(),
        TEST_DATABASE_URL: z.string().url({ message: 'TEST_DATABASE_URL は有効なURL形式である必要があります' })
            .optional(),

        // サーバー側では必須（optional 化の妥協は不要）
        JWT_SECRET: z.string().min(32, { message: 'JWT_SECRET は32文字以上である必要があります' }),
    })
    .superRefine((data, ctx) => {
        if (data.NODE_ENV === 'production') {
            if (!data.DATABASE_URL) {
                ctx.addIssue({
                    code: z.ZodIssueCode.custom,
                    path: ['DATABASE_URL'],
                    message: '本番環境では DATABASE_URL の指定が必須です',
                });
            }
        }
    })
    .transform((data) => ({
        ...data,
        API_BASE_URL: data.API_BASE_URL ?? `http://localhost:${data.PORT}`,
        DATABASE_URL: data.DATABASE_URL
            ?? (data.NODE_ENV !== 'production' ? 'postgresql://postgres:postgres@db:5432/app_db' : ''),
        TEST_DATABASE_URL: data.TEST_DATABASE_URL
            ?? (data.NODE_ENV !== 'production' ? 'postgresql://postgres:postgres@db:5432/app_db_test' : ''),
    }));

export type ClientEnv = z.infer<typeof clientEnvSchema>;
export type ServerEnv = z.infer<typeof serverEnvSchema>;

// ==========================================
// 2. 環境別の安全な評価・生成処理
// ==========================================

/** クライアント環境変数のパース (Vite 環境) */
function getClientEnv(): ClientEnv {
    const targetEnv =
        typeof import.meta !== 'undefined' && import.meta.env
            ? import.meta.env : typeof process !== 'undefined'
                ? process.env : {};

    const result = clientEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        console.error('❌ [Client] 無効な環境変数があります:\n', formattedErrors);
        throw new Error(`[Client] 環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

/** サーバー環境変数のパース (Node.js 環境) */
function getServerEnv(): ServerEnv {
    const targetEnv = typeof process !== 'undefined' ? process.env : {};

    // テスト実行時 (NODE_ENV === 'test') の安全フォールバック処理
    if (targetEnv.NODE_ENV === 'test') {
        const fallbackResult = serverEnvSchema.safeParse({
            ...targetEnv,
            JWT_SECRET: targetEnv.JWT_SECRET ?? '12345678901234567890123456789012',
        });
        if (fallbackResult.success) return fallbackResult.data;
    }

    const result = serverEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        console.error('❌ [Server] 無効な環境変数があります:\n', formattedErrors);
        throw new Error(`[Server] 環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

// ==========================================
// 3. 外部公開用オブジェクト (Export)
// ==========================================

/** フロントエンド用環境変数 (App.tsx などから参照) */
export const clientEnv: ClientEnv = getClientEnv();

/** バックエンド用環境変数 (サーバーコードのみから参照) */
export const env: ServerEnv =
    typeof window === 'undefined'
        ? getServerEnv()
        : (new Proxy({} as ServerEnv, {
            get() {
                throw new Error('❌ [Security Alert] フロントエンド（ブラウザ）からサーバー環境変数 (env) を参照することはできません。');
            },
        }));

// ==========================================
// 4. ログ出力用整形関数
// ==========================================
export function formatEnvForLog(targetEnv: ServerEnv = env): string {
    const maskedEnv = { ...targetEnv };

    if (maskedEnv.DATABASE_URL) {
        maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL
            .replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    }
    if (maskedEnv.TEST_DATABASE_URL) {
        maskedEnv.TEST_DATABASE_URL = maskedEnv.TEST_DATABASE_URL
            .replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    }
    if (maskedEnv.JWT_SECRET) {
        maskedEnv.JWT_SECRET = '***';
    }

    return JSON.stringify(maskedEnv, null, 2);
}

