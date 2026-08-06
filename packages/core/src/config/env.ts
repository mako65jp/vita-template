import { z } from 'zod';

// ==========================================
// 1. バックエンド用 (Node.js) スキーマ & 関数
// ==========================================
export const envSchema = z
    .object({
        NODE_ENV: z.enum(['development', 'test', 'production'])
            .default('development'),
        PORT: z.coerce.number()
            .default(3001),
        API_BASE_URL: z.string().url().optional(),
        DATABASE_URL: z.string().url({ message: 'DATABASE_URL は有効なURL形式である必要があります' }),
        TEST_DATABASE_URL: z.string().url({ message: 'TEST_DATABASE_URL は有効なURL形式である必要があります' })
            .default('postgresql://postgres:postgres@localhost:5432/app_db_test'),
        JWT_SECRET: z.string().min(32)
            .default('super-secret-jwt-key-for-testing-purposes-123456'),
    })
    .transform((data) => ({
        ...data,
        // API_BASE_URL が明示的に与えられていない場合は PORT から動的に補完
        API_BASE_URL: data.API_BASE_URL ?? `http://localhost:${data.PORT}`,
    }));

export type Env = z.infer<typeof envSchema>;

// テスト時も含めて安全に検証したオブジェクトを取得
export const env: Env = typeof window !== 'undefined' ? ({} as Env) : validateEnv();

function validateEnv(targetEnv: Record<string, string | undefined> = process.env): Env {
    const result = envSchema.safeParse(targetEnv);

    if (!result.success) {
        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        console.error('❌ 無効な環境変数があります:\n', formattedErrors);
        throw new Error(`環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
}

/**
 * ログ出力用に環境変数を整形（パスワード等はマスク）する関数
 * 引数を渡さない場合は内部の `env` を使用
 */
export function formatEnvForLog(targetEnv: Env = env): string {
    const maskedEnv = { ...targetEnv };

    if (maskedEnv.DATABASE_URL) {
        maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL.replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    }
    if (maskedEnv.TEST_DATABASE_URL) {
        maskedEnv.TEST_DATABASE_URL = maskedEnv.TEST_DATABASE_URL.replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    }
    if (maskedEnv.JWT_SECRET) {
        maskedEnv.JWT_SECRET = '***';
    }

    return JSON.stringify(maskedEnv, null, 2);
}

// ==========================================
// 2. フロントエンド用 (Vite / Browser) スキーマ
// ==========================================
export const clientEnvSchema = z.object({
    VITE_PORT: z.string().optional()
        .default('3000'),
    VITE_API_TARGET_URL: z.string().url().optional()
        .default('http://127.0.0.1:3001'),
    VITE_APP_TITLE: z.string().optional()
        .default('My App'),
});

export type ClientEnv = z.infer<typeof clientEnvSchema>;
