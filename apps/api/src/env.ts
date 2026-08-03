import { z } from 'zod';

const envSchema = z.object({
    DATABASE_URL: z.string().min(1, '環境変数の検証に失敗しました'),
    PORT: z.string().optional(),
});

export function validateEnv(env: Record<string, string | undefined> = process.env) {
    const result = envSchema.safeParse(env);
    if (!result.success) {
        throw new Error('環境変数の検証に失敗しました');
    }
    return result.data;
}
