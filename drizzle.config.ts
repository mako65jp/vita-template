import { defineConfig } from 'drizzle-kit';

export default defineConfig({
    schema: './packages/schema/src/database/*',
    out: './apps/api/drizzle',
    dialect: 'postgresql',
    dbCredentials: {
        url: process.env.DATABASE_URL!,
    },
});
