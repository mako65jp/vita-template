import { defineConfig } from 'drizzle-kit';
import { env } from '../functions';

export default defineConfig({
    schema: '../schemas/index.ts',
    out: './drizzle',
    dialect: 'postgresql',
    dbCredentials: {
        url: env.DATABASE_URL,
    },
});
