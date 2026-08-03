import { defineConfig } from 'drizzle-kit';

export default defineConfig({
    // スキーマファイルの場所
    schema: './src/db/schema.ts',

    // マイグレーションファイルの出力先（push の場合は参照のみ）
    out: './drizzle',

    // 使用する DB ドライバー
    dialect: 'postgresql',

    // 接続情報（.env から読み込み）
    dbCredentials: {
        url: process.env.DATABASE_URL || 'postgresql://postgres:postgres@db:5432/app_db_test',
    },
});
