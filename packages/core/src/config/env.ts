import { z } from 'zod';

// アプリケーション全体で統一して使用するポートのデフォルト定数
const DEFAULT_BACKEND_PORT = 3001;
const DEFAULT_FRONTEND_PORT = 3000;

// ==========================================
// 1. 全環境変数の統合検証 & 補完スキーマ
// ==========================================
export const allEnvSchema = z.object({
    // 共通・バックエンド用
    NODE_ENV: z.enum(['development', 'test', 'production'])
        .default('development'),
    PORT: z.coerce.number().int().positive({ message: 'PORT は正の整数である必要があります' })
        .default(DEFAULT_BACKEND_PORT),
    API_BASE_URL: z.string().url()
        .optional(),
    DATABASE_URL: z.string().url({ message: 'DATABASE_URL は有効なURL形式である必要があります' })
        .optional(),
    TEST_DATABASE_URL: z.string().url({ message: 'TEST_DATABASE_URL は有効なURL形式である必要があります' })
        .optional(),
    JWT_SECRET: z.string().min(32, { message: 'JWT_SECRET は32文字以上である必要があります' }),

    // フロントエンド用 (Vite / Browser)
    VITE_PORT: z.coerce.number().int().positive({ message: 'VITE_PORT は正の整数である必要があります' })
        .default(DEFAULT_FRONTEND_PORT),
    VITE_API_TARGET_URL: z.string().url({ message: 'VITE_API_TARGET_URL は有効なURL形式である必要があります' })
        .optional(),
    VITE_APP_TITLE: z.string()
        .default('My App'),
}).superRefine((data, ctx) => {
    // 本番環境 (production) の場合は、重要インフラ・シークレットの存在を厳格に要求
    if (data.NODE_ENV === 'production') {
        if (!data.DATABASE_URL) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                path: ['DATABASE_URL'],
                message: '本番環境では DATABASE_URL の指定が必須です',
            });
        }
        if (!data.JWT_SECRET) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                path: ['JWT_SECRET'],
                message: '本番環境では 32文字以上の JWT_SECRET の指定が必須です',
            });
        }
    }
}).transform((data) => ({
    ...data,
    // API_BASE_URL: 未指定の場合、設定された PORT の数値から動的に URL を補完生成
    API_BASE_URL: data.API_BASE_URL ?? `http://localhost:${data.PORT}`,
    // VITE_API_TARGET_URL: 未指定の場合、設定された PORT の数値から動的に URL を補完生成
    VITE_API_TARGET_URL: data.VITE_API_TARGET_URL ?? `http://127.0.0.1:${data.PORT}`,

    DATABASE_URL: data.DATABASE_URL
        ?? (data.NODE_ENV !== 'production' ? 'postgresql://postgres:postgres@db:5432/app_db' : ''),
    TEST_DATABASE_URL: data.TEST_DATABASE_URL
        ?? (data.NODE_ENV !== 'production' ? 'postgresql://postgres:postgres@db:5432/app_db_test' : ''),
}));

export type AllEnv = z.infer<typeof allEnvSchema>;

// ==========================================
// 2. モジュール読み込み時の評価・安全パース
// ==========================================
const parsedAllEnv: AllEnv = (() => {
    const targetEnv = typeof process !== 'undefined' ? process.env : {};
    const result = allEnvSchema.safeParse(targetEnv);

    if (!result.success) {
        // 単体テスト実行時 (NODE_ENV === 'test') は、テスト停止を防ぐためスキーマの初期化ルールに従う
        if (targetEnv.NODE_ENV === 'test' || (typeof process !== 'undefined' && process.env.NODE_ENV === 'test')) {
            return allEnvSchema.parse({});
        }

        const formattedErrors = JSON.stringify(result.error.format(), null, 2);
        console.error('❌ 無効な環境変数があります:\n', formattedErrors);
        throw new Error(`環境変数の検証に失敗しました:\n${formattedErrors}`);
    }

    return result.data;
})();

// ==========================================
// 3. 外部公開用オブジェクト (export 対象)
// ==========================================
export const env = {
    NODE_ENV: parsedAllEnv.NODE_ENV,
    PORT: parsedAllEnv.PORT,
    API_BASE_URL: parsedAllEnv.API_BASE_URL,
    DATABASE_URL: parsedAllEnv.DATABASE_URL,
    TEST_DATABASE_URL: parsedAllEnv.TEST_DATABASE_URL,
    JWT_SECRET: parsedAllEnv.JWT_SECRET,
};
export type Env = typeof env;

export const clientEnv = {
    VITE_PORT: parsedAllEnv.VITE_PORT,
    VITE_API_TARGET_URL: parsedAllEnv.VITE_API_TARGET_URL,
    VITE_APP_TITLE: parsedAllEnv.VITE_APP_TITLE,
};
export type ClientEnv = typeof clientEnv;

// ==========================================
// 4. ログ出力用整形関数 (export 対象)
// ==========================================
export function formatEnvForLog(targetEnv: Env = env): string {
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
