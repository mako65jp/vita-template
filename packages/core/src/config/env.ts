import { z } from 'zod';

// ==========================================
// 1. バックエンド用 (Node.js) スキーマ & 関数
// ==========================================
export const envSchema = z.object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    PORT: z.coerce.number().default(3001),
    DATABASE_URL: z.string().url({ message: 'DATABASE_URL は有効なURL形式である必要があります' }),
});

export type Env = z.infer<typeof envSchema>;

export function validateEnv(targetEnv: Record<string, string | undefined> = process.env): Env {
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
 */
export function formatEnvForLog(envObj: Env): string {
    const maskedEnv = { ...envObj };

    if (maskedEnv.DATABASE_URL) {
        maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL.replace(
            /:\/\/(.*):(.*)@/,
            '://$1:***@'
        );
    }

    return JSON.stringify(maskedEnv, null, 2);
}

// ⚠️ トップレベルで validateEnv() を直接実行するのではなく、
// ブラウザ環境（typeof window !== 'undefined'）では参照しない安全なガードを入れる
export const env: Env = typeof window !== 'undefined'
    ? ({} as Env)
    : (process.env.NODE_ENV === 'test'
        ? (process.env as unknown as Env)
        : validateEnv());


// ==========================================
// 2. フロントエンド用 (Vite / Browser) スキーマ
// ==========================================
export const clientEnvSchema = z.object({
    VITE_PORT: z.string().optional().default('3000'),
    VITE_API_TARGET_URL: z.string().url().optional().default('http://127.0.0.1:3001'),
    VITE_APP_TITLE: z.string().optional().default('My App'),
});

export type ClientEnv = z.infer<typeof clientEnvSchema>;
