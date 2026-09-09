import { z } from 'zod';
import { DEFAULT_FRONTEND_PORT, DEFAULT_BACKEND_PORT, } from '@shared/config';

// Node.js process のグローバル型宣言（DOM環境における型欠落防止）
declare const process: {
    env?: Record<string, string>;
} | undefined;

// フロントエンド用スキーマ (Vite / Browser)
export const clientEnvSchema = z
    .object({
        // バックエンドポート番号（VITE_API_TARGET_URL の補完計算用）
        PORT: z.coerce.number().int().positive()
            .default(DEFAULT_BACKEND_PORT),
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

// クライアント環境変数のパース (Vite 環境)
function getClientEnv(): ClientEnv {
    const metaEnv = typeof import.meta !== 'undefined'
        ? (import.meta as { env?: Record<string, string> }).env
        : undefined;
    const targetEnv = metaEnv
        ? metaEnv
        : ((typeof process !== 'undefined' && process.env) ? process.env : {});
    const result = clientEnvSchema.safeParse(targetEnv);
    if (!result.success) {
        throw new Error(`[Client] 環境変数の検証に失敗しました:\n${JSON.stringify(result.error.format(), null, 2)}`);
    }
    return result.data;
}

export type ClientEnv = z.infer<typeof clientEnvSchema>;

// フロントエンド用環境変数 (App.tsx などから参照)
export const clientEnv: ClientEnv = getClientEnv();

