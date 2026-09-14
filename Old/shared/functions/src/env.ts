import { z } from 'zod';
import { DEFAULT_FRONTEND_PORT, DEFAULT_BACKEND_PORT } from '@shared/config';

/** バックエンド用スキーマ (Node.js Server) */
export const serverEnvSchema = z
    .object({
        NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
        PORT: z.coerce
            .number()
            .int()
            .positive({ message: 'PORT は正の整数である必要があります' })
            .default(DEFAULT_BACKEND_PORT),
        API_BASE_URL: z.string().url().optional(),
        CORS_ORIGIN: z.string().optional(),
        DATABASE_URL: z
            .string()
            .url({ message: 'DATABASE_URL は有効なURL形式である必要があります' })
            .optional(),

        // サーバー側では必須（optional 化の妥協は不要）
        JWT_SECRET: z.string().min(32, { message: 'JWT_SECRET は32文字以上である必要があります' }),

        // 認証プロバイダ選択・AD用設定 ---
        AUTH_PROVIDER: z.enum(['local', 'ad']).default('local'),
        LDAP_URL: z.string().optional(),
        LDAP_DOMAIN: z.string().optional(),
    })
    .superRefine((data, ctx) => {
        if (data.NODE_ENV === 'production' && !data.DATABASE_URL) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                path: ['DATABASE_URL'],
                message: '本番環境では DATABASE_URL の指定が必須です',
            });
        }
        if (data.AUTH_PROVIDER === 'ad' && (!data.LDAP_URL || !data.LDAP_DOMAIN)) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                path: ['LDAP_URL'],
                message: 'AUTH_PROVIDER が ad の場合、LDAP_URL および LDAP_DOMAIN の指定は必須です',
            });
        }
    })
    .transform((data) => ({
        ...data,
        API_BASE_URL: data.API_BASE_URL ?? `http://localhost:${data.PORT}`,
        CORS_ORIGIN: data.CORS_ORIGIN ?? `http://localhost:${DEFAULT_FRONTEND_PORT}`,
        DATABASE_URL:
            data.DATABASE_URL ??
            (data.NODE_ENV !== 'production' ? 'postgresql://postgres:postgres@db:5432/app_db' : ''),
    }));

export type ServerEnv = z.infer<typeof serverEnvSchema>;

// サーバー環境変数のパース (Node.js 環境)
function getServerEnv(): ServerEnv {
    const targetEnv = typeof process !== 'undefined' && process.env ? process.env : {};
    const result = serverEnvSchema.safeParse(targetEnv);
    if (!result.success) {
        throw new Error(
            `[Server] 環境変数の検証に失敗しました:\n${JSON.stringify(result.error.format(), null, 2)}`,
        );
    }
    return result.data;
}

// バックエンド用環境変数 (サーバーコードのみから参照)
export const isTest =
    typeof process !== 'undefined' &&
    process.env &&
    (process.env.NODE_ENV === 'test' || Boolean(process.env.VITEST));

export const isServer = typeof globalThis !== 'undefined' && !('document' in globalThis);

export const env: ServerEnv =
    isServer || isTest
        ? getServerEnv()
        : new Proxy({} as ServerEnv, {
              get() {
                  throw new Error(
                      '❌ [Security Alert] フロントエンドからサーバー環境変数を参照することはできません。',
                  );
              },
          });

export function formatEnvForLog(targetEnv: ServerEnv = env): string {
    const maskedEnv = { ...targetEnv };
    if (maskedEnv.DATABASE_URL)
        maskedEnv.DATABASE_URL = maskedEnv.DATABASE_URL.replace(/:\/\/(.*):(.*)@/, '://$1:***@');
    if (maskedEnv.JWT_SECRET) maskedEnv.JWT_SECRET = '***';
    return JSON.stringify(maskedEnv, null, 2);
}
