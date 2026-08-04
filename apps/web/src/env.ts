import { clientEnvSchema, type ClientEnv } from '@app/core';

// Vite の import.meta.env を Zod で検証・補完
export const env: ClientEnv = clientEnvSchema.parse({
    VITE_PORT: import.meta.env.VITE_PORT,
    VITE_API_TARGET_URL: import.meta.env.VITE_API_TARGET_URL,
    VITE_APP_TITLE: import.meta.env.VITE_APP_TITLE,
});
