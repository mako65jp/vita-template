import { defineConfig } from 'drizzle-kit';
import { env } from '@shared/functions';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default defineConfig({
    // schema: './src/schema/index.ts',
    // out: './drizzle',

    schema: path.resolve(__dirname, './src/schema/index.ts'),
    out: path.resolve(__dirname, './drizzle'),

    dialect: 'postgresql',
    dbCredentials: {
        url: env.DATABASE_URL,
    },
});
